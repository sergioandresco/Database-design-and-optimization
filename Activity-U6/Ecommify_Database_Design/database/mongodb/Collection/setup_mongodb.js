// setup_mongodb.js
// Ecommify MongoDB setup script.
// Can be executed from mongosh or MongoDB Atlas UI.

use("ecommify_mongodb");

// ============================================================
// Collections
// ============================================================

const collections = [
  "products",
  "reviews",
  "product_catalog_view",
  "user_behavior",
  "recommendations"
];

collections.forEach(function(collectionName) {
  if (!db.getCollectionNames().includes(collectionName)) {
    db.createCollection(collectionName);
    print("Created collection: " + collectionName);
  } else {
    print("Collection already exists: " + collectionName);
  }
});

// ============================================================
// Products indexes
// ============================================================

db.products.createIndex(
  { product_id: 1 },
  { unique: true, name: "ux_products_product_id" }
);

db.products.createIndex(
  { "category.name_en": 1 },
  { name: "idx_products_category_en" }
);

db.products.createIndex(
  {
    "category.name_en": 1,
    "analytics.avg_review_score": -1,
    "analytics.total_sales": -1
  },
  { name: "idx_products_esr_category_score_sales" }
);

// ============================================================
// Reviews indexes
// ============================================================

db.reviews.createIndex(
  { review_id: 1 },
  { unique: true, name: "ux_reviews_review_id" }
);

db.reviews.createIndex(
  { order_id: 1 },
  { name: "idx_reviews_order_id" }
);

db.reviews.createIndex(
  { score: 1 },
  { name: "idx_reviews_score" }
);

db.reviews.createIndex(
  { "comment.title": "text", "comment.message": "text" },
  { name: "idx_reviews_text_comment" }
);

// ============================================================
// Product Catalog View indexes
// ============================================================

db.product_catalog_view.createIndex(
  { "category.name_en": 1 },
  { name: "idx_catalog_category_en" }
);

db.product_catalog_view.createIndex(
  { "metrics.total_sales": -1 },
  { name: "idx_catalog_total_sales" }
);

db.product_catalog_view.createIndex(
  { "category.name_en": 1, "metrics.total_sales": -1 },
  { name: "idx_catalog_category_sales" }
);

// ============================================================
// User Behavior indexes
// ============================================================

db.user_behavior.createIndex(
  { customer_id: 1 },
  { name: "idx_behavior_customer" }
);

db.user_behavior.createIndex(
  { "events.product_id": 1 },
  { name: "idx_behavior_product" }
);

// ============================================================
// Recommendations indexes
// ============================================================

db.recommendations.createIndex(
  { customer_id: 1 },
  { name: "idx_recommendations_customer" }
);

db.recommendations.createIndex(
  { "recommendations.product_id": 1 },
  { name: "idx_recommendations_product" }
);

print("MongoDB setup completed successfully.");
