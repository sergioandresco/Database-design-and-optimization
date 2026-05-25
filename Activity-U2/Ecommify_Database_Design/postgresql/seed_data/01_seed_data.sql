-- ============================================================================
-- ECOMMIFY - Datos de prueba (seed) coherentes
-- ----------------------------------------------------------------------------
-- Subconjunto sintético, pero referencialmente íntegro, del modelo Olist.
-- Sirve para validar el esquema, los índices y todas las queries de la
-- carpeta queries/ sin necesidad de descargar el dataset completo.
--
-- Carga (psql / Supabase SQL editor) en orden:
--   1) schema/01_create_tables.sql
--   2) schema/02_indexes.sql
--   3) seed_data/01_seed_data.sql
--
-- Para cargar el dataset Olist real en su lugar, usar COPY, p.ej.:
--   \copy customers FROM 'olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true);
-- (el header se mapea por posición; el orden de columnas coincide con el CSV).
-- ============================================================================

BEGIN;

-- Reinicia datos previos respetando dependencias.
TRUNCATE order_reviews, order_payments, order_items, orders,
         products, category_translation, sellers, customers, geolocation
         RESTART IDENTITY CASCADE;

-- --- geolocation ------------------------------------------------------------
INSERT INTO geolocation
    (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state) VALUES
    (1001, -23.55, -46.63, 'sao paulo',      'SP'),
    (20010, -22.90, -43.20, 'rio de janeiro', 'RJ'),
    (30110, -19.92, -43.94, 'belo horizonte', 'MG'),
    (13010, -22.90, -47.06, 'campinas',       'SP'),
    (90010, -30.03, -51.23, 'porto alegre',   'RS'),
    (40010, -12.97, -38.51, 'salvador',       'BA'),
    (4500,  -23.61, -46.66, 'sao paulo',      'SP'),
    (22011, -22.96, -43.18, 'rio de janeiro', 'RJ'),
    (80010, -25.43, -49.27, 'curitiba',       'PR'),
    (1310,  -23.56, -46.65, 'sao paulo',      'SP'),
    (31010, -19.86, -43.95, 'belo horizonte', 'MG');

-- --- customers --------------------------------------------------------------
INSERT INTO customers
    (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state) VALUES
    ('c001', 'u001', 1001,  'sao paulo',      'SP'),
    ('c002', 'u002', 20010, 'rio de janeiro', 'RJ'),
    ('c003', 'u003', 30110, 'belo horizonte', 'MG'),
    ('c004', 'u004', 13010, 'campinas',       'SP'),
    ('c005', 'u005', 90010, 'porto alegre',   'RS'),
    ('c006', 'u006', 40010, 'salvador',       'BA');

-- --- sellers ----------------------------------------------------------------
INSERT INTO sellers
    (seller_id, seller_zip_code_prefix, seller_city, seller_state) VALUES
    ('s001', 4500,  'sao paulo',      'SP'),
    ('s002', 22011, 'rio de janeiro', 'RJ'),
    ('s003', 80010, 'curitiba',       'PR'),
    ('s004', 1310,  'sao paulo',      'SP'),
    ('s005', 31010, 'belo horizonte', 'MG');

-- --- category_translation ---------------------------------------------------
INSERT INTO category_translation
    (product_category_name, product_category_name_english) VALUES
    ('beleza_saude',            'health_beauty'),
    ('informatica_acessorios',  'computers_accessories'),
    ('cama_mesa_banho',         'bed_bath_table'),
    ('esporte_lazer',           'sports_leisure'),
    ('relogios_presentes',      'watches_gifts');

