🚀 Ecommify — Database Design and Optimization
Diseño, Implementación y Optimización de una Arquitectura Híbrida PostgreSQL + MongoDB para E-commerce
Universidad de La Sabana

Facultad de Ingeniería – Ingeniería de Sistemas

Asignatura: Diseño y Optimización de Bases de Datos

Proyecto Final: Ecommify

Integrantes

Juan José Vélez Álvarez
Juan Sebastián Buitrago Romero
Sergio Andrés Cobos Suárez
David Aníbal Vásquez Beltrán
📌 Descripción del Proyecto

Ecommify es un proyecto académico que aborda el diseño, implementación y optimización de una arquitectura de bases de datos para un entorno de comercio electrónico basado en el dataset Olist.

El proyecto parte de un análisis exploratorio de datos (EDA) para identificar la naturaleza, calidad y comportamiento de las entidades principales del negocio. A partir de estos hallazgos se diseña una arquitectura híbrida que combina PostgreSQL y MongoDB para aprovechar las fortalezas de ambos paradigmas.

La solución implementada busca responder a necesidades transaccionales, analíticas y de escalabilidad, manteniendo consistencia donde es necesaria y flexibilidad donde aporta valor.

🎯 Objetivos
Objetivo General

Diseñar e implementar una arquitectura híbrida de bases de datos que combine PostgreSQL y MongoDB para soportar las necesidades operativas y analíticas de una plataforma de comercio electrónico.

Objetivos Específicos
Analizar la calidad y estructura del dataset Ecommify.
Diseñar un modelo relacional normalizado para entidades transaccionales.
Diseñar colecciones documentales optimizadas para MongoDB.
Implementar índices y estrategias de optimización.
Evaluar rendimiento mediante métricas cuantitativas.
Analizar decisiones arquitectónicas utilizando el Teorema CAP.
Documentar una solución reproducible y escalable.

🏗 Arquitectura Implementada
El proyecto adopta una arquitectura híbrida o políglota.
PostgreSQL (Supabase)
PostgreSQL funciona como sistema OLTP y fuente principal de verdad.
Entidades gestionadas
Customers
Orders
Order Items
Order Payments
Sellers
Geolocation
Category Translation
Razones de selección
Integridad referencial
Consistencia fuerte
Restricciones y constraints
Transacciones ACID
Modelo normalizado

MongoDB Atlas
MongoDB funciona como capa documental y analítica.
Colecciones implementadas
Products
Reviews
Product Catalog View
User Behavior
Recommendations
Razones de selección
Catálogo heterogéneo
Comentarios opcionales
Consultas flexibles
Agregaciones rápidas
Recomendaciones precalculadas

📊 Hallazgos del EDA
El análisis exploratorio identificó:
32.951 productos.
73 categorías distintas.
Más de 99.000 reseñas.
Más de 100.000 pedidos.
Más de 1 millón de registros geográficos.
Hallazgos clave
Productos con estructuras heterogéneas.
Reseñas con texto opcional.
Alta consistencia relacional.
Concentración geográfica en São Paulo.
Necesidad de separar cargas transaccionales y analíticas.

🗄 Implementación PostgreSQL
La implementación relacional incluye:
Características
Modelo normalizado hasta 3FN.
Claves primarias y foráneas.
Constraints de negocio.
Índices especializados.
Particionamiento temporal.
Scripts DDL reproducibles.
Optimizaciones
Índices B-Tree.
Índices compuestos.
EXPLAIN ANALYZE.
Particionamiento por fecha.

🍃 Implementación MongoDB
La implementación documental incluye:
Modelado
JSON Schema Validation.
Attribute Pattern.
Computed Pattern.
Subset Pattern.
Extended Reference Pattern.
Índices
Simples.
Compuestos.
Parciales.
Full Text Search.
Aggregation Pipelines
Catálogo por categoría.
Análisis de reseñas.
Productos más vendidos.
Métricas agregadas.

⚡ Optimización de Rendimiento
PostgreSQL
Se optimizaron consultas utilizando:
Índices especializados.
Particionamiento.
EXPLAIN ANALYZE.
MongoDB
Se optimizaron consultas mediante:
Índices compuestos siguiendo la regla ESR.
Índices parciales.
Índices de texto.
Aggregation Pipelines optimizados.
Explain Execution Stats.
Métricas evaluadas
executionTimeMillis
totalDocsExamined
totalKeysExamined
nReturned
Efficiency Ratio

🔀 Escalabilidad
Replica Sets
Configuración teórica:
1 Primary
2 Secondary
Estrategias implementadas
Read Preference
Write Concern
Consistencia eventual

Sharding
Shard Key propuesta
{
  "category.name_en": 1,
  "_id": "hashed"
}

Beneficios
Distribución uniforme.
Menor riesgo de hotspots.
Consultas eficientes por categoría.

📁 Estructura del Repositorio
Ecommify_Database_Design/
│
├── README.md
│
├── database/
│   ├── mongodb/
│   ├── postgresql/  
│
├── diagrams/
│
├── docs/
│
├── notebooks/
│   ├── 01_EDA_Ecommify.ipynb
│   ├── 02_MongoDB_Atlas_Ecommify.ipynb
│   └── 03_MongoDB_Ecommify_Entregable2_U5.ipynb
│
├── presentation/
│ 
├── scripts/
│   ├── results/
│   ├── evidences/
│   └── setup/



▶ Cómo Reproducir el Proyecto
Requisitos
Python 3.10+
Google Colab
MongoDB Atlas
Supabase
Git

Clonar Repositorio
git clone https://github.com/sergioandresco/Database-design-and-optimization.git

cd Activity-U6/Ecommify_Database_Design

Instalar Dependencias
bash scripts/setup/install_requirements.sh

Ejecutar Notebooks
Orden recomendado:
- 01_EDA_Ecommify.ipynb
- 02_MongoDB_Atlas_Ecommify.ipynb
- 03_MongoDB_Ecommify_Entregable2_U5.ipynb

Ejecucion scripts
1) Modificar archivo .env con sus credenciales de Postgresql y MongoDB
    Nota: Se requiere la cadena de conexión de python para la propiedad MONGODB_URI

2) Ejecutar validate_environment.py
3) Ejecutar run_postgresql_scripts.py
4) Ejecutar validate_mongodb_atlas.py
5) Ejecutar generate_performance_evidences.py

📈 Resultados Obtenidos
PostgreSQL
Modelo normalizado.
Integridad referencial validada.
Optimización mediante índices.
Particionamiento implementado.
MongoDB
Colecciones documentales optimizadas.
JSON Schema Validation.
Índices especializados.
Aggregation Pipelines eficientes.
Explain Execution Stats documentado.
Arquitectura
Separación clara de responsabilidades.
Escalabilidad futura documentada.
Estrategia híbrida validada.

📚 Documentación
La documentación completa se encuentra en:
docs/

Incluye:
Informe final

🔗 Repositorio
GitHub:
https://github.com/sergioandresco/Database-design-and-optimization

📖 Referencias
MongoDB Documentation
PostgreSQL Documentation
Supabase Documentation
MongoDB Atlas Documentation
Olist E-commerce Dataset
Material académico de Diseño y Optimización de Bases de Datos

✅ Estado del Proyecto
Proyecto Finalizado
Versión Académica — Arquitectura Híbrida PostgreSQL + MongoDB
Universidad de La Sabana
