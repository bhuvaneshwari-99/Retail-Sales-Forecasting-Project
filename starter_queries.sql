-- ============================================================
-- RETAIL SALES FORECASTING — STARTER SQL QUERIES
-- Database: retail_sales.db  |  Tables: sales, dim_store
-- ============================================================

-- 1. Sanity check: row counts, date range
SELECT COUNT(*) AS total_rows, MIN(date) AS first_date, MAX(date) AS last_date
FROM sales;

-- 2. Monthly revenue trend (the core series you'll forecast)
SELECT strftime('%Y-%m', date) AS month, ROUND(SUM(revenue), 2) AS monthly_revenue
FROM sales
GROUP BY month
ORDER BY month;

-- 3. Day-of-week pattern (are weekends really stronger?)
SELECT day_of_week,
       CASE day_of_week WHEN 0 THEN 'Mon' WHEN 1 THEN 'Tue' WHEN 2 THEN 'Wed'
                         WHEN 3 THEN 'Thu' WHEN 4 THEN 'Fri' WHEN 5 THEN 'Sat' ELSE 'Sun' END AS day_name,
       ROUND(AVG(revenue), 2) AS avg_daily_revenue
FROM sales
GROUP BY day_of_week
ORDER BY day_of_week;

-- 4. Category performance ranked by total revenue
SELECT category, ROUND(SUM(revenue), 2) AS total_revenue, SUM(units_sold) AS total_units
FROM sales
GROUP BY category
ORDER BY total_revenue DESC;

-- 5. Store performance with region (join against dim_store)
SELECT s.store_id, d.store_name, s.region, ROUND(SUM(s.revenue), 2) AS total_revenue
FROM sales s
JOIN dim_store d ON s.store_id = d.store_id
GROUP BY s.store_id, d.store_name, s.region
ORDER BY total_revenue DESC;

-- 6. Promotion effect: average units sold on promo days vs non-promo days, by category
SELECT category, promo_flag, ROUND(AVG(units_sold), 2) AS avg_units
FROM sales
GROUP BY category, promo_flag
ORDER BY category, promo_flag;

-- 7. Holiday lift: compare holiday_flag=1 days vs regular days
SELECT holiday_flag, ROUND(AVG(revenue), 2) AS avg_daily_revenue_per_row
FROM sales
GROUP BY holiday_flag;

-- 8. 7-day moving average of total daily revenue (classic smoothing before modeling)
WITH daily AS (
  SELECT date, SUM(revenue) AS daily_revenue
  FROM sales
  GROUP BY date
)
SELECT date, daily_revenue,
       ROUND(AVG(daily_revenue) OVER (
         ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ), 2) AS moving_avg_7d
FROM daily
ORDER BY date;

-- 9. Year-over-year comparison by month (useful for detecting trend + seasonality together)
SELECT strftime('%m', date) AS month_num,
       strftime('%Y', date) AS year,
       ROUND(SUM(revenue), 2) AS revenue
FROM sales
GROUP BY year, month_num
ORDER BY month_num, year;

-- 10. Build the model-ready table: daily revenue per store+category (the typical forecasting grain)
SELECT date, store_id, category, SUM(units_sold) AS units_sold, SUM(revenue) AS revenue,
       MAX(promo_flag) AS promo_flag, MAX(holiday_flag) AS holiday_flag, MAX(is_weekend) AS is_weekend
FROM sales
GROUP BY date, store_id, category
ORDER BY date;
