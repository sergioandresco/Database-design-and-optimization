#!/usr/bin/env bash
set -e

echo "Installing Ecommify repository dependencies..."

python -m pip install --upgrade pip
python -m pip install   pandas   numpy   pymongo   dnspython   psycopg2-binary   python-dotenv   tqdm   matplotlib

echo "Dependencies installed successfully."
