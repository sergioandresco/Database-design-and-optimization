"""
validate_environment.py

Valida dependencias mínimas y conexión opcional a MongoDB Atlas para el proyecto Ecommify.
"""

import os
from dotenv import load_dotenv
import sys
import platform
import importlib


# Load variables from the .env file into the system environment
load_dotenv()

REQUIRED_PACKAGES = [
    "pandas",
    "numpy",
    "pymongo",
    "psycopg2",
    "matplotlib",
    "dotenv",
    "tqdm",
]

def validate_python_version() -> bool:
    version = sys.version_info
    print(f"[INFO] Python version: {platform.python_version()}")
    if version.major < 3 or (version.major == 3 and version.minor < 9):
        print("[ERROR] Python 3.9+ is recommended.")
        return False
    print("[OK] Python version is compatible.")
    return True

def validate_packages() -> bool:
    ok = True
    for package in REQUIRED_PACKAGES:
        try:
            importlib.import_module(package)
            print(f"[OK] Package available: {package}")
        except ImportError:
            print(f"[ERROR] Missing package: {package}")
            ok = False
    return ok

def validate_mongodb_optional() -> bool:
    mongodb_uri = os.getenv("MONGODB_URI")
    if not mongodb_uri:
        print("[WARN] MONGODB_URI not found. Skipping MongoDB connection check.")
        return True

    try:
        from pymongo import MongoClient
        client = MongoClient(mongodb_uri, serverSelectionTimeoutMS=15000)
        client.admin.command("ping")
        print("[OK] MongoDB Atlas connection successful.")
        return True
    except Exception as exc:
        print(f"[ERROR] MongoDB connection failed: {exc}")
        return False

def main() -> int:
    checks = [
        validate_python_version(),
        validate_packages(),
        validate_mongodb_optional(),
    ]

    if all(checks):
        print("\nEnvironment validation successful.")
        return 0

    print("\nEnvironment validation completed with errors.")
    return 1

if __name__ == "__main__":
    raise SystemExit(main())
