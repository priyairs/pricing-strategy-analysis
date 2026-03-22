CREATE DATABASE pricing_db;
USE pricing_db;

CREATE TABLE pricing_analysis (
    product_id                 VARCHAR(50),
    product_category_name      VARCHAR(100),
    month_year                 VARCHAR(20),
    qty                        INT,
    total_price                FLOAT,
    freight_price              FLOAT,
    unit_price                 FLOAT,
    product_name_lenght        INT,
    product_description_lenght INT,
    product_photos_qty         INT,
    product_weight_g           INT,
    product_score              FLOAT,
    customers                  INT,
    weekday                    INT,
    weekend                    INT,
    holiday                    INT,
    month                      INT,
    year                       INT,
    s                          FLOAT,
    volume                     INT,
    comp_1                     FLOAT,
    ps1                        FLOAT,
    fp1                        FLOAT,
    comp_2                     FLOAT,
    ps2                        FLOAT,
    fp2                        FLOAT,
    comp_3                     FLOAT,
    ps3                        FLOAT,
    fp3                        FLOAT,
    lag_price                  FLOAT,
    revenue                    FLOAT,
    margin                     FLOAT,
    margin_pct                 FLOAT,
    comp_avg                   FLOAT,
    price_gap                  FLOAT,
    price_position             VARCHAR(20),
    price_band                 VARCHAR(20),
    price_drop                 FLOAT,
    discount_band              VARCHAR(30),
    price_rounded              INT
);

-- ANALYSIS 1: Revenue by Category
SELECT
    product_category_name,
    COUNT(*)                  AS total_products,
    ROUND(AVG(unit_price), 2) AS avg_price,
    ROUND(SUM(revenue), 2)    AS total_revenue,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct,
    ROUND(AVG(qty), 2)        AS avg_qty_sold
FROM pricing_analysis
GROUP BY product_category_name
ORDER BY total_revenue DESC;

-- ANALYSIS 2: Revenue by Price Band
SELECT
    price_band,
    COUNT(*)                  AS product_count,
    ROUND(AVG(unit_price), 2) AS avg_price,
    ROUND(AVG(qty), 2)        AS avg_qty,
    ROUND(SUM(revenue), 2)    AS total_revenue,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct
FROM pricing_analysis
GROUP BY price_band
ORDER BY avg_price ASC;

-- ANALYSIS 3: Price Positioning vs Competitors
SELECT
    price_position,
    COUNT(*)                  AS product_count,
    ROUND(AVG(unit_price), 2) AS avg_our_price,
    ROUND(AVG(comp_avg), 2)   AS avg_comp_price,
    ROUND(AVG(price_gap), 2)  AS avg_price_gap,
    ROUND(AVG(revenue), 2)    AS avg_revenue,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct
FROM pricing_analysis
GROUP BY price_position
ORDER BY avg_revenue DESC;

-- ANALYSIS 4: Discount Impact on Revenue and Margin
SELECT
    discount_band,
    COUNT(*)                   AS product_count,
    ROUND(AVG(price_drop), 2)  AS avg_price_drop,
    ROUND(AVG(revenue), 2)     AS avg_revenue,
    ROUND(AVG(margin_pct), 2)  AS avg_margin_pct,
    ROUND(AVG(qty), 2)         AS avg_qty_sold
FROM pricing_analysis
GROUP BY discount_band
ORDER BY avg_revenue DESC;

-- ANALYSIS 5: Monthly Revenue Trend
SELECT
    year,
    month,
    ROUND(SUM(revenue), 2)    AS total_revenue,
    ROUND(AVG(unit_price), 2) AS avg_price,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct,
    SUM(qty)                  AS total_units_sold
FROM pricing_analysis
GROUP BY year, month
ORDER BY year ASC, month ASC;

-- ANALYSIS 6: Top 10 Most Profitable Categories
SELECT
    product_category_name,
    ROUND(AVG(margin_pct), 2)  AS avg_margin_pct,
    ROUND(SUM(revenue), 2)     AS total_revenue,
    ROUND(AVG(unit_price), 2)  AS avg_price,
    ROUND(AVG(comp_avg), 2)    AS avg_comp_price,
    SUM(qty)                   AS total_units
FROM pricing_analysis
GROUP BY product_category_name
ORDER BY avg_margin_pct DESC
LIMIT 10;