-- --- products (p008 sin categoría: caso real de catálogo) --------------------
INSERT INTO products
    (product_id, product_category_name, product_name_length, product_description_length,
     product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm) VALUES
    ('p001', 'beleza_saude',           45, 320, 3,  300, 20, 10, 15),
    ('p002', 'informatica_acessorios', 52, 540, 5,  800, 30, 12, 20),
    ('p003', 'cama_mesa_banho',        38, 210, 2, 1500, 40, 15, 35),
    ('p004', 'esporte_lazer',          60, 410, 4,  950, 50, 25, 30),
    ('p005', 'relogios_presentes',     33, 180, 6,  200, 12,  8, 10),
    ('p006', 'informatica_acessorios', 48, 500, 4,  650, 28, 11, 18),
    ('p007', 'beleza_saude',           41, 260, 2,  150, 10,  6,  8),
    ('p008', NULL,                     NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --- orders -----------------------------------------------------------------
INSERT INTO orders
    (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at,
     order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date) VALUES
    ('o001', 'c001', 'delivered', '2017-09-05 10:15:00', '2017-09-05 10:40:00', '2017-09-06 08:00:00', '2017-09-12 16:30:00', '2017-09-18 00:00:00'),
    ('o002', 'c002', 'delivered', '2017-11-20 14:05:00', '2017-11-20 14:20:00', '2017-11-21 09:00:00', '2017-11-28 11:00:00', '2017-12-02 00:00:00'),
    ('o003', 'c003', 'delivered', '2018-01-15 09:30:00', '2018-01-15 09:55:00', '2018-01-16 07:30:00', '2018-01-22 13:45:00', '2018-01-26 00:00:00'),
    ('o004', 'c004', 'shipped',   '2018-02-10 18:45:00', '2018-02-10 19:10:00', '2018-02-11 10:00:00', NULL,                  '2018-02-20 00:00:00'),
    ('o005', 'c005', 'delivered', '2018-03-22 11:20:00', '2018-03-22 11:35:00', '2018-03-23 08:15:00', '2018-03-30 17:00:00', '2018-04-03 00:00:00'),
    ('o006', 'c006', 'canceled',  '2018-04-01 16:00:00', NULL,                  NULL,                  NULL,                  '2018-04-12 00:00:00'),
    ('o007', 'c001', 'delivered', '2018-05-18 08:10:00', '2018-05-18 08:30:00', '2018-05-19 09:00:00', '2018-05-25 15:20:00', '2018-05-29 00:00:00');

-- --- order_items ------------------------------------------------------------
INSERT INTO order_items
    (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value) VALUES
    ('o001', 1, 'p001', 's001', '2017-09-08 10:15:00', 59.90, 12.30),
    ('o001', 2, 'p002', 's002', '2017-09-08 10:15:00', 89.00, 15.00),
    ('o002', 1, 'p003', 's003', '2017-11-23 14:05:00', 120.00, 20.00),
    ('o003', 1, 'p004', 's004', '2018-01-18 09:30:00', 45.50, 9.90),
    ('o004', 1, 'p005', 's005', '2018-02-13 18:45:00', 230.00, 25.00),
    ('o005', 1, 'p006', 's002', '2018-03-25 11:20:00', 89.00, 14.00),
    ('o005', 2, 'p001', 's001', '2018-03-25 11:20:00', 59.90, 12.30),
    ('o006', 1, 'p007', 's001', '2018-04-04 16:00:00', 35.00, 8.00),
    ('o007', 1, 'p002', 's002', '2018-05-21 08:10:00', 89.00, 15.00),
    ('o007', 2, 'p008', 's003', '2018-05-21 08:10:00', 19.90, 7.00);

-- --- order_payments (o005 con pago dividido) --------------------------------
INSERT INTO order_payments
    (order_id, payment_sequential, payment_type, payment_installments, payment_value) VALUES
    ('o001', 1, 'credit_card', 3, 176.20),
    ('o002', 1, 'boleto',      1, 140.00),
    ('o003', 1, 'credit_card', 2, 55.40),
    ('o004', 1, 'credit_card', 4, 255.00),
    ('o005', 1, 'voucher',     1, 50.00),
    ('o005', 2, 'credit_card', 3, 125.20),
    ('o006', 1, 'credit_card', 1, 43.00),
    ('o007', 1, 'credit_card', 3, 130.90);

-- --- order_reviews ----------------------------------------------------------
INSERT INTO order_reviews
    (review_id, order_id, review_score, review_comment_title, review_comment_message,
     review_creation_date, review_answer_timestamp) VALUES
    ('r001', 'o001', 5, 'Excelente',   'Produto chegou antes do prazo.',        '2017-09-13 00:00:00', '2017-09-14 10:00:00'),
    ('r002', 'o002', 4, NULL,          NULL,                                    '2017-11-29 00:00:00', '2017-11-30 09:30:00'),
    ('r003', 'o003', 5, 'Recomendo',   'Tudo certo, embalagem perfeita.',       '2018-01-23 00:00:00', '2018-01-24 12:00:00'),
    ('r004', 'o004', 3, NULL,          'Demorou um pouco para enviar.',         '2018-02-21 00:00:00', '2018-02-22 08:00:00'),
    ('r005', 'o005', 2, 'Regular',     'Um item veio com a caixa amassada.',    '2018-03-31 00:00:00', '2018-04-01 14:00:00'),
    ('r006', 'o006', 1, 'Cancelado',   'Pedido cancelado, nao recebi.',         '2018-04-13 00:00:00', '2018-04-14 09:00:00'),
    ('r007', 'o007', 4, NULL,          NULL,                                    '2018-05-26 00:00:00', '2018-05-27 10:30:00');

COMMIT;

-- Verificación rápida de carga.
SELECT 'customers' AS tabla, COUNT(*) FROM customers
UNION ALL SELECT 'sellers',        COUNT(*) FROM sellers
UNION ALL SELECT 'products',       COUNT(*) FROM products
UNION ALL SELECT 'orders',         COUNT(*) FROM orders
UNION ALL SELECT 'order_items',    COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews',  COUNT(*) FROM order_reviews
ORDER BY tabla;
