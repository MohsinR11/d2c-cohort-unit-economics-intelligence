-- ═══════════════════════════════════════════════════════════
-- SCRIPT 01: CUSTOMER ACQUISITION ANALYSIS
-- Business Question: Which channels bring the best customers
-- at what cost, and how does CAC vary over time?
-- ═══════════════════════════════════════════════════════════

-- ─────────────────────────────────────────
-- 1A: Channel-wise customer volume and avg CAC
-- ─────────────────────────────────────────
SELECT
    acquisition_channel,
    COUNT(*)                            AS total_customers,
    ROUND(AVG(acquisition_cac), 2)      AS avg_cac,
    ROUND(MIN(acquisition_cac), 2)      AS min_cac,
    ROUND(MAX(acquisition_cac), 2)      AS max_cac,
    ROUND(SUM(acquisition_cac), 2)      AS total_cac_spent,
    ROUND(COUNT(*) * 100.0 /
          SUM(COUNT(*)) OVER (), 2)     AS pct_of_customers
FROM customers
GROUP BY acquisition_channel
ORDER BY total_customers DESC;


-- ─────────────────────────────────────────
-- 1B: Monthly new customer acquisition trend by channel
-- ─────────────────────────────────────────
SELECT
    TO_CHAR(acquisition_date, 'YYYY-MM')    AS acquisition_month,
    acquisition_channel,
    COUNT(*)                                AS new_customers,
    ROUND(AVG(acquisition_cac), 2)          AS avg_cac
FROM customers
GROUP BY 1, 2
ORDER BY 1, 2;


-- ─────────────────────────────────────────
-- 1C: City tier wise acquisition breakdown
-- ─────────────────────────────────────────
SELECT
    city_tier,
    acquisition_channel,
    COUNT(*)                            AS customers,
    ROUND(AVG(acquisition_cac), 2)      AS avg_cac
FROM customers
GROUP BY 1, 2
ORDER BY 1, 2;


-- ─────────────────────────────────────────
-- 1D: Gender and age band distribution by channel
-- ─────────────────────────────────────────
SELECT
    acquisition_channel,
    gender,
    CASE
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        ELSE '45+'
    END                                 AS age_band,
    COUNT(*)                            AS customers
FROM customers
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;