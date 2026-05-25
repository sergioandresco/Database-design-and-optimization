-- ============================================================================
-- ECOMMIFY - Núcleo transaccional (PostgreSQL / Supabase)
-- Etapa: Diseño relacional - Actividad U2
-- ----------------------------------------------------------------------------
-- Modelo basado en el dataset Brazilian E-commerce (Olist), 9 tablas.
-- Las claves product_id, order_id y customer_id son las claves compartidas
-- con la capa documental de MongoDB Atlas (ver notebooks/02_MongoDB_Atlas).
--
-- Orden de columnas idéntico al de los CSV de Olist para permitir carga
-- directa con COPY ... FROM CSV HEADER (el header se ignora por posición).
-- ============================================================================

-- Idempotencia: limpia el esquema antes de recrearlo.
DROP TABLE IF EXISTS order_reviews     CASCADE;
DROP TABLE IF EXISTS order_payments    CASCADE;
DROP TABLE IF EXISTS order_items       CASCADE;
DROP TABLE IF EXISTS orders            CASCADE;
DROP TABLE IF EXISTS products          CASCADE;
DROP TABLE IF EXISTS category_translation CASCADE;
DROP TABLE IF EXISTS sellers           CASCADE;
DROP TABLE IF EXISTS customers         CASCADE;
DROP TABLE IF EXISTS geolocation       CASCADE;

-- ----------------------------------------------------------------------------
-- 1. geolocation
-- El prefijo de ZIP NO es único en Olist (varias coordenadas por prefijo),
-- por eso se usa una PK surrogate y NO se referencia con FK estricta.
-- ----------------------------------------------------------------------------
CREATE TABLE geolocation (
    geolocation_id            BIGSERIAL PRIMARY KEY,
    geolocation_zip_code_prefix INTEGER NOT NULL,
    geolocation_lat           DOUBLE PRECISION,
    geolocation_lng           DOUBLE PRECISION,
    geolocation_city          VARCHAR(120),
    geolocation_state         CHAR(2)
);
COMMENT ON TABLE geolocation IS 'Coordenadas por prefijo de código postal (no único). Referencia geográfica.';

-- ----------------------------------------------------------------------------
-- 2. customers
-- ----------------------------------------------------------------------------
CREATE TABLE customers (
    customer_id               VARCHAR(32) PRIMARY KEY,
    customer_unique_id        VARCHAR(32) NOT NULL,
    customer_zip_code_prefix  INTEGER,
    customer_city             VARCHAR(120),
    customer_state            CHAR(2)
);
COMMENT ON TABLE customers IS 'Cliente por pedido. customer_unique_id agrupa al cliente real entre pedidos.';
COMMENT ON COLUMN customers.customer_id IS 'Clave compartida con MongoDB (user_behavior, recommendations).';

-- ----------------------------------------------------------------------------
-- 3. sellers
-- ----------------------------------------------------------------------------
CREATE TABLE sellers (
    seller_id                 VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix    INTEGER,
    seller_city               VARCHAR(120),
    seller_state              CHAR(2)
);
COMMENT ON TABLE sellers IS 'Vendedores del marketplace.';

-- ----------------------------------------------------------------------------
-- 4. category_translation  (product_category_name_translation.csv)
-- ----------------------------------------------------------------------------
CREATE TABLE category_translation (
    product_category_name         VARCHAR(80) PRIMARY KEY,
    product_category_name_english VARCHAR(80) NOT NULL
);
COMMENT ON TABLE category_translation IS 'Traducción PT->EN de la categoría. Origen de category.name_pt/name_en en MongoDB.';

-- ----------------------------------------------------------------------------
-- 5. products
-- Nota: product_category_name puede ser NULL o no estar en la tabla de
-- traducción (caso real de Olist). FK NOT VALID para permitir carga del
-- dataset crudo; valídala luego con: ALTER TABLE products VALIDATE CONSTRAINT ...
-- ----------------------------------------------------------------------------
CREATE TABLE products (
    product_id                  VARCHAR(32) PRIMARY KEY,
    product_category_name       VARCHAR(80),
    product_name_length         INTEGER,
    product_description_length  INTEGER,
    product_photos_qty          INTEGER,
    product_weight_g            INTEGER,
    product_length_cm           INTEGER,
    product_height_cm           INTEGER,
    product_width_cm            INTEGER
);
COMMENT ON TABLE products IS 'Catálogo transaccional. product_id es clave compartida con MongoDB (products, reviews).';

