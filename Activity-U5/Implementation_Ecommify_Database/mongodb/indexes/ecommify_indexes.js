// Ecommify MongoDB Indexes

// Indexes for products
// SON([('v', 2), ('key', SON([('_id', 1)])), ('name', '_id_')])
// SON([('v', 2), ('key', SON([('product_id', 1)])), ('name', 'ux_products_product_id'), ('unique', True)])
// SON([('v', 2), ('key', SON([('category.name_pt', 1)])), ('name', 'idx_products_category_pt')])
// SON([('v', 2), ('key', SON([('category.name_en', 1)])), ('name', 'idx_products_category_en')])
// SON([('v', 2), ('key', SON([('analytics.avg_review_score', -1)])), ('name', 'idx_products_avg_review')])
// SON([('v', 2), ('key', SON([('specs.weight_g', 1)])), ('name', 'idx_products_weight')])
// SON([('v', 2), ('key', SON([('category.name_en', 1), ('analytics.avg_review_score', -1), ('analytics.total_sales', -1)])), ('name', 'idx_products_esr_category_score_sales')])
// SON([('v', 2), ('key', SON([('status', 1), ('category.name_en', 1)])), ('name', 'idx_products_active_category_partial'), ('partialFilterExpression', SON([('status', 'active')]))])

// Indexes for reviews
// SON([('v', 2), ('key', SON([('_id', 1)])), ('name', '_id_')])
// SON([('v', 2), ('key', SON([('review_id', 1)])), ('name', 'ux_reviews_review_id'), ('unique', True)])
// SON([('v', 2), ('key', SON([('order_id', 1)])), ('name', 'idx_reviews_order_id')])
// SON([('v', 2), ('key', SON([('product_ids', 1)])), ('name', 'idx_reviews_product_ids')])
// SON([('v', 2), ('key', SON([('score', 1)])), ('name', 'idx_reviews_score')])
// SON([('v', 2), ('key', SON([('_fts', 'text'), ('_ftsx', 1)])), ('name', 'idx_reviews_text_comment'), ('weights', SON([('comment.message', 1), ('comment.title', 1)])), ('default_language', 'english'), ('language_override', 'language'), ('textIndexVersion', 3)])
// SON([('v', 2), ('key', SON([('score', 1), ('created_at', -1)])), ('name', 'idx_reviews_with_comment_partial'), ('partialFilterExpression', SON([('comment.message', SON([('$exists', True)]))]))])

// Indexes for product_catalog_view
// SON([('v', 2), ('key', SON([('_id', 1)])), ('name', '_id_')])
// SON([('v', 2), ('key', SON([('category.name_en', 1)])), ('name', 'idx_catalog_category_en')])
// SON([('v', 2), ('key', SON([('metrics.total_sales', -1)])), ('name', 'idx_catalog_total_sales')])
// SON([('v', 2), ('key', SON([('metrics.avg_review_score', -1)])), ('name', 'idx_catalog_avg_review')])
// SON([('v', 2), ('key', SON([('category.name_en', 1), ('metrics.total_sales', -1)])), ('name', 'idx_catalog_category_sales')])

// Indexes for user_behavior
// SON([('v', 2), ('key', SON([('_id', 1)])), ('name', '_id_')])
// SON([('v', 2), ('key', SON([('customer_id', 1)])), ('name', 'idx_behavior_customer')])
// SON([('v', 2), ('key', SON([('events.product_id', 1)])), ('name', 'idx_behavior_product')])
// SON([('v', 2), ('key', SON([('events.timestamp', -1)])), ('name', 'idx_behavior_event_time')])

// Indexes for recommendations
// SON([('v', 2), ('key', SON([('_id', 1)])), ('name', '_id_')])
// SON([('v', 2), ('key', SON([('customer_id', 1)])), ('name', 'idx_recommendations_customer')])
// SON([('v', 2), ('key', SON([('recommendations.product_id', 1)])), ('name', 'idx_recommendations_product')])
// SON([('v', 2), ('key', SON([('generated_at', -1)])), ('name', 'idx_recommendations_generated')])

