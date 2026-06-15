// Ecommify Optimized Queries

db.products.find({ "category.name_en": "agro_industry_and_commerce", status: "active" }).sort({ "analytics.avg_review_score": -1, "analytics.total_sales": -1 }).limit(20);

db.reviews.find({ score: { $lte: 2 }, "comment.message": { $exists: true } }).sort({ created_at: -1 }).limit(20);

db.product_catalog_view.find({ "category.name_en": "agro_industry_and_commerce" }).sort({ "metrics.total_sales": -1 }).limit(20);
