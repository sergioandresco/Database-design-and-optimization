"""
run_postgresql_scripts.py

Ejecuta scripts SQL de PostgreSQL/Supabase usando variables de entorno y genera evidencias.
"""

import os
from dotenv import load_dotenv
import json
import time
from pathlib import Path
from datetime import datetime, timezone

import psycopg2

# Load variables from the .env file into the system environment
load_dotenv()

ROOT_DIR = Path(__file__).resolve().parents[2]
RESULTS_DIR = ROOT_DIR / "results"
EVIDENCE_DIR = ROOT_DIR / "evidences"

SQL_FILES = [
    ROOT_DIR / "database"/ "posgresql" / "schema" / "01_create_tables.sql",
    ROOT_DIR / "database"/ "posgresql" / "schema" / "02_indexes.sql",
    ROOT_DIR / "database"/ "posgresql" / "seed_data" / "01_seed_data.sql",
]

def get_connection():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST"),
        port=os.getenv("POSTGRES_PORT", "5432"),
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
    )

def execute_sql_file(cursor, path: Path) -> dict:
    if not path.exists():
        return {
            "file": str(path),
            "status": "SKIPPED",
            "reason": "File not found",
            "execution_seconds": 0,
        }

    sql = path.read_text(encoding="utf-8")
    start = time.time()
    cursor.execute(sql)
    elapsed = round(time.time() - start, 4)

    return {
        "file": str(path),
        "status": "OK",
        "execution_seconds": elapsed,
    }

def main() -> int:
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    EVIDENCE_DIR.mkdir(parents=True, exist_ok=True)

    summary = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "scripts": [],
    }

    try:
        connection = get_connection()
        connection.autocommit = True

        with connection.cursor() as cursor:
            for sql_file in SQL_FILES:
                print(f"Executing: {sql_file}")
                result = execute_sql_file(cursor, sql_file)
                summary["scripts"].append(result)
                print(result)

        connection.close()

    except Exception as exc:
        summary["error"] = str(exc)
        print(f"[ERROR] PostgreSQL execution failed: {exc}")

    output_json = RESULTS_DIR / "postgresql_execution_summary.json"
    output_log = EVIDENCE_DIR / "postgresql_execution_log.txt"

    output_json.write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
    output_log.write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")

    print(f"Summary written to: {output_json}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
