"""
generate_performance_evidences.py

Ejecuta queries optimizadas en MongoDB, extrae explain executionStats y genera evidencias.
"""

import os
from dotenv import load_dotenv
import json
from pathlib import Path
from datetime import datetime, timezone

import pandas as pd
import matplotlib.pyplot as plt
from pymongo import MongoClient, DESCENDING

# Load variables from the .env file into the system environment
load_dotenv()

ROOT_DIR = Path(__file__).resolve().parents[2]
RESULTS_DIR = ROOT_DIR / "results"
EXPLAIN_DIR = ROOT_DIR / "evidences" / "explain_results" / "mongodb"
GRAPH_DIR = ROOT_DIR / "evidences" / "performance_graphs"

DB_NAME = "ecommify_mongodb"

def get_client() -> MongoClient:
    mongodb_uri = os.getenv("MONGODB_URI")
    if not mongodb_uri:
        raise ValueError("MONGODB_URI environment variable is required.")
    return MongoClient(mongodb_uri, serverSelectionTimeoutMS=30000)

def extract_execution_stats(explain: dict) -> dict:
    stats = explain.get("executionStats", {})
    n_returned = stats.get("nReturned") or 0
    docs_examined = stats.get("totalDocsExamined") or 0

    return {
        "executionTimeMillis": stats.get("executionTimeMillis"),
        "totalDocsExamined": docs_examined,
        "totalKeysExamined": stats.get("totalKeysExamined"),
        "nReturned": n_returned,
        "efficiencyRatio": round(docs_examined / n_returned, 4) if n_returned else None,
    }

def build_queries(db):
    return {
        "products_by_category_score_sales": db.products.find(
            {"category.name_en": {"$exists": True}, "status": "active"},
            {"product_id": 1, "category": 1, "analytics": 1}
        ).sort([
            ("analytics.avg_review_score", DESCENDING),
            ("analytics.total_sales", DESCENDING),
        ]).limit(20),

        "negative_reviews_with_comment": db.reviews.find(
            {
                "score": {"$lte": 2},
                "comment.message": {"$exists": True},
            },
            {"review_id": 1, "order_id": 1, "score": 1, "comment": 1}
        ).limit(20),

        "catalog_top_sales": db.product_catalog_view.find(
            {"category.name_en": {"$exists": True}},
            {"product_id": 1, "category": 1, "metrics": 1}
        ).sort("metrics.total_sales", DESCENDING).limit(20),
    }

def main() -> int:
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    EXPLAIN_DIR.mkdir(parents=True, exist_ok=True)
    GRAPH_DIR.mkdir(parents=True, exist_ok=True)

    client = get_client()
    client.admin.command("ping")
    db = client[DB_NAME]

    rows = []
    explains_summary = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "database": DB_NAME,
        "queries": {},
    }

    for query_name, cursor in build_queries(db).items():
        print(f"Running explain for: {query_name}")
        explain = cursor.explain()
        stats = extract_execution_stats(explain)

        explain_path = EXPLAIN_DIR / f"{query_name}_explain.json"
        explain_path.write_text(json.dumps(explain, indent=2, default=str, ensure_ascii=False), encoding="utf-8")

        row = {"query": query_name, **stats}
        rows.append(row)
        explains_summary["queries"][query_name] = {
            **stats,
            "explain_file": str(explain_path),
        }

    summary_json = RESULTS_DIR / "mongodb_explain_summary.json"
    summary_json.write_text(json.dumps(explains_summary, indent=2, default=str, ensure_ascii=False), encoding="utf-8")

    df = pd.DataFrame(rows)
    csv_path = RESULTS_DIR / "consolidated_test_results.csv"
    df.to_csv(csv_path, index=False)

    if not df.empty:
        ax = df.plot(
            x="query",
            y=["executionTimeMillis", "totalDocsExamined", "totalKeysExamined"],
            kind="bar",
            figsize=(12, 6),
        )
        plt.title("MongoDB Query Performance Summary")
        plt.ylabel("Metric value")
        plt.xticks(rotation=35, ha="right")
        plt.tight_layout()

        graph_path = GRAPH_DIR / "mongodb_performance_summary.png"
        plt.savefig(graph_path)
        plt.close()

    print(f"Consolidated CSV written to: {csv_path}")
    print(f"Summary JSON written to: {summary_json}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
