# Performance Summary — Ecommify

## 1. Objetivo de pruebas

Consolidar las evidencias de rendimiento para la implementación MongoDB Atlas y PostgreSQL/Supabase del proyecto Ecommify.

Este documento resume las métricas generadas automáticamente por los scripts de evidencia y establece la ubicación de los resultados.

## 2. Metodología

Las pruebas se enfocan en:

1. Validación de ejecución de scripts SQL.
2. Validación de conexión a MongoDB Atlas.
3. Conteo de documentos por colección.
4. Listado de índices creados.
5. Ejecución de consultas optimizadas.
6. Extracción de métricas mediante `explain("executionStats")`.

## 3. Queries MongoDB evaluadas

### Query 1 — Productos por categoría

Ordena productos por:

- `analytics.avg_review_score`
- `analytics.total_sales`

### Query 2 — Reviews negativas con comentario

Filtra reseñas con:

- `score <= 2`
- existencia de `comment.message`

### Query 3 — Product Catalog View por ventas

Ordena documentos por:

- `metrics.total_sales`

## 4. Métricas utilizadas

| Métrica | Descripción |
|---|---|
| executionTimeMillis | Tiempo de ejecución reportado por MongoDB |
| totalDocsExamined | Total de documentos examinados |
| totalKeysExamined | Total de llaves de índice examinadas |
| nReturned | Número de documentos retornados |
| efficiencyRatio | totalDocsExamined / nReturned |

## 5. Tabla de resultados

Los resultados consolidados se generan automáticamente en:

```text
results/consolidated_test_results.csv
results/mongodb_explain_summary.json
```

## 📊 Resultados de Rendimiento MongoDB

| Query | Execution Time (ms) | Docs Examined | Keys Examined | Documents Returned | Efficiency Ratio |
|--------|-------------------:|--------------:|--------------:|-------------------:|----------------:|
| products_by_category_score_sales | 151 | 32,951 | 32,951 | 20 | 1,647.55 |
| negative_reviews_with_comment | 0 | 20 | 20 | 20 | 1.00 |
| catalog_top_sales | 0 | 21 | 21 | 20 | 1.05 |

### Interpretación

- **products_by_category_score_sales** presenta el mayor costo de ejecución debido al volumen de documentos examinados (32.951), evidenciando una oportunidad de optimización adicional mediante índices más selectivos o refinamiento de la consulta.
- **negative_reviews_with_comment** muestra un comportamiento altamente eficiente, examinando únicamente los documentos necesarios para retornar los resultados.
- **catalog_top_sales** presenta una eficiencia cercana al óptimo, utilizando correctamente los índices definidos sobre la colección `product_catalog_view`.
- El **Efficiency Ratio** representa la relación entre documentos examinados y documentos retornados. Valores cercanos a **1** indican consultas altamente eficientes. 


## 6. Evidencias generadas

Las evidencias se almacenan en:

```text
evidences/mongodb/
evidences/postgresql/
evidences/explain_results/
evidences/performance_graphs/
```

## 7. Interpretación esperada

La optimización debe reflejar:

- menor cantidad de documentos examinados,
- uso de índices,
- menor tiempo de ejecución,
- mejor relación entre documentos examinados y documentos retornados.
