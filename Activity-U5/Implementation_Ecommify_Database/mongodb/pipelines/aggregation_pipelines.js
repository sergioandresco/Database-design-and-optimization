/* Ecommify Aggregation Pipelines */

const pipeline_catalog_by_category = [
  {
    "$match": {
      "category.name_en": "agro_industry_and_commerce"
    }
  },
  {
    "$addFields": {
      "weighted_score": {
        "$add": [
          {
            "$multiply": [
              "$metrics.avg_review_score",
              0.7
            ]
          },
          {
            "$multiply": [
              {
                "$ln": {
                  "$add": [
                    "$metrics.total_sales",
                    1
                  ]
                }
              },
              0.3
            ]
          }
        ]
      }
    }
  },
  {
    "$project": {
      "_id": 0,
      "product_id": 1,
      "category": 1,
      "metrics": 1,
      "weighted_score": 1
    }
  },
  {
    "$sort": {
      "weighted_score": -1,
      "metrics.total_sales": -1
    }
  },
  {
    "$facet": {
      "top_products": [
        {
          "$limit": 10
        }
      ],
      "summary": [
        {
          "$group": {
            "_id": "$category.name_en",
            "products": {
              "$sum": 1
            },
            "avg_review_score": {
              "$avg": "$metrics.avg_review_score"
            },
            "total_sales": {
              "$sum": "$metrics.total_sales"
            },
            "total_revenue": {
              "$sum": "$metrics.total_revenue"
            }
          }
        }
      ]
    }
  }
];

const pipeline_reviews_analysis = [
  {
    "$match": {
      "score": {
        "$gte": 1,
        "$lte": 5
      }
    }
  },
  {
    "$unwind": {
      "path": "$product_ids",
      "preserveNullAndEmptyArrays": false
    }
  },
  {
    "$group": {
      "_id": {
        "product_id": "$product_ids",
        "score": "$score"
      },
      "reviews": {
        "$sum": 1
      },
      "with_comment": {
        "$sum": {
          "$cond": [
            {
              "$ifNull": [
                "$comment.message",
                false
              ]
            },
            1,
            0
          ]
        }
      }
    }
  },
  {
    "$project": {
      "_id": 0,
      "product_id": "$_id.product_id",
      "score": "$_id.score",
      "reviews": 1,
      "with_comment": 1,
      "comment_rate": {
        "$cond": [
          {
            "$gt": [
              "$reviews",
              0
            ]
          },
          {
            "$divide": [
              "$with_comment",
              "$reviews"
            ]
          },
          0
        ]
      }
    }
  },
  {
    "$sort": {
      "reviews": -1,
      "score": 1
    }
  },
  {
    "$limit": 20
  }
];

const pipeline_top_products = [
  {
    "$match": {
      "metrics.total_sales": {
        "$gt": 0
      },
      "metrics.avg_review_score": {
        "$gt": 0
      }
    }
  },
  {
    "$addFields": {
      "quality_score": {
        "$multiply": [
          "$metrics.avg_review_score",
          {
            "$ln": {
              "$add": [
                "$metrics.total_sales",
                1
              ]
            }
          }
        ]
      }
    }
  },
  {
    "$project": {
      "_id": 0,
      "product_id": 1,
      "category.name_en": 1,
      "metrics": 1,
      "quality_score": 1
    }
  },
  {
    "$sort": {
      "quality_score": -1
    }
  },
  {
    "$facet": {
      "top_20": [
        {
          "$limit": 20
        }
      ],
      "sales_buckets": [
        {
          "$bucket": {
            "groupBy": "$metrics.total_sales",
            "boundaries": [
              0,
              1,
              5,
              10,
              25,
              50,
              100,
              500,
              10000
            ],
            "default": "other",
            "output": {
              "products": {
                "$sum": 1
              },
              "avg_review_score": {
                "$avg": "$metrics.avg_review_score"
              }
            }
          }
        }
      ]
    }
  }
];
