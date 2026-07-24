# Retail-Sales-Forecasting-Project

## The business problem

Retailers lose money in two ways when they can't predict demand: they either overstock (tying up cash, markdowns, waste) or understock (lost sales, especially during peak periods). On top of that, marketing spend gets wasted when it's not timed to when demand is actually rising. The guiding question was: can we forecast near-term sales accurately enough, by store and category, to actually inform inventory and marketing decisions?

## How you solved it

1. Got a real, structured dataset (2 years of daily sales, 5 stores, 6 categories) into a proper SQL database instead of working off a spreadsheet.
2. Used SQL to explore the data first — trends, weekday patterns, category/store performance, promo effects — before touching any models. This is the step that actually reveals what's worth modeling.
3. Engineered features that give a model something to learn from: lag values (yesterday, last week), rolling averages, and — critically — calendar flags for holidays and promotions.
4. Tested a range of approaches from simple to sophisticated: naive baselines → SARIMA (classic time-series) → XGBoost (machine learning using your engineered features).
5. Evaluated everything on a genuinely hard test window (Nov–Dec, including Black Friday and Christmas) using a time-respecting train/test split — not randomly shuffled, which would have been a mistake for time-series data.
6. Picked a winner based on evidence: XGBoost cut forecast error more than in half versus the naive baseline (6.1% vs 14.2% MAPE).

## The business insights that actually move the needle

- **Electronics is 43% of total revenue** despite moderate unit volume — this is where forecasting accuracy matters most in dollar terms, so it deserves the most attention if you can only focus resources on one category.
- **Holidays more than double average daily revenue**, and knowing whether a day is a holiday window turned out to be the single most powerful input to the model (72% of its predictive weight). That's a concrete, actionable finding: inventory planning built around holiday calendars will outperform planning built on historical averages alone.
- **Promotions lift units sold by ~43%** — a large, measurable effect worth building into promotional and inventory planning together, so stock levels match what a promo actually does to demand.
- **Weekends outsell weekdays by ~18%**, consistently enough that it should just be a standing staffing/stocking adjustment rather than something re-decided each week.
- **Store performance is fairly even across all 5 locations** — no store is an outlier — which means one shared forecasting model works fine; you don't need to build and maintain five separate ones.
- 

## What's in this project

| File | What it is | How to open it |
|------|------------|-----------------|
| `retail_sales_data.csv` | Raw dataset (21,930 rows) | Excel, Google Sheets, or `pandas.read_csv()` |
| `retail_sales.db` | Same data, pre-loaded into SQLite (`sales`, `dim_store` tables) | See below — **not** an Excel/Word file |
| `schema.sql` | Recreates the database from the CSV | Any SQLite client, or `sqlite3 retail_sales.db < schema.sql` |
| `starter_queries.sql` | 10 ready-to-run EDA queries | Paste into any SQLite client |
| `forecasting_pipeline.py` | Full Python pipeline: EDA → baselines → SARIMA → XGBoost → evaluation | `python3 forecasting_pipeline.py` |
| `model_comparison.csv` | Output: MAE/RMSE/MAPE per model | Excel or pandas |
| `figures/*.png` | Output charts from the pipeline | Any image viewer |
| `Project_Structure.md` | The project plan (phases, timeline) | Any text editor / Markdown viewer |
| `Analysis_Report.md` | Write-up of findings and recommendations | Any text editor / Markdown viewer |

---

## Opening `retail_sales.db`

A `.db` file won't open by double-clicking — you need a SQLite client. Pick whichever fits how you like to work:

### Option A — DB Browser for SQLite (easiest, free, GUI)

1. Download from **https://sqlitebrowser.org/dl/** (Windows/Mac/Linux)
2. Open the app → **File → Open Database** → select `retail_sales.db`
3. Click the **"Execute SQL"** tab, paste in queries from `starter_queries.sql`, hit the ▶ Run button
4. The **"Browse Data"** tab lets you scroll the raw tables directly, no SQL needed

### Option B — VS Code (if you already use it)

1. Install the **"SQLite Viewer"** or **"SQLite"** extension from the Extensions marketplace
2. Right-click `retail_sales.db` in the file explorer → **Open Database**
3. Run queries in a `.sql` file against it

### Option C — DBeaver (free, more powerful, good if you'll also connect to real databases later)

1. Download from **https://dbeaver.io/download/**
2. New Connection → SQLite → point it at `retail_sales.db`

### Option D — Command line

```bash
sqlite3 retail_sales.db
.tables                    -- list tables
.schema sales               -- show table structure
SELECT * FROM sales LIMIT 5;
```

### Option E — Python (no separate app needed)

```python
import sqlite3
import pandas as pd

conn = sqlite3.connect("retail_sales.db")
df = pd.read_sql("SELECT * FROM sales LIMIT 10", conn)
print(df)
```

**Recommendation:** if you just want to poke around and run the starter queries with the least setup, go with **DB Browser for SQLite**. If you're doing the Python phase anyway, Option E means you don't need to install anything extra.

---

## Running the Python pipeline

Requires: `pandas`, `numpy`, `matplotlib`, `statsmodels`, `scikit-learn`, `xgboost`

```bash
pip install pandas numpy matplotlib statsmodels scikit-learn xgboost
python3 forecasting_pipeline.py
```
## Quick start recommendation

1. Open `retail_sales.db` in DB Browser for SQLite, run `starter_queries.sql` to get familiar with the data
2. Read `Analysis_Report.md` for what's already been found
3. Run `forecasting_pipeline.py` yourself to see the modeling in action, then extend it (per-category forecasts, add Prophet, tune SARIMA orders)
4. Reference `Project_Structure.md` for the full phase-by-phase plan if you want to build this out further
