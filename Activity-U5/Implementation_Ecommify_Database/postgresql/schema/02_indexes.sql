-- ============================================================================
-- ECOMMIFY - Índices de optimización (PostgreSQL / Supabase)
-- ----------------------------------------------------------------------------
-- Etapa de optimización: índices secundarios alineados con los patrones de
-- consulta del EDA (notebooks/01) y de las métricas que alimentan MongoDB.
-- Las PK y los UNIQUE ya generan índices automáticamente; aquí se cubren
-- únicamente los accesos por columnas NO clave.
-- ============================================================================

-- --- orders: filtros por cliente, estado y rango temporal (serie mensual) ---
CREATE INDEX IF NOT EXISTS idx_orders_customer_id        ON orders (customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status             ON orders (order_status);
CREATE INDEX IF NOT EXISTS idx_orders_purchase_ts        ON orders (order_purchase_timestamp);
-- BRIN: alternativa de bajo costo para grandes volúmenes ordenados por fecha.
CREATE INDEX IF NOT EXISTS brin_orders_purchase_ts       ON orders USING brin (order_purchase_timestamp);

-- --- order_items: joins de reconciliación con MongoDB (product_id) ---
CREATE INDEX IF NOT EXISTS idx_items_product_id          ON order_items (product_id);
CREATE INDEX IF NOT EXISTS idx_items_seller_id           ON order_items (seller_id);
-- order_id ya está cubierto por la PK compuesta (order_id, order_item_id).

-- --- order_payments ---
-- order_id ya cubierto por la PK compuesta (order_id, payment_sequential).
CREATE INDEX IF NOT EXISTS idx_payments_type             ON order_payments (payment_type);

-- --- order_reviews: distribución de score y join por order_id ---
CREATE INDEX IF NOT EXISTS idx_reviews_order_id          ON order_reviews (order_id);
CREATE INDEX IF NOT EXISTS idx_reviews_score             ON order_reviews (review_score);

-- --- products: agrupaciones por categoría (catálogo MongoDB) ---
CREATE INDEX IF NOT EXISTS idx_products_category         ON products (product_category_name);

-- --- customers / sellers: distribución geográfica del EDA ---
CREATE INDEX IF NOT EXISTS idx_customers_state           ON customers (customer_state);
CREATE INDEX IF NOT EXISTS idx_customers_zip             ON customers (customer_zip_code_prefix);
CREATE INDEX IF NOT EXISTS idx_sellers_state             ON sellers (seller_state);

-- --- geolocation: búsqueda por prefijo de ZIP ---
CREATE INDEX IF NOT EXISTS idx_geo_zip                   ON geolocation (geolocation_zip_code_prefix);

-- Refresca estadísticas del planificador tras crear índices y cargar datos.
ANALYZE;
