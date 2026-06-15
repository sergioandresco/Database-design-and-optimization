/* Ecommify MongoDB JSON Schemas */

const validators = {
  "products": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "_id",
        "product_id",
        "status",
        "created_at"
      ],
      "properties": {
        "_id": {
          "bsonType": "string"
        },
        "product_id": {
          "bsonType": "string"
        },
        "category": {
          "bsonType": "object",
          "properties": {
            "name_pt": {
              "bsonType": "string"
            },
            "name_en": {
              "bsonType": "string"
            }
          }
        },
        "specs": {
          "bsonType": "object"
        },
        "analytics": {
          "bsonType": "object"
        },
        "status": {
          "enum": [
            "active",
            "inactive"
          ]
        },
        "created_at": {
          "bsonType": "date"
        }
      }
    }
  },
  "reviews": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "_id",
        "review_id",
        "order_id",
        "score"
      ],
      "properties": {
        "_id": {
          "bsonType": "string"
        },
        "review_id": {
          "bsonType": "string"
        },
        "order_id": {
          "bsonType": "string"
        },
        "product_ids": {
          "bsonType": "array",
          "items": {
            "bsonType": "string"
          }
        },
        "score": {
          "bsonType": "int",
          "minimum": 1,
          "maximum": 5
        },
        "comment": {
          "bsonType": "object"
        },
        "created_at": {
          "bsonType": "date"
        },
        "answered_at": {
          "bsonType": "date"
        }
      }
    }
  },
  "product_catalog_view": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "_id",
        "product_id",
        "last_updated"
      ],
      "properties": {
        "_id": {
          "bsonType": "string"
        },
        "product_id": {
          "bsonType": "string"
        },
        "category": {
          "bsonType": "object"
        },
        "specs": {
          "bsonType": "object"
        },
        "metrics": {
          "bsonType": "object"
        },
        "top_sellers": {
          "bsonType": "array"
        },
        "last_updated": {
          "bsonType": "date"
        }
      }
    }
  },
  "user_behavior": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "_id",
        "customer_id",
        "session_id",
        "events"
      ],
      "properties": {
        "_id": {
          "bsonType": "string"
        },
        "customer_id": {
          "bsonType": "string"
        },
        "session_id": {
          "bsonType": "string"
        },
        "events": {
          "bsonType": "array"
        },
        "device": {
          "bsonType": "object"
        }
      }
    }
  },
  "recommendations": {
    "$jsonSchema": {
      "bsonType": "object",
      "required": [
        "_id",
        "customer_id",
        "generated_at",
        "recommendations"
      ],
      "properties": {
        "_id": {
          "bsonType": "string"
        },
        "customer_id": {
          "bsonType": "string"
        },
        "generated_at": {
          "bsonType": "date"
        },
        "recommendations": {
          "bsonType": "array"
        }
      }
    }
  }
};
