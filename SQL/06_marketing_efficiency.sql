-- ═══════════════════════════════════════════════════════════
-- SCRIPT 06: MARKETING SPEND EFFICIENCY
-- Business Question: Which channels give the best return
-- on marketing spend month over month?
-- ═══════════════════════════════════════════════════════════

-- ─────────────────────────────────────────
-- 6A: Channel-wise spend vs revenue generated
-- ─────────────────────────────────────────
WITH channel_revenue AS (
    SELECT
        c.acquisition_channel,
        TO_CHAR(o.order_date, 'YYYY-MM')        AS order_month,
        SUM(o.order_revenue)                    AS revenue,
        SUM(o.gross_profit)                     AS gross_profit
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY 1, 2
)
SELECT
    ms.channel,
    ms.month,
    ms.spend_inr,
    ms.new_customers_acquired,
    ms.cac_realized,
    ms.impressions,
    ms.clicks,
    ms.cpm,
    ms.cpc,
    COALESCE(cr.revenue, 0)                     AS revenue_from_new_customers,
    COALESCE(cr.gross_profit, 0)                AS gp_from_new_customers,
    ROUND(COALESCE(cr.revenue, 0)
          / NULLIF(ms.spend_inr, 0), 2)         AS roas
FROM marketing_spend ms
LEFT JOIN channel_revenue cr
    ON ms.channel = cr.acquisition_channel
    AND ms.month  = cr.order_month
ORDER BY ms.month, ms.channel;


-- ─────────────────────────────────────────
-- 6B: Annual marketing efficiency summary
-- ─────────────────────────────────────────
SELECT
    channel,
    SUBSTRING(month, 1, 4)                      AS year,
    ROUND(SUM(spend_inr), 2)                    AS total_spend,
    SUM(new_customers_acquired)                 AS total_new_customers,
    ROUND(SUM(spend_inr)
          / NULLIF(SUM(new_customers_acquired), 0), 2) AS blended_cac,
    SUM(impressions)                            AS total_impressions,
    SUM(clicks)                                 AS total_clicks,
    ROUND(SUM(clicks) * 100.0
          / NULLIF(SUM(impressions), 0), 3)     AS avg_ctr_pct
FROM marketing_spend
GROUP BY 1, 2
ORDER BY 2, total_spend DESC;