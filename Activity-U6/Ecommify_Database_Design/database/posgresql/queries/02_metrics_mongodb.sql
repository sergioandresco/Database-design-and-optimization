-- ============================================================================
-- ECOMMIFY - Métricas que alimentan la capa documental (MongoDB Atlas)
-- ----------------------------------------------------------------------------
-- Estas consultas calculan, desde el núcleo transaccional, los campos que el
-- notebook 02_MongoDB_Atlas embebe en los documentos (Computed Pattern):
--   products.analytics / product_catalog_view.metrics:
--       total_sales, total_revenue, avg_review_score
-- y validan las métricas de control M2 (almacenamiento) y M4 (reconciliación
-- de claves order_items.product_id <-> products.product_id).
-- ============================================================================

-- --- Computed Pattern: métricas por producto para product_catalog_view -----
-- avg_review_score se aproxima vía las reseñas de los pedidos que contienen
-- cada producto (el score de Olist es a nivel pedido, no de ítem).
WITH ventas AS (
    SELECT
        product_id,
        COUNT(*)                               AS total_sales,
        SUM(price + freight_value)             AS total_revenue
    FROM order_items
    GROUP BY product_id
),
scores AS (
    SELECT
        oi.product_id,
        AVG(orw.review_score)::NUMERIC(4,2)    AS avg_review_score,
        COUNT(orw.review_id)                   AS review_count
    FROM order_items oi
    JOIN order_reviews orw ON orw.order_id = oi.order_id
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.product_category_name,
    COALESCE(v.total_sales, 0)            AS total_sales,
    ROUND(COALESCE(v.total_revenue, 0),2) AS total_revenue,
    s.avg_review_score,
    COALESCE(s.review_count, 0)           AS review_count
FROM products p
LEFT JOIN ventas  v ON v.product_id = p.product_id
LEFT JOIN scores  s ON s.product_id = p.product_id
ORDER BY total_revenue DESC;

-- --- Documento reviews: forma previa a la carga en MongoDB -----------------
-- product_ids es el array de productos del pedido reseñado (claves compartidas).
SELECT
    orw.review_id,
    orw.order_id,
    array_agg(DISTINCT oi.product_id) AS product_ids,
    orw.review_score                  AS score,
    orw.review_comment_message        AS comment,
    orw.review_creation_date          AS created_at,
    orw.review_answer_timestamp       AS answered_at
FROM order_reviews orw
LEFT JOIN order_items oi ON oi.order_id = orw.order_id
GROUP BY orw.review_id, orw.order_id, orw.review_score,
         orw.review_comment_message, orw.review_creation_date, orw.review_answer_timestamp
ORDER BY orw.review_id;

-- --- Métrica M2: estimación de tamaño de las tablas (planeación Atlas M0) ---
SELECT
    relname                                   AS tabla,
    to_char(reltuples, 'FM999G999G999')       AS filas_estimadas,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS tamano_total
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relkind = 'r'
ORDER BY pg_total_relation_size(c.oid) DESC;

-- --- Métrica M4: reconciliación de claves PostgreSQL <-> MongoDB -----------
-- Todo product_id vendido debe existir en el catálogo (huérfanos = 0).
SELECT COUNT(DISTINCT oi.product_id) AS product_ids_huerfanos
FROM order_items oi
LEFT JOIN products p ON p.product_id = oi.product_id
WHERE p.product_id IS NULL;

-- Cobertura: cuántos productos del catálogo se han vendido al menos una vez.
SELECT
    COUNT(*)                                              AS productos_catalogo,
    COUNT(*) FILTER (WHERE oi.product_id IS NOT NULL)     AS productos_con_ventas,
    ROUND(100.0 * COUNT(*) FILTER (WHERE oi.product_id IS NOT NULL) / COUNT(*), 1) AS pct_con_ventas
FROM products p
LEFT JOIN (SELECT DISTINCT product_id FROM order_items) oi
       ON oi.product_id = p.product_id;
