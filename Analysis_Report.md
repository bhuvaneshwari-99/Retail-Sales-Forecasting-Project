# Retail Sales Analysis & Forecasting Report

**Dataset:** 21,930 daily records | 5 stores | 6 categories | Jan 2023 – Dec 2024
**Total revenue analyzed:** $38,451,889

---

## 1. Executive Summary

Daily revenue shows a clear weekly pattern (weekends stronger), a strong
holiday effect (Nov–Dec more than double an average day), and a steady
underlying growth trend. A machine-learning model (XGBoost) using calendar
and lag features forecasts daily revenue with **6.1% average error (MAPE)**
over a 60-day test window — more than **2x more accurate** than a naive
"yesterday repeats" baseline (14.2% MAPE). The single biggest driver of
forecast accuracy is knowing whether a day falls in a holiday shopping
window, which alone accounted for 72% of the model's predictive weight.

---

## 2. Key Findings

### Revenue is concentrated in a few categories
| Category | Revenue | Units Sold |
|---|---|---|
| Electronics | $16,680,890 | 76,805 |
| Clothing | $6,748,603 | 151,781 |
| Home & Garden | $5,429,651 | 91,622 |
| Sports | $4,564,026 | 84,012 |
| Groceries | $3,069,798 | 365,794 |
| Toys | $1,958,921 | 66,057 |

Electronics drives 43% of total revenue despite moderate unit volume — it's
a high-price, high-value category and the one most worth forecasting
precisely, since errors there carry the biggest dollar impact.

### Store performance is fairly even, with a clear leader
| Store | Region | Revenue |
|---|---|---|
| S3 — Eastside Plaza | East | $8,823,251 |
| S4 — Westfield Center | West | $7,848,756 |
| S1 — Downtown Flagship | North | $7,590,679 |
| S2 — Southgate Mall | South | $7,298,891 |
| S5 — Central Station | Central | $6,890,312 |

No single store is dramatically under- or over-performing (range is
~$1.9M, or about 22% of the top store's revenue) — this supports building
one shared forecasting approach across stores rather than needing
store-specific models.

### Weekends outsell weekdays by ~18%
| Day | Avg. Revenue (per row) |
|---|---|
| Saturday | $1,973.65 |
| Sunday | $1,968.45 |
| Friday | $1,705.47 |
| Thursday | $1,689.44 |
| Monday | $1,665.35 |
| Wednesday | $1,639.59 |
| Tuesday | $1,631.74 |

Weekend average ($1,971.05) vs. weekday average ($1,666.32) is an **18.3%
lift** — a reliable, low-noise signal that any forecasting model should
capture easily.

### Promotions lift unit sales by ~43%
Average units sold per row: **37.2 on non-promo days vs. 53.1 on promo
days** — a 42.9% lift. This is a large, measurable effect and a strong
candidate feature for any demand model (already included in the pipeline
via `promo_flag`).

### Holidays are the single strongest driver
Average revenue per row: **$1,693.54 on regular days vs. $3,881.24 on
holiday-window days** — more than **2.3x**. This matches what the
forecasting model found on its own: `holiday_flag` was by far the most
important feature (72% of total feature importance in the XGBoost model),
dwarfing lag-based features like yesterday's or last week's revenue.

---

## 3. Forecasting Model Comparison

Evaluated on the last 60 days (Nov 2 – Dec 31, 2024), which includes Black
Friday, Cyber Monday, and the Christmas shopping window — a deliberately
hard test period.

| Model | MAE | RMSE | MAPE |
|---|---|---|---|
| **XGBoost (lag + calendar features)** | 5,285 | 8,072 | **6.14%** |
| SARIMA(1,1,1)(1,1,1,7) | 10,730 | 25,451 | 9.35% |
| Naive (yesterday repeats) | 11,354 | 21,968 | 14.15% |
| 7-day Moving Average | 16,638 | 26,674 | 19.99% |
| Seasonal Naive (same day last week) | 19,999 | 36,676 | 23.51% |

**Interpretation:**
- XGBoost wins because it can directly use `holiday_flag` as an input —
  pure time-series methods (SARIMA, seasonal naive) have to infer holiday
  spikes from historical patterns alone, and both under-predict the sharp
  Black Friday / Christmas peaks visible in the actual-vs-forecast chart.
- Seasonal naive performs *worst* here specifically because it assumes
  "last week repeats," which fails badly right when a holiday spike hits.
- SARIMA still comfortably beats the simple baselines, so it remains a
  reasonable choice in settings without reliable promo/holiday calendars.

---

## 4. Business Recommendations

1. **Prioritize Electronics forecast accuracy** — it's 43% of revenue, so a
   1% forecasting error there costs more in absolute dollars than the same
   error in any other category.
2. **Build holiday/promo calendars into inventory planning**, not just
   historical averages — the data shows this is the single highest-leverage
   input for demand accuracy.
3. **Staff and stock for the ~18% weekend lift** as a standing baseline
   adjustment, not a special case.
4. **Treat promotions as a ~43% unit-volume lever** when planning
   promotional calendars against inventory commitments.
5. Since store performance is fairly even, a **shared forecasting model
   across stores** (rather than 5 separate models) is a reasonable and
   simpler starting point.

---

## 5. Limitations & Next Steps

- This report forecasts **total daily revenue**; a production system would
  forecast at the **store × category** grain for actual inventory
  decisions — the pipeline's feature engineering already supports this,
  it just needs to be run per-segment.
- SARIMA parameters `(1,1,1)(1,1,1,7)` were chosen for reasonable
  performance, not exhaustively tuned — a grid search (`auto_arima`) could
  improve it further.
- Facebook Prophet was not tested here but is worth adding — it treats
  holidays as explicit regressors, similar to XGBoost's advantage, and
  paired with confidence intervals.
- With more data, testing the promo lift with a proper causal method (e.g.
  difference-in-differences) rather than a simple average comparison would
  give a more defensible lift estimate.