-- ANALYSIS 7: Weekday vs Weekend Performance
SELECT
    CASE WHEN weekday = 1 THEN 'Weekday' ELSE 'Weekend' END AS day_type,
    COUNT(*)                  AS records,
    ROUND(AVG(unit_price), 2) AS avg_price,
    ROUND(AVG(qty), 2)        AS avg_qty,
    ROUND(AVG(revenue), 2)    AS avg_revenue,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct
FROM pricing_analysis
GROUP BY weekday;

-- ANALYSIS 8: Holiday Effect on Sales
SELECT
    CASE WHEN holiday = 1 THEN 'Holiday' ELSE 'Non-Holiday' END AS day_type,
    COUNT(*)                  AS records,
    ROUND(AVG(unit_price), 2) AS avg_price,
    ROUND(AVG(qty), 2)        AS avg_qty,
    ROUND(SUM(revenue), 2)    AS total_revenue,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct
FROM pricing_analysis
GROUP BY holiday;

-- ANALYSIS 9: Optimal Price Zones
SELECT
    price_rounded,
    COUNT(*)                  AS product_count,
    ROUND(AVG(revenue), 2)    AS avg_revenue,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct,
    ROUND(AVG(qty), 2)        AS avg_qty
FROM pricing_analysis
GROUP BY price_rounded
HAVING product_count >= 5
ORDER BY avg_revenue DESC
LIMIT 10;

-- ANALYSIS 10: Our Score vs Competitor Scores by Category
SELECT
    product_category_name,
    ROUND(AVG(product_score), 2) AS our_score,
    ROUND(AVG(ps1), 2)           AS comp1_score,
    ROUND(AVG(ps2), 2)           AS comp2_score,
    ROUND(AVG(ps3), 2)           AS comp3_score,
    ROUND(AVG(unit_price), 2)    AS our_price,
    ROUND(AVG(comp_avg), 2)      AS comp_avg_price
FROM pricing_analysis
GROUP BY product_category_name
ORDER BY our_score DESC;

-- ANALYSIS 11:Price Elasticity Approximation in SQL
-- Categories where small price increase = big qty drop = elastic demand
SELECT
    product_category_name,
    ROUND(AVG(unit_price), 2)                          AS avg_price,
    ROUND(AVG(qty), 2)                                 AS avg_qty,
    ROUND(AVG(revenue), 2)                             AS avg_revenue,
    ROUND((AVG(qty) / NULLIF(AVG(unit_price), 0)), 4)  AS qty_per_price_unit,
    CASE
        WHEN (AVG(qty) / NULLIF(AVG(unit_price), 0)) > 5  THEN 'Highly Elastic'
        WHEN (AVG(qty) / NULLIF(AVG(unit_price), 0)) > 2  THEN 'Elastic'
        WHEN (AVG(qty) / NULLIF(AVG(unit_price), 0)) > 1  THEN 'Moderate'
        ELSE 'Inelastic'
    END AS demand_type
FROM pricing_analysis
GROUP BY product_category_name
ORDER BY qty_per_price_unit DESC;

-- ANALYSIS 12:Revenue Lost by Being Overpriced
-- Products priced higher than competitors AND earning below avg revenue
SELECT
    product_category_name,
    COUNT(*)                   AS overpriced_products,
    ROUND(AVG(price_gap), 2)   AS avg_price_gap,
    ROUND(AVG(revenue), 2)     AS avg_revenue,
    ROUND(AVG(margin_pct), 2)  AS avg_margin_pct,
    ROUND(AVG(qty), 2)         AS avg_qty
FROM pricing_analysis
WHERE price_position = 'Overpriced'
  AND revenue < (SELECT AVG(revenue) FROM pricing_analysis)
GROUP BY product_category_name
ORDER BY overpriced_products DESC;

-- ANALYSIS 13: Sweet Spot Products
-- On-par with competitors + high margin + high revenue = ideal pricing
SELECT
    product_id,
    product_category_name,
    ROUND(unit_price, 2)       AS our_price,
    ROUND(comp_avg, 2)         AS comp_avg,
    ROUND(margin_pct, 2)       AS margin_pct,
    ROUND(revenue, 2)          AS revenue,
    qty,
    price_position
FROM pricing_analysis
WHERE price_position = 'On-par'
  AND margin_pct > (SELECT AVG(margin_pct) FROM pricing_analysis)
  AND revenue   > (SELECT AVG(revenue)    FROM pricing_analysis)
ORDER BY revenue DESC
LIMIT 15;

