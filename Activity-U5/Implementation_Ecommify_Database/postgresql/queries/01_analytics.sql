-- ============================================================================
-- ECOMMIFY - Consultas analíticas (espejo SQL del EDA)
-- ----------------------------------------------------------------------------
-- Reproduce en SQL los análisis del notebook 01_EDA_Ecommify:
-- volumen por tabla, nulos, integridad de FKs, serie temporal, geografía,
-- scoring de reseñas y heterogeneidad del catálogo.
-- ============================================================================

-- 1) Volumen de filas por tabla (resumen de carga) --------------------------
SELECT 'customers' AS tabla, COUNT(*) AS filas FROM customers
UNION ALL SELECT 'geolocation',    COUNT(*) FROM geolocation
UNION ALL SELECT 'sellers',        COUNT(*) FROM sellers
UNION ALL SELECT 'products',       COUNT(*) FROM products
UNION ALL SELECT 'orders',         COUNT(*) FROM orders
UNION ALL SELECT 'order_items',    COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews',  COUNT(*) FROM order_reviews
ORDER BY filas DESC;

-- 2) Calidad de datos: % de nulos en columnas clave de products -------------
SELECT
    COUNT(*) AS total,
    ROUND(100.0 * COUNT(*) FILTER (WHERE product_category_name IS NULL) / COUNT(*), 2) AS pct_sin_categoria,
    ROUND(100.0 * COUNT(*) FILTER (WHERE product_weight_g       IS NULL) / COUNT(*), 2) AS pct_sin_peso,
    ROUND(100.0 * COUNT(*) FILTER (WHERE product_photos_qty     IS NULL) / COUNT(*), 2) AS pct_sin_fotos
FROM products;

-- 3) Integridad referencial: pedidos huérfanos (debe dar 0) -----------------
SELECT COUNT(*) AS items_sin_pedido
FROM order_items oi
LEFT JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL;

-- 4) Distribución temporal: pedidos por mes y estado ------------------------
SELECT
    date_trunc('month', order_purchase_timestamp) AS mes,
    order_status,
    COUNT(*) AS pedidos
FROM orders
GROUP BY 1, 2
ORDER BY 1, 2;

-- 5) Distribución geográfica: top estados de clientes y vendedores ----------
SELECT 'cliente' AS rol, customer_state AS estado, COUNT(*) AS total
FROM customers GROUP BY customer_state
UNION ALL
SELECT 'vendedor', seller_state, COUNT(*)
FROM sellers GROUP BY seller_state
ORDER BY total DESC, rol;

-- 6) Reseñas: distribución de scoring y % con comentario --------------------
SELECT
    review_score,
    COUNT(*) AS cantidad,
    ROUND(100.0 * COUNT(*) FILTER (WHERE review_comment_message IS NOT NULL) / COUNT(*), 1) AS pct_con_comentario
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

-- 7) Catálogo: heterogeneidad de atributos por categoría --------------------
SELECT
    COALESCE(p.product_category_name, '(sin categoria)') AS categoria,
    ct.product_category_name_english AS categoria_en,
    COUNT(*) AS productos,
    ROUND(AVG(p.product_photos_qty), 2) AS prom_fotos,
    ROUND(AVG(p.product_weight_g), 0)  AS prom_peso_g
FROM products p
LEFT JOIN category_translation ct ON ct.product_category_name = p.product_category_name
GROUP BY p.product_category_name, ct.product_category_name_english
ORDER BY productos DESC;

-- 8) Top productos por ingresos (price + freight) ---------------------------
SELECT
    oi.product_id,
    COUNT(*)                              AS unidades,
    ROUND(SUM(oi.price), 2)               AS ventas,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS ingresos_totales
FROM order_items oi
GROUP BY oi.product_id
ORDER BY ingresos_totales DESC;
