"""
validate_mongodb_atlas.py

Valida conexión a MongoDB Atlas, colecciones, conteos e índices.
"""

import os
from dotenv import load_dotenv
import json
from pathlib import Path
from datetime import datetime, timezone

from pymongo import MongoClient

# Load variables from the .env file into the system environment
load_dotenv()

ROOT_DIR = Path(__file__).resolve().parents[2]
EVIDENCE_DIR = ROOT_DIR / "evidences" / "mongodb"

DB_NAME = "ecommify_mongodb"
COLLECTIONS = [
    "products",
    "reviews",
    "product_catalog_view",
    "user_behavior",
    "recommendations",
]

def get_client() -> MongoClient:
    mongodb_uri = os.getenv("MONGODB_URI")
    if not mongodb_uri:
        raise ValueError("MONGODB_URI environment variable is required.")
    return MongoClient(mongodb_uri, serverSelectionTimeoutMS=30000)

def summarize_collection(db, collection_name: str) -> dict:
    collection = db[collection_name]
    return {
        "collection": collection_name,
        "documents": collection.count_documents({}),
        "indexes": [
            {
                "name": index.get("name"),
                "key": dict(index.get("key", {})),
                "unique": index.get("unique", False),
            }
            for index in collection.list_indexes()
        ],
        "sample_document": collection.find_one({}, {"_id": 0}),
    }

def main() -> int:
    EVIDENCE_DIR.mkdir(parents=True, exist_ok=True)

    client = get_client()
    client.admin.command("ping")
    db = client[DB_NAME]

    summary = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "database": DB_NAME,
        "collections": {},
    }

    for collection_name in COLLECTIONS:
        print(f"Validating collection: {collection_name}")
        summary["collections"][collection_name] = summarize_collection(db, collection_name)

    output_path = EVIDENCE_DIR / "mongodb_collections_summary.json"
    output_path.write_text(json.dumps(summary, indent=2, default=str, ensure_ascii=False), encoding="utf-8")

    print(f"MongoDB summary written to: {output_path}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