-- FK a la traducción como NOT VALID: no revalida filas existentes (permite
-- cargar el Olist crudo con categorías huérfanas) pero sí valida las nuevas.
-- Para forzar la revisión total: ALTER TABLE products VALIDATE CONSTRAINT fk_products_category;
ALTER TABLE products
    ADD CONSTRAINT fk_products_category
    FOREIGN KEY (product_category_name)
    REFERENCES category_translation (product_category_name)
    ON UPDATE CASCADE ON DELETE SET NULL
    NOT VALID;

-- ----------------------------------------------------------------------------
-- 6. orders
-- ----------------------------------------------------------------------------
CREATE TABLE orders (
    order_id                       VARCHAR(32) PRIMARY KEY,
    customer_id                    VARCHAR(32) NOT NULL,
    order_status                   VARCHAR(20) NOT NULL,
    order_purchase_timestamp       TIMESTAMP,
    order_approved_at              TIMESTAMP,
    order_delivered_carrier_date   TIMESTAMP,
    order_delivered_customer_date  TIMESTAMP,
    order_estimated_delivery_date  TIMESTAMP,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
    CONSTRAINT chk_order_status CHECK (order_status IN
        ('created','approved','invoiced','processing','shipped',
         'delivered','unavailable','canceled'))
);
COMMENT ON TABLE orders IS 'Pedidos. order_id es clave compartida con MongoDB (reviews).';

-- ----------------------------------------------------------------------------
-- 7. order_items  (PK compuesta: order_id + order_item_id)
-- ----------------------------------------------------------------------------
CREATE TABLE order_items (
    order_id            VARCHAR(32) NOT NULL,
    order_item_id       INTEGER     NOT NULL,
    product_id          VARCHAR(32) NOT NULL,
    seller_id           VARCHAR(32) NOT NULL,
    shipping_limit_date TIMESTAMP,
    price               NUMERIC(12,2) NOT NULL CHECK (price >= 0),
    freight_value       NUMERIC(12,2)          CHECK (freight_value >= 0),
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_items_order   FOREIGN KEY (order_id)   REFERENCES orders (order_id)   ON DELETE CASCADE,
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products (product_id),
    CONSTRAINT fk_items_seller  FOREIGN KEY (seller_id)  REFERENCES sellers (seller_id)
);
COMMENT ON TABLE order_items IS 'Líneas de pedido. Base para métricas total_sales / total_revenue de MongoDB.';

-- ----------------------------------------------------------------------------
-- 8. order_payments  (PK compuesta: order_id + payment_sequential)
-- ----------------------------------------------------------------------------
CREATE TABLE order_payments (
    order_id             VARCHAR(32) NOT NULL,
    payment_sequential   INTEGER     NOT NULL,
    payment_type         VARCHAR(20),
    payment_installments INTEGER CHECK (payment_installments >= 0),
    payment_value        NUMERIC(12,2) CHECK (payment_value >= 0),
    CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE
);
COMMENT ON TABLE order_payments IS 'Pagos por pedido (un pedido puede tener varios pagos).';

-- ----------------------------------------------------------------------------
-- 9. order_reviews
-- En Olist crudo review_id NO es estrictamente único; aquí se asume único
-- para alinear con el índice único de MongoDB (reviews.review_id) y servir
-- de fuente de verdad relacional. Caso real: deduplicar antes de cargar.
-- ----------------------------------------------------------------------------
CREATE TABLE order_reviews (
    review_id              VARCHAR(32) PRIMARY KEY,
    order_id               VARCHAR(32) NOT NULL,
    review_score           SMALLINT NOT NULL CHECK (review_score BETWEEN 1 AND 5),
    review_comment_title   VARCHAR(255),
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    CONSTRAINT fk_reviews_order FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE
);
COMMENT ON TABLE order_reviews IS 'Reseñas. review_id/order_id son claves compartidas con MongoDB (reviews).';
