-- ═══════════════════════════════════════════════════════════
-- SCRIPT 05: RETURNS IMPACT ANALYSIS
-- Business Question: How much are returns truly costing us
-- and which segments drive the most return damage?
-- ═══════════════════════════════════════════════════════════

-- ─────────────────────────────────────────
-- 5A: Overall return metrics
-- ─────────────────────────────────────────
SELECT
    COUNT(DISTINCT r.return_id)                 AS total_returns,
    COUNT(DISTINCT o.order_id)                  AS total_orders,
    ROUND(COUNT(DISTINCT r.return_id) * 100.0
          / COUNT(DISTINCT o.order_id), 2)      AS return_rate_pct,
    ROUND(SUM(r.refund_amount), 2)              AS total_refunds,
    ROUND(SUM(r.reverse_logistics), 2)          AS total_reverse_logistics,
    ROUND(SUM(r.restocking_cost), 2)            AS total_restocking,
    ROUND(SUM(r.net_return_cost), 2)            AS total_return_cost,
    ROUND(AVG(r.net_return_cost), 2)            AS avg_cost_per_return
FROM orders o
LEFT JOIN returns r ON o.order_id = r.order_id;


-- ─────────────────────────────────────────
-- 5B: Return rate and cost by acquisition channel
-- ─────────────────────────────────────────
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id)                  AS total_orders,
    COUNT(DISTINCT r.return_id)                 AS total_returns,
    ROUND(COUNT(DISTINCT r.return_id) * 100.0
          / COUNT(DISTINCT o.order_id), 2)      AS return_rate_pct,
    ROUND(SUM(r.net_return_cost), 2)            AS total_return_cost,
    ROUND(AVG(r.net_return_cost), 2)            AS avg_return_cost
FROM orders o
JOIN customers c    ON o.customer_id = c.customer_id
LEFT JOIN returns r ON o.order_id = r.order_id
GROUP BY c.acquisition_channel
ORDER BY return_rate_pct DESC;


-- ─────────────────────────────────────────
-- 5C: Return reason breakdown
-- ─────────────────────────────────────────
SELECT
    return_reason,
    COUNT(*)                                    AS return_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_returns,
    ROUND(SUM(net_return_cost), 2)              AS total_cost,
    ROUND(AVG(net_return_cost), 2)              AS avg_cost
FROM returns
GROUP BY return_reason
ORDER BY return_count DESC;


-- ─────────────────────────────────────────
-- 5D: Monthly return trend
-- ─────────────────────────────────────────
SELECT
    TO_CHAR(r.return_date, 'YYYY-MM')           AS return_month,
    COUNT(*)                                    AS returns,
    ROUND(SUM(r.net_return_cost), 2)            AS monthly_return_cost
FROM returns r
GROUP BY 1
ORDER BY 1;