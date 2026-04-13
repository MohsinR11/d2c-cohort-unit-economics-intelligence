-- ═══════════════════════════════════════════════════════════
-- SCRIPT 04: CUSTOMER PROFITABILITY SEGMENTATION
-- Business Question: Which customers are truly profitable
-- after accounting for CAC, returns, and all costs?
-- ═══════════════════════════════════════════════════════════

-- ─────────────────────────────────────────
-- 4A: True customer profitability (net of CAC + returns)
-- ─────────────────────────────────────────
WITH order_summary AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id)            AS total_orders,
        SUM(order_revenue)                  AS total_revenue,
        SUM(order_cogs)                     AS total_cogs,
        SUM(shipping_cost)                  AS total_shipping,
        SUM(gross_profit)                   AS total_gross_profit
    FROM orders
    GROUP BY customer_id
),
return_summary AS (
    SELECT
        customer_id,
        COUNT(*)                            AS total_returns,
        SUM(net_return_cost)                AS total_return_cost
    FROM returns
    GROUP BY customer_id
),
customer_true_profit AS (
    SELECT
        c.customer_id,
        c.acquisition_channel,
        c.acquisition_cac,
        c.city_tier,
        c.preferred_category,
        c.gender,
        CASE
            WHEN c.age BETWEEN 18 AND 24 THEN '18-24'
            WHEN c.age BETWEEN 25 AND 34 THEN '25-34'
            WHEN c.age BETWEEN 35 AND 44 THEN '35-44'
            ELSE '45+'
        END                                 AS age_band,
        COALESCE(os.total_orders, 0)        AS total_orders,
        COALESCE(os.total_revenue, 0)       AS total_revenue,
        COALESCE(os.total_gross_profit, 0)  AS total_gross_profit,
        COALESCE(rs.total_returns, 0)       AS total_returns,
        COALESCE(rs.total_return_cost, 0)   AS total_return_cost,
        -- True Net Profit = Gross Profit - CAC - Return Costs
        COALESCE(os.total_gross_profit, 0)
            - c.acquisition_cac
            - COALESCE(rs.total_return_cost, 0) AS true_net_profit
    FROM customers c
    LEFT JOIN order_summary os  ON c.customer_id = os.customer_id
    LEFT JOIN return_summary rs ON c.customer_id = rs.customer_id
)
SELECT
    *,
    CASE
        WHEN true_net_profit >= 2000  THEN 'High Value'
        WHEN true_net_profit >= 0     THEN 'Profitable'
        WHEN true_net_profit >= -1000 THEN 'Near Break-Even'
        ELSE                               'Value Destroying'
    END                                     AS profitability_segment,
    CASE
        WHEN total_orders = 0 THEN 'Never Ordered'
        WHEN total_orders = 1 THEN 'One-Time Buyer'
        WHEN total_orders BETWEEN 2 AND 3 THEN 'Occasional'
        ELSE 'Loyal'
    END                                     AS buyer_segment
FROM customer_true_profit
ORDER BY true_net_profit DESC;


-- ─────────────────────────────────────────
-- 4B: Profitability segment summary by channel
-- ─────────────────────────────────────────
WITH order_summary AS (
    SELECT customer_id,
           SUM(gross_profit)       AS total_gross_profit
    FROM orders GROUP BY customer_id
),
return_summary AS (
    SELECT customer_id,
           SUM(net_return_cost)    AS total_return_cost
    FROM returns GROUP BY customer_id
),
profit_base AS (
    SELECT
        c.customer_id,
        c.acquisition_channel,
        COALESCE(os.total_gross_profit, 0)
            - c.acquisition_cac
            - COALESCE(rs.total_return_cost, 0) AS true_net_profit
    FROM customers c
    LEFT JOIN order_summary os  ON c.customer_id = os.customer_id
    LEFT JOIN return_summary rs ON c.customer_id = rs.customer_id
)
SELECT
    acquisition_channel,
    COUNT(*)                                            AS total_customers,
    COUNT(CASE WHEN true_net_profit >= 2000 THEN 1 END) AS high_value,
    COUNT(CASE WHEN true_net_profit BETWEEN 0 AND 1999 THEN 1 END) AS profitable,
    COUNT(CASE WHEN true_net_profit BETWEEN -1000 AND -1 THEN 1 END) AS near_breakeven,
    COUNT(CASE WHEN true_net_profit < -1000 THEN 1 END) AS value_destroying,
    ROUND(AVG(true_net_profit), 2)                      AS avg_true_net_profit,
    ROUND(SUM(true_net_profit), 2)                      AS total_net_profit
FROM profit_base
GROUP BY acquisition_channel
ORDER BY total_net_profit DESC;