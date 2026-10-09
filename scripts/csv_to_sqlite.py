"""Convierte el CSV del sensor (grupo 601) a una base SQLite para el asset de Flutter.

Uso (desde la raíz del proyecto):
    python scripts/csv_to_sqlite.py

- Lee   : _analisis/dataset/Stationary/Stationary/601/sen66_20260401_075451.csv
- Escribe: assets/data/air_quality.db

Solo biblioteca estándar. El CSV original no se modifica.
Reduce a ~1 medición por minuto promediando los valores numéricos de cada minuto.
Descarta registros con co2 >= 60000, temperature_c <= 0 o humidity_pct <= 0.
"""

import csv
import os
import sqlite3
from collections import defaultdict
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSV_PATH = os.path.join(
    BASE_DIR, "_analisis", "dataset", "Stationary", "Stationary", "601",
    "sen66_20260401_075451.csv",
)
DB_PATH = os.path.join(BASE_DIR, "assets", "data", "air_quality.db")

NUMERIC_COLS = [
    "temperature_c", "humidity_pct", "co2_ppm",
    "pm1_0", "pm2_5", "pm4_0", "pm10",
    "voc_index", "nox_index",
]

# Mapeo columna CSV -> columna SQLite
COL_MAP = {
    "temperature_c": "temperature",
    "humidity_pct": "humidity",
    "co2_ppm": "co2",
    "pm1_0": "pm1",
    "pm2_5": "pm25",
    "pm4_0": "pm4",
    "pm10": "pm10",
    "voc_index": "voc",
    "nox_index": "nox",
}


def es_valido(row):
    try:
        co2 = float(row["co2_ppm"])
        temp = float(row["temperature_c"])
        hum = float(row["humidity_pct"])
    except (ValueError, TypeError):
        return False
    return co2 < 60000 and temp > 0 and hum > 0


def main():
    if not os.path.isfile(CSV_PATH):
        raise SystemExit(f"No se encontró el CSV: {CSV_PATH}")

    # Agrupar por minuto: clave = timestamp truncado al minuto
    buckets = defaultdict(lambda: {c: [] for c in NUMERIC_COLS})
    total = 0
    descartados = 0

    with open(CSV_PATH, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            total += 1
            if not es_valido(row):
                descartados += 1
                continue
            try:
                ts = datetime.strptime(
                    row["timestamp_utc"], "%Y-%m-%d %H:%M:%S.%f"
                ).replace(second=0, microsecond=0)
            except ValueError:
                descartados += 1
                continue
            key = ts.strftime("%Y-%m-%d %H:%M:%S")
            bucket = buckets[key]
            for col in NUMERIC_COLS:
                try:
                    bucket[col].append(float(row[col]))
                except (ValueError, TypeError):
                    pass

    # Crear la base SQLite desde cero (reproducible)
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)

    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.execute(
        """
        CREATE TABLE mediciones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            temperature REAL,
            humidity REAL,
            co2 REAL,
            pm1 REAL,
            pm25 REAL,
            pm4 REAL,
            pm10 REAL,
            voc REAL,
            nox REAL
        )
        """
    )
    cur.execute("CREATE INDEX idx_mediciones_timestamp ON mediciones (timestamp)")

    insert_sql = (
        "INSERT INTO mediciones (timestamp, temperature, humidity, co2, "
        "pm1, pm25, pm4, pm10, voc, nox) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    )
    for key in sorted(buckets):
        bucket = buckets[key]
        if not bucket["temperature_c"]:
            continue
        valores = [
            round(sum(bucket[c]) / len(bucket[c]), 2) if bucket[c] else None
            for c in NUMERIC_COLS
        ]
        cur.execute(insert_sql, [key] + valores)

    conn.commit()
    n_final = cur.execute("SELECT COUNT(*) FROM mediciones").fetchone()[0]
    conn.close()

    print(f"CSV: {total} filas leídas, {descartados} descartadas")
    print(f"SQLite: {n_final} mediciones (1 por minuto) en {DB_PATH}")


if __name__ == "__main__":
    main()
