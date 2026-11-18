#!/usr/bin/env python3
"""
Seed your cloud Turso database with the local SQLite data (tables and jobs).
Usage:
    export TURSO_DATABASE_URL="libsql://your-db.turso.io"
    export TURSO_AUTH_TOKEN="your-token"
    python seed_turso.py
"""
import os
import sqlite3
import sys
from pathlib import Path
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent
load_dotenv(ROOT / ".env")

LOCAL_DB = ROOT / "data" / "jobs.db"
TURSO_URL = os.getenv("TURSO_DATABASE_URL", "").strip()
TURSO_TOKEN = os.getenv("TURSO_AUTH_TOKEN", "").strip()

if not TURSO_URL:
    print("Error: TURSO_DATABASE_URL is not set.")
    print("Set TURSO_DATABASE_URL and TURSO_AUTH_TOKEN in your environment or backend/.env")
    sys.exit(1)

if not LOCAL_DB.exists():
    print(f"Error: Local database {LOCAL_DB} not found.")
    sys.exit(1)

import libsql_experimental as libsql

print(f"Connecting to local SQLite: {LOCAL_DB}")
local_conn = sqlite3.connect(LOCAL_DB)
local_cur = local_conn.cursor()

print(f"Connecting to Turso: {TURSO_URL}")
turso_conn = libsql.connect(TURSO_URL, auth_token=TURSO_TOKEN or None)
turso_cur = turso_conn.cursor()

tables = ["jobs", "sync_runs"]

for table in tables:
    print(f"\nProcessing table '{table}'...")
    schema_row = local_cur.execute(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name=?", (table,)
    ).fetchone()
    if not schema_row:
        print(f"  Warning: Table {table} does not exist locally. Skipping.")
        continue

    create_sql = schema_row[0]
    print(f"  Ensuring table exists in Turso...")
    turso_cur.execute(create_sql)
    turso_conn.commit()

    rows = local_cur.execute(f"SELECT * FROM {table}").fetchall()
    col_names = [d[0] for d in local_cur.description]
    placeholders = ", ".join(["?"] * len(col_names))
    col_list = ", ".join(col_names)

    print(f"  Transferring {len(rows)} records from '{table}' to Turso...")
    insert_sql = f"INSERT OR REPLACE INTO {table} ({col_list}) VALUES ({placeholders})"
    
    count = 0
    for r in rows:
        turso_cur.execute(insert_sql, r)
        count += 1
        if count % 100 == 0:
            print(f"    Uploaded {count}/{len(rows)}...")
    turso_conn.commit()
    print(f"  Finished '{table}' ({count} records).")

turso_conn.close()
local_conn.close()
print("\nSuccess! Turso database is seeded and ready for production.")
