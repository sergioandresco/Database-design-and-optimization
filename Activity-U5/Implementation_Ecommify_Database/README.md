# Ecommify — Diseño y Optimización de Bases de Datos (Actividad U2)

Diseño de una **arquitectura de datos híbrida** para la empresa ficticia *Ecommify*, a partir del dataset público **Brazilian E-commerce (Olist)** (9 tablas).

- **PostgreSQL / Supabase** → núcleo transaccional (clientes, pedidos, pagos, catálogo relacional).
- **MongoDB Atlas** → capa documental flexible (catálogo enriquecido, reseñas, vistas desnormalizadas, comportamiento y recomendaciones).

Las claves `product_id`, `order_id` y `customer_id` son **claves compartidas** entre ambos motores y permiten la reconciliación entre la capa relacional y la documental.

## Estructura del proyecto

```
Ecommify_Database_Design/
├── notebooks/
│   ├── 01_EDA_Ecommify.ipynb          # Análisis exploratorio de las 9 tablas Olist
│   └── 02_MongoDB_Atlas_Ecommify.ipynb # Implementación de la capa documental en Atlas
├── mongodb/
│   └── schema/
│       └── ecommify_mongodb_schemas.txt # Validadores JSON Schema + índices
├── postgresql/
│   ├── schema/
│   │   ├── 01_create_tables.sql        # Tablas, PKs, FKs, CHECKs, comentarios
│   │   └── 02_indexes.sql              # Índices de optimización (B-tree, BRIN, compuestos)
│   ├── seed_data/
│   │   └── 01_seed_data.sql            # Datos de prueba referencialmente íntegros
│   └── queries/
│       ├── 01_analytics.sql            # Consultas analíticas (espejo SQL del EDA)
│       ├── 02_metrics_mongodb.sql      # Métricas que alimentan los documentos Mongo (M2/M4)
│       └── 03_optimization.sql         # EXPLAIN ANALYZE y demostración de índices
└── docs/
```

## Modelo relacional (PostgreSQL)

9 tablas que reproducen el modelo Olist:

| Tabla | Clave primaria | Relaciones |
|---|---|---|
| `customers` | `customer_id` | — |
| `sellers` | `seller_id` | — |
| `geolocation` | `geolocation_id` (surrogate) | referencia geográfica por prefijo de ZIP |
| `category_translation` | `product_category_name` | — |
| `products` | `product_id` | → `category_translation` |
| `orders` | `order_id` | → `customers` |
| `order_items` | `(order_id, order_item_id)` | → `orders`, `products`, `sellers` |
| `order_payments` | `(order_id, payment_sequential)` | → `orders` |
| `order_reviews` | `review_id` | → `orders` |

### Decisiones de diseño

- **PKs compuestas** en `order_items` y `order_payments` (un pedido tiene varias líneas y varios pagos).
- **`CHECK`**: `review_score` ∈ [1,5], estados de orden válidos, importes ≥ 0.
- **FK de categoría como `NOT VALID`**: permite cargar el Olist crudo (con categorías huérfanas) sin fallar, validando solo las filas nuevas.
- **`geolocation`** usa PK surrogate porque el prefijo de ZIP no es único en Olist.
- El **orden de columnas coincide con los CSV** de Olist para permitir carga directa con `COPY`.

## Cómo ejecutar

Orden de carga (psql o el editor SQL de Supabase):

```bash
psql -d ecommify -f postgresql/schema/01_create_tables.sql
psql -d ecommify -f postgresql/schema/02_indexes.sql
psql -d ecommify -f postgresql/seed_data/01_seed_data.sql      # datos de prueba
# o, para el dataset real:
#   \copy customers FROM 'olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true);
```

Luego las consultas:

```bash
psql -d ecommify -f postgresql/queries/01_analytics.sql
psql -d ecommify -f postgresql/queries/02_metrics_mongodb.sql
psql -d ecommify -f postgresql/queries/03_optimization.sql
```

El SQL fue validado contra **PostgreSQL 16** (todos los scripts ejecutan sin errores; la reconciliación M4 de claves devuelve 0 huérfanos sobre el seed).

## Capa documental (MongoDB Atlas)

Implementada en `notebooks/02_MongoDB_Atlas_Ecommify.ipynb`. Colecciones: `products`, `reviews`, `product_catalog_view`, `user_behavior`, `recommendations`. Patrones aplicados: *Embedding*, *Referencing*, *Computed Pattern* y *Subset Pattern* (para respetar el límite de Atlas M0). Las métricas embebidas (`total_sales`, `total_revenue`, `avg_review_score`) se calculan desde PostgreSQL en `queries/02_metrics_mongodb.sql`.

## Dataset

Brazilian E-commerce Public Dataset by Olist (Kaggle) — 9 archivos CSV. En los notebooks se carga desde Google Drive (`/content/drive/MyDrive/Ecommify/data`).
