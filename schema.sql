-- ============================================================
-- SCHEMA: retail_sales.db
-- Run this if you want to rebuild the database from the CSV yourself
-- (e.g. sqlite3 retail_sales.db < schema.sql)
-- ============================================================

CREATE TABLE IF NOT EXISTS sales (
    date          TEXT NOT NULL,       -- YYYY-MM-DD
    store_id      TEXT NOT NULL,
    region        TEXT NOT NULL,
    category      TEXT NOT NULL,
    units_sold    INTEGER NOT NULL,
    unit_price    REAL NOT NULL,
    revenue       REAL NOT NULL,
    promo_flag    INTEGER NOT NULL,    -- 1 if a promotion ran that day
    holiday_flag  INTEGER NOT NULL,    -- 1 if date falls in a major shopping event
    day_of_week   INTEGER NOT NULL,    -- 0=Mon ... 6=Sun
    is_weekend    INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_store (
    store_id    TEXT PRIMARY KEY,
    region      TEXT NOT NULL,
    store_name  TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_sales_date  ON sales(date);
CREATE INDEX IF NOT EXISTS idx_sales_store ON sales(store_id);
CREATE INDEX IF NOT EXISTS idx_sales_cat   ON sales(category);

-- To load the CSV into the `sales` table via the sqlite3 CLI:
--   .mode csv
--   .import --skip 1 retail_sales_data.csv sales
