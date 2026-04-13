-- ─────────────────────────────────────────
-- TABLE 1: CUSTOMERS
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS customers (
    customer_id             VARCHAR(10)     PRIMARY KEY,
    acquisition_date        DATE            NOT NULL,
    acquisition_channel     VARCHAR(30)     NOT NULL,
    acquisition_cac         NUMERIC(10,2)   NOT NULL,
    city                    VARCHAR(30)     NOT NULL,
    city_tier               VARCHAR(10)     NOT NULL,
    age                     INT             NOT NULL,
    gender                  VARCHAR(10)     NOT NULL,
    preferred_category      VARCHAR(20)     NOT NULL
);

-- ─────────────────────────────────────────
-- TABLE 2: ORDERS
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    order_id                VARCHAR(12)     PRIMARY KEY,
    customer_id             VARCHAR(10)     REFERENCES customers(customer_id),
    order_date              DATE            NOT NULL,
    order_month             VARCHAR(7)      NOT NULL,
    order_year              INT             NOT NULL,
    order_revenue           NUMERIC(10,2)   NOT NULL,
    order_cogs              NUMERIC(10,2)   NOT NULL,
    shipping_cost           NUMERIC(8,2)    NOT NULL,
    discount_pct            NUMERIC(5,2)    NOT NULL,
    gross_profit            NUMERIC(10,2)   NOT NULL,
    payment_mode            VARCHAR(20)     NOT NULL,
    is_first_order          SMALLINT        NOT NULL
);

-- ─────────────────────────────────────────
-- TABLE 3: ORDER ITEMS
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id           VARCHAR(20)     PRIMARY KEY,
    order_id                VARCHAR(12)     REFERENCES orders(order_id),
    customer_id             VARCHAR(10)     REFERENCES customers(customer_id),
    product_name            VARCHAR(60)     NOT NULL,
    category                VARCHAR(20)     NOT NULL,
    mrp                     NUMERIC(8,2)    NOT NULL,
    selling_price           NUMERIC(8,2)    NOT NULL,
    quantity                INT             NOT NULL,
    line_revenue            NUMERIC(10,2)   NOT NULL,
    line_cogs               NUMERIC(10,2)   NOT NULL
);

-- ─────────────────────────────────────────
-- TABLE 4: MARKETING SPEND
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS marketing_spend (
    month                   VARCHAR(7)      NOT NULL,
    channel                 VARCHAR(30)     NOT NULL,
    spend_inr               NUMERIC(12,2)   NOT NULL,
    impressions             BIGINT          NOT NULL,
    clicks                  INT             NOT NULL,
    new_customers_acquired  INT             NOT NULL,
    cpm                     NUMERIC(10,2)   NOT NULL,
    cpc                     NUMERIC(10,2)   NOT NULL,
    cac_realized            NUMERIC(10,2)   NOT NULL,
    PRIMARY KEY (month, channel)
);

-- ─────────────────────────────────────────
-- TABLE 5: RETURNS
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS returns (
    return_id               VARCHAR(10)     PRIMARY KEY,
    order_id                VARCHAR(12)     REFERENCES orders(order_id),
    customer_id             VARCHAR(10)     REFERENCES customers(customer_id),
    return_date             DATE            NOT NULL,
    return_reason           VARCHAR(40)     NOT NULL,
    refund_amount           NUMERIC(10,2)   NOT NULL,
    reverse_logistics       NUMERIC(8,2)    NOT NULL,
    restocking_cost         NUMERIC(8,2)    NOT NULL,
    net_return_cost         NUMERIC(10,2)   NOT NULL
);



SELECT 'customers'    AS tbl, COUNT(*) AS rows FROM customers    UNION ALL
SELECT 'orders'       AS tbl, COUNT(*) AS rows FROM orders        UNION ALL
SELECT 'order_items'  AS tbl, COUNT(*) AS rows FROM order_items   UNION ALL
SELECT 'marketing'    AS tbl, COUNT(*) AS rows FROM marketing_spend UNION ALL
SELECT 'returns'      AS tbl, COUNT(*) AS rows FROM returns;