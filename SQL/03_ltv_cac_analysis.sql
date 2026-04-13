-- ═══════════════════════════════════════════════════════════
-- SCRIPT 03: LTV vs CAC ANALYSIS
-- Business Question: Which channels have healthy LTV:CAC
-- ratios and what is the payback period per channel?
-- ═══════════════════════════════════════════════════════════

-- ─────────────────────────────────────────
-- 3A: Customer-level cumulative LTV
-- ─────────────────────────────────────────
WITH customer_revenue AS (
    SELECT
        o.customer_id,
        c.acquisition_channel,
        c.acquisition_cac,
        c.acquisition_date,
        SUM(o.order_revenue)                        AS total_revenue,
        SUM(o.gross_profit)                         AS total_gross_profit,
        COUNT(DISTINCT o.order_id)                  AS total_orders,
        MIN(o.order_date)                           AS first_order_date,
        MAX(o.order_date)                           AS last_order_date
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY 1, 2, 3, 4
),

-- ─────────────────────────────────────────
-- 3B: Channel-level LTV and CAC aggregation
-- ─────────────────────────────────────────
channel_ltv AS (
    SELECT
        acquisition_channel,
        COUNT(DISTINCT customer_id)                 AS total_customers,
        ROUND(AVG(acquisition_cac), 2)              AS avg_cac,
        ROUND(AVG(total_revenue), 2)                AS avg_ltv_revenue,
        ROUND(AVG(total_gross_profit), 2)           AS avg_ltv_gross_profit,
        ROUND(AVG(total_orders), 2)                 AS avg_orders_per_customer,
        ROUND(AVG(total_gross_profit)
              / NULLIF(AVG(acquisition_cac), 0), 2) AS ltv_cac_ratio,
        ROUND(AVG(
            CASE WHEN total_gross_profit > 0
            THEN acquisition_cac / (total_gross_profit /
                 NULLIF(total_orders, 0))
            ELSE NULL END
        ), 1)                                       AS est_payback_orders
    FROM customer_revenue
    GROUP BY acquisition_channel
)

SELECT
    acquisition_channel,
    total_customers,
    avg_cac,
    avg_ltv_revenue,
    avg_ltv_gross_profit,
    avg_orders_per_customer,
    ltv_cac_ratio,
    est_payback_orders,
    CASE
        WHEN ltv_cac_ratio >= 3   THEN 'Excellent (≥3x)'
        WHEN ltv_cac_ratio >= 2   THEN 'Good (2–3x)'
        WHEN ltv_cac_ratio >= 1   THEN 'Break-Even (1–2x)'
        ELSE                           'Value Destroying (<1x)'
    END                                             AS ltv_cac_health
FROM channel_ltv
ORDER BY ltv_cac_ratio DESC;


-- ─────────────────────────────────────────
-- 3C: Cumulative LTV build-up by month since acquisition
-- (for LTV curve chart in Power BI)
-- ─────────────────────────────────────────
WITH order_tagged AS (
    SELECT
        o.customer_id,
        c.acquisition_channel,
        c.acquisition_cac,
        o.gross_profit,
        o.order_revenue,
        (EXTRACT(YEAR FROM o.order_date) - EXTRACT(YEAR FROM c.acquisition_date)) * 12
        + (EXTRACT(MONTH FROM o.order_date) - EXTRACT(MONTH FROM c.acquisition_date))
                                                    AS months_since_acquisition
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
)
SELECT
    acquisition_channel,
    months_since_acquisition,
    COUNT(DISTINCT customer_id)                     AS active_customers,
    ROUND(AVG(gross_profit), 2)                     AS avg_gp_this_month,
    ROUND(SUM(SUM(order_revenue))
          OVER (PARTITION BY acquisition_channel
                ORDER BY months_since_acquisition), 2) AS cumulative_revenue,
    ROUND(SUM(SUM(gross_profit))
          OVER (PARTITION BY acquisition_channel
                ORDER BY months_since_acquisition), 2) AS cumulative_gp
FROM order_tagged
WHERE months_since_acquisition BETWEEN 0 AND 12
GROUP BY 1, 2
ORDER BY 1, 2;