-- ANALYSIS 14: Underpriced but High Demand = Revenue Leakage
-- These products sell well but are priced too low → easy revenue gain
SELECT
    product_category_name,
    COUNT(*)                   AS underpriced_count,
    ROUND(AVG(unit_price), 2)  AS avg_our_price,
    ROUND(AVG(comp_avg), 2)    AS avg_comp_price,
    ROUND(AVG(price_gap), 2)   AS avg_gap,
    ROUND(AVG(qty), 2)         AS avg_qty,
    ROUND(AVG(revenue), 2)     AS avg_revenue,
    ROUND(
        AVG(comp_avg - unit_price) * AVG(qty), 2
    )                          AS estimated_revenue_leakage
FROM pricing_analysis
WHERE price_position = 'Underpriced'
  AND qty > (SELECT AVG(qty) FROM pricing_analysis)
GROUP BY product_category_name
ORDER BY estimated_revenue_leakage DESC;

-- ANALYSIS 15: Discount Effectiveness — did discounting actually increase qty?
SELECT
    discount_band,
    COUNT(*)                   AS products,
    ROUND(AVG(qty), 2)         AS avg_qty,
    ROUND(AVG(revenue), 2)     AS avg_revenue,
    ROUND(AVG(margin_pct), 2)  AS avg_margin,
    ROUND(AVG(price_drop), 2)  AS avg_price_drop,
    CASE
        WHEN AVG(qty) > (SELECT AVG(qty) FROM pricing_analysis)
         AND AVG(margin_pct) > (SELECT AVG(margin_pct) FROM pricing_analysis)
        THEN 'Effective'
        WHEN AVG(qty) > (SELECT AVG(qty) FROM pricing_analysis)
        THEN 'Drives volume only'
        ELSE 'Ineffective'
    END AS discount_verdict
FROM pricing_analysis
GROUP BY discount_band
ORDER BY avg_revenue DESC;

-- ANALYSIS 16: Year-over-Year Revenue Growth by Category
SELECT
    product_category_name,
    year,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(revenue) - LAG(SUM(revenue))
        OVER (PARTITION BY product_category_name ORDER BY year), 2) AS yoy_change,
    ROUND(
        (SUM(revenue) - LAG(SUM(revenue))
            OVER (PARTITION BY product_category_name ORDER BY year))
        / NULLIF(LAG(SUM(revenue))
            OVER (PARTITION BY product_category_name ORDER BY year), 0) * 100
    , 2) AS yoy_growth_pct
FROM pricing_analysis
GROUP BY product_category_name, year
ORDER BY product_category_name, year;

-- ANALYSIS 17: Competitor Freight vs Our Freight — who has cost advantage?
SELECT
    product_category_name,
    ROUND(AVG(freight_price), 2) AS our_freight,
    ROUND(AVG(fp1), 2)           AS comp1_freight,
    ROUND(AVG(fp2), 2)           AS comp2_freight,
    ROUND(AVG(fp3), 2)           AS comp3_freight,
    ROUND(AVG(freight_price) - AVG((fp1 + fp2 + fp3) / 3), 2) AS freight_gap,
    CASE
        WHEN AVG(freight_price) < AVG((fp1 + fp2 + fp3) / 3) THEN 'We have advantage'
        ELSE 'Competitors cheaper'
    END AS freight_verdict
FROM pricing_analysis
GROUP BY product_category_name
ORDER BY freight_gap ASC;


-- ANALYSIS 18: Pricing Strategy Recommendation per Category
-- Combines positioning + margin + elasticity into one action label
SELECT
    product_category_name,
    ROUND(AVG(unit_price), 2)  AS avg_price,
    ROUND(AVG(margin_pct), 2)  AS avg_margin,
    ROUND(AVG(price_gap), 2)   AS avg_price_gap,
    ROUND(AVG(qty), 2)         AS avg_qty,
    CASE
        WHEN AVG(margin_pct) > 40 AND AVG(price_gap) < 0
            THEN 'Raise price — underpriced with high margin'
        WHEN AVG(margin_pct) < 20 AND AVG(price_gap) > 5
            THEN 'Reduce price — overpriced with low margin'
        WHEN AVG(qty) > 200 AND AVG(margin_pct) < 25
            THEN 'Bundle products — high volume low margin'
        WHEN AVG(price_gap) BETWEEN -5 AND 5 AND AVG(margin_pct) > 30
            THEN 'Maintain — sweet spot pricing'
        ELSE 'Review — mixed signals'
    END AS pricing_recommendation
FROM pricing_analysis
GROUP BY product_category_name
ORDER BY avg_margin DESC;

