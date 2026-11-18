from __future__ import annotations

import os
import sqlite3
from collections.abc import Mapping
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DB_PATH = Path(os.getenv("DATABASE_PATH", "data/jobs.db"))
if not DB_PATH.is_absolute():
    DB_PATH = ROOT / DB_PATH


class Row(Mapping):
    def __init__(self, cols: list[str], vals: tuple[Any, ...]) -> None:
        self._d = dict(zip(cols, vals))
        self._t = tuple(vals)

    def __getitem__(self, key: Any) -> Any:
        if isinstance(key, int):
            return self._t[key]
        return self._d[key]

    def __iter__(self):
        return iter(self._d)

    def __len__(self) -> int:
        return len(self._t)


class CursorWrapper:
    def __init__(self, cur: Any) -> None:
        self._cur = cur

    @property
    def description(self) -> Any:
        return self._cur.description

    def fetchone(self) -> Row | None:
        row = self._cur.fetchone()
        if row is None:
            return None
        cols = [c[0] for c in self._cur.description]
        return Row(cols, row)

    def fetchall(self) -> list[Row]:
        rows = self._cur.fetchall()
        if not rows:
            return []
        cols = [c[0] for c in self._cur.description]
        return [Row(cols, r) for r in rows]


class LibsqlWrapper:
    def __init__(self, conn: Any) -> None:
        self._conn = conn

    def __enter__(self) -> LibsqlWrapper:
        return self

    def __exit__(self, exc_type: Any, exc_val: Any, exc_tb: Any) -> None:
        if exc_type is None:
            self._conn.commit()
        else:
            self._conn.rollback()

    def execute(self, sql: str, params: Any = None) -> CursorWrapper:
        cur = self._conn.cursor()
        if params is not None:
            cur.execute(sql, params)
        else:
            cur.execute(sql)
        return CursorWrapper(cur)

    def commit(self) -> None:
        self._conn.commit()

    def close(self) -> None:
        self._conn.close()


def connect() -> Any:
    turso_url = os.getenv("TURSO_DATABASE_URL", "").strip()
    turso_token = os.getenv("TURSO_AUTH_TOKEN", "").strip()
    if turso_url:
        import libsql_experimental as libsql
        if turso_token:
            conn = libsql.connect(turso_url, auth_token=turso_token)
        else:
            conn = libsql.connect(turso_url)
        return LibsqlWrapper(conn)

    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    db = sqlite3.connect(DB_PATH)
    db.row_factory = sqlite3.Row
    return db
