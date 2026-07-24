# Retail Sales & Demand Forecasting — Project Structure

**Theme:** AI in Retail — using data to power smarter, more targeted operations
**Focus:** Sales / demand forecasting
**Tools:** SQL (SQLite) + Python (pandas, statsmodels/Prophet, scikit-learn)

---

## 1. Business Problem

Retailers waste money on broad marketing and get stock levels wrong when they
can't predict demand accurately. This project builds a forecasting pipeline
that predicts near-term sales by store and category, so a retailer could:
- Order the right inventory ahead of demand spikes (holidays, promos)
- Decide which categories/stores need marketing attention
- Quantify how much promotions actually lift sales

**Guiding question:** *Can we forecast next month's revenue by store and
category accurately enough to inform inventory and marketing decisions?*

---

## 2. Dataset

`retail_sales_data.csv` / `retail_sales.db` (provided)

| Column | Description |
|---|---|
| date | Daily grain, 2023-01-01 to 2024-12-31 |
| store_id / region | 5 stores across 5 regions |
| category | 6 product categories (Electronics, Clothing, Home & Garden, Groceries, Toys, Sports) |
| units_sold, unit_price, revenue | Core sales metrics |
| promo_flag | Whether a promotion ran that day |
| holiday_flag | Whether the date falls in a major shopping event window |
| day_of_week, is_weekend | Calendar features |

Built-in patterns to discover: weekly seasonality (weekend lift varies by
category), category-specific annual seasonality (Toys/Electronics peak in
Nov–Dec, Home & Garden peaks in spring), a slow upward trend, and a
measurable promotion effect. This mirrors real retail data closely enough for
genuine practice, without the licensing/quality uncertainty of a scraped or
crowd-uploaded file.

---

## 3. Folder Structure

```
retail-forecasting-project/
│
├── data/
│   ├── raw/
│   │   └── retail_sales_data.csv
│   └── processed/
│       └── daily_store_category.csv      (built in Phase 2)
│
├── sql/
│   ├── retail_sales.db
│   ├── schema.sql
│   └── eda_queries.sql
│
├── notebooks/
│   ├── 01_eda.ipynb
│   ├── 02_feature_engineering.ipynb
│   ├── 03_baseline_models.ipynb
│   ├── 04_forecasting_models.ipynb
│   └── 05_evaluation_and_insights.ipynb
│
├── src/
│   ├── db_utils.py
│   ├── features.py
│   └── models.py
│
├── reports/
│   └── figures/
│
└── README.md
```

---

## 4. Project Phases

### Phase 1 — Data Understanding & SQL Setup
- Load the CSV into SQLite (`retail_sales.db`, already built for you)
- Run EDA queries: monthly trend, day-of-week pattern, category/store
  performance, promotion effect, 7-day moving average (see `starter_queries.sql`)
- Deliverable: a short "data profile" summary (row counts, date range, missing
  values check, outlier scan)

### Phase 2 — SQL-Based Feature Engineering
- Aggregate to the modeling grain: **daily revenue per store + category**
- Add lag features via SQL window functions: `LAG(revenue, 1)`, `LAG(revenue, 7)`
- Add rolling averages (7-day, 28-day) using window functions
- Export the model-ready table to `data/processed/daily_store_category.csv`

### Phase 3 — Exploratory Analysis in Python
- Visualize trend + seasonality (line plots by month, by category)
- Decompose the series (trend / seasonal / residual) with
  `statsmodels.tsa.seasonal_decompose`
- Check stationarity (ADF test) to decide if differencing is needed

### Phase 4 — Baseline Models
Always start simple — these set the bar your real model must beat:
- Naive forecast (tomorrow = today)
- Seasonal naive (this month = same month last year)
- Moving average

### Phase 5 — Forecasting Models
Pick 2–3 to compare:
- **Statistical:** SARIMA (captures trend + seasonality directly)
- **Statistical/fast:** Facebook Prophet (handles holidays/promos as regressors well)
- **ML-based:** Gradient boosting (XGBoost/LightGBM) using the lag/rolling
  features from Phase 2 — often wins when you have promo/holiday flags as inputs

### Phase 6 — Evaluation
- Train/test split by **time** (never shuffle time series randomly!) — e.g.
  train on 2023–2024 Q3, test on the last 3 months
- Metrics: MAE, RMSE, and MAPE (MAPE is the one retail stakeholders understand)
- Compare all models in one table against the baselines

### Phase 7 — Business Insights & Reporting
- Which categories/stores are hardest to forecast, and why?
- Quantify the promotion effect (e.g. "promos lift units by X% on average")
- Translate forecast error into a business number (e.g. potential
  overstock/understock cost)
- Package as a short slide deck or dashboard (Power BI / Streamlit / matplotlib report)

---

## 5. Suggested Timeline (if this is a portfolio/coursework project)

| Week | Focus |
|---|---|
| 1 | Phase 1–2: SQL setup, EDA, feature engineering |
| 2 | Phase 3–4: Python EDA, baseline models |
| 3 | Phase 5: Build 2–3 forecasting models |
| 4 | Phase 6–7: Evaluate, write up insights, polish deliverable |

---

## 6. Stretch Goals (optional, ties back to "AI in retail" theme)

- Add a simple **recommendation** angle: which categories should a given
  store increase inventory for next month, based on forecast + current stock?
- Simulate an **A/B test** of a marketing campaign using the promo_flag column
  and measure lift with a simple causal approach (diff-in-diff)
- Turn Phase 5's best model into a small Streamlit app to demo forecasts interactively
