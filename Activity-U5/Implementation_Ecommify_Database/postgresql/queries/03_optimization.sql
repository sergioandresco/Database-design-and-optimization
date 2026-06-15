-- ============================================================================
-- ECOMMIFY - Optimización de consultas
-- ----------------------------------------------------------------------------
-- Demuestra el efecto de los índices de schema/02_indexes.sql con
-- EXPLAIN (ANALYZE, BUFFERS). Ejecuta cada bloque y compara el plan
-- (Seq Scan vs Index Scan) y el tiempo de ejecución.
--
-- Nota: con el seed pequeño el planificador puede preferir Seq Scan por
-- tener pocas filas; el beneficio del índice se aprecia al cargar el
-- dataset Olist completo (~100k pedidos / ~112k ítems).
-- ============================================================================

-- 1) Filtro por estado de pedido -> usa idx_orders_status -------------------
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, order_purchase_timestamp
FROM orders
WHERE order_status = 'delivered';

-- 2) Rango temporal -> usa idx_orders_purchase_ts / brin --------------------
EXPLAIN (ANALYZE, BUFFERS)
SELECT date_trunc('month', order_purchase_timestamp) AS mes, COUNT(*)
FROM orders
WHERE order_purchase_timestamp >= DATE '2018-01-01'
  AND order_purchase_timestamp <  DATE '2018-06-01'
GROUP BY 1
ORDER BY 1;

-- 3) Join de reconciliación product_id -> usa idx_items_product_id ----------
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.product_id, COUNT(*) AS unidades, SUM(oi.price) AS ventas
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY ventas DESC;

-- 4) Distribución de score -> usa idx_reviews_score -------------------------
EXPLAIN (ANALYZE, BUFFERS)
SELECT review_score, COUNT(*)
FROM order_reviews
WHERE review_score <= 2
GROUP BY review_score;

-- ----------------------------------------------------------------------------
-- Índice compuesto / cubriente: acelera el agregado mensual de ventas
-- entregadas evitando tocar la tabla orders (index-only friendly).
-- ----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_orders_status_ts
    ON orders (order_status, order_purchase_timestamp);

ANALYZE orders;

EXPLAIN (ANALYZE, BUFFERS)
SELECT date_trunc('month', order_purchase_timestamp) AS mes, COUNT(*)
FROM orders
WHERE order_status = 'delivered'
GROUP BY 1
ORDER BY 1;

-- Inspección de índices existentes y su tamaño.
SELECT indexrelname AS indice, relname AS tabla,
       pg_size_pretty(pg_relation_size(indexrelid)) AS tamano
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;
