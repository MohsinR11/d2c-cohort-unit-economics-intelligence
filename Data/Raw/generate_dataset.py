import pandas as pd
import numpy as np
from faker import Faker
from datetime import datetime, timedelta
import random
import os

fake = Faker('en_IN')
np.random.seed(42)
random.seed(42)

# ────────────────────────────────────────────
# CONFIG
# ────────────────────────────────────────────
START_DATE = datetime(2022, 1, 1)
END_DATE   = datetime(2024, 12, 31)
N_CUSTOMERS = 8000

CHANNELS = ['Paid Instagram', 'Paid Google', 'Influencer', 'Organic Search', 'Email Referral', 'Direct']

CHANNEL_CAC = {
    'Paid Instagram':   (800,  1400),
    'Paid Google':      (600,  1100),
    'Influencer':       (1100, 2200),
    'Organic Search':   (100,  300),
    'Email Referral':   (150,  350),
    'Direct':           (50,   150),
}

CATEGORIES = ['Skincare', 'Haircare', 'Supplements', 'Personal Care']

PRODUCTS = {
    'Skincare':      [('Vitamin C Serum', 899, 180), ('SPF 50 Sunscreen', 599, 110),
                      ('Retinol Night Cream', 1199, 240), ('Face Wash Gel', 349, 60),
                      ('Hyaluronic Moisturizer', 799, 150)],
    'Haircare':      [('Biotin Hair Serum', 699, 130), ('Anti-Dandruff Shampoo', 449, 80),
                      ('Keratin Hair Mask', 899, 160), ('Onion Hair Oil', 549, 90),
                      ('Scalp Scrub', 399, 70)],
    'Supplements':   [('Collagen Powder', 1499, 320), ('Biotin Tablets 10000mcg', 799, 150),
                      ('Vitamin D3 + K2', 699, 120), ('Iron + Folic Acid', 499, 85),
                      ('Omega 3 Fish Oil', 899, 170)],
    'Personal Care': [('Charcoal Body Wash', 399, 70), ('Intimate Wash', 449, 80),
                      ('Deodorant Roll-On', 299, 50), ('Lip Balm SPF 15', 199, 35),
                      ('Hand Cream Repair', 349, 60)],
}

CHANNEL_REPEAT_PROB = {
    'Paid Instagram':  0.28,
    'Paid Google':     0.33,
    'Influencer':      0.22,
    'Organic Search':  0.42,
    'Email Referral':  0.45,
    'Direct':          0.50,
}

CHANNEL_RETURN_PROB = {
    'Paid Instagram':  0.14,
    'Paid Google':     0.11,
    'Influencer':      0.18,
    'Organic Search':  0.08,
    'Email Referral':  0.07,
    'Direct':          0.06,
}

# ────────────────────────────────────────────
# TABLE 1 - CUSTOMERS
# ────────────────────────────────────────────
print("Generating customers...")

def random_date(start, end):
    return start + timedelta(days=random.randint(0, (end - start).days))

cities = ['Mumbai', 'Delhi', 'Bengaluru', 'Hyderabad', 'Chennai',
          'Pune', 'Ahmedabad', 'Kolkata', 'Jaipur', 'Lucknow',
          'Surat', 'Chandigarh', 'Kochi', 'Indore', 'Nagpur']

city_tier = {
    'Mumbai': 'Tier 1', 'Delhi': 'Tier 1', 'Bengaluru': 'Tier 1',
    'Hyderabad': 'Tier 1', 'Chennai': 'Tier 1', 'Pune': 'Tier 1',
    'Ahmedabad': 'Tier 1', 'Kolkata': 'Tier 1',
    'Jaipur': 'Tier 2', 'Lucknow': 'Tier 2', 'Surat': 'Tier 2',
    'Chandigarh': 'Tier 2', 'Kochi': 'Tier 2',
    'Indore': 'Tier 3', 'Nagpur': 'Tier 3',
}

customers = []
for i in range(1, N_CUSTOMERS + 1):
    channel   = random.choices(CHANNELS, weights=[25, 20, 15, 18, 12, 10])[0]
    acq_date  = random_date(START_DATE, datetime(2024, 6, 30))
    city      = random.choices(cities, weights=[14,13,12,9,8,8,7,6,5,4,4,3,3,2,2])[0]
    cac_lo, cac_hi = CHANNEL_CAC[channel]
    cac       = round(random.uniform(cac_lo, cac_hi), 2)
    age       = random.randint(18, 52)
    gender    = random.choices(['Female', 'Male', 'Other'], weights=[62, 35, 3])[0]

    customers.append({
        'customer_id':        f'CUST{i:05d}',
        'acquisition_date':   acq_date.date(),
        'acquisition_channel':channel,
        'acquisition_cac':    cac,
        'city':               city,
        'city_tier':          city_tier[city],
        'age':                age,
        'gender':             gender,
        'preferred_category': random.choice(CATEGORIES),
    })

customers_df = pd.DataFrame(customers)
print(f"  Customers: {len(customers_df)}")

# ────────────────────────────────────────────
# TABLE 2 - ORDERS + TABLE 3 - ORDER ITEMS
# ────────────────────────────────────────────
print("Generating orders and order items...")

orders      = []
order_items = []
order_id    = 1

SHIPPING_COST  = 60
PAYMENT_MODES  = ['UPI', 'Credit Card', 'Debit Card', 'COD', 'Wallet']
PAYMENT_WEIGHTS= [38, 22, 18, 15, 7]

for _, cust in customers_df.iterrows():
    cid          = cust['customer_id']
    channel      = cust['acquisition_channel']
    acq_date     = pd.to_datetime(cust['acquisition_date'])
    repeat_prob  = CHANNEL_REPEAT_PROB[channel]
    pref_cat     = cust['preferred_category']

    # first order - within 3 days of acquisition
    order_date = acq_date + timedelta(days=random.randint(0, 3))
    if order_date.date() > END_DATE.date():
        continue

    session_orders = [order_date]

    # generate repeat purchases
    current_date = order_date
    while True:
        if random.random() > repeat_prob:
            break
        gap = random.randint(25, 120)
        current_date = current_date + timedelta(days=gap)
        if current_date.date() > END_DATE.date():
            break
        session_orders.append(current_date)
        repeat_prob = max(repeat_prob - 0.03, 0.08)   # slight decay

    for o_date in session_orders:
        oid = f'ORD{order_id:07d}'
        n_items  = random.choices([1, 2, 3], weights=[60, 30, 10])[0]
        discount = round(random.choices(
            [0, 0.05, 0.10, 0.15, 0.20],
            weights=[30, 20, 25, 15, 10])[0], 2)
        payment  = random.choices(PAYMENT_MODES, weights=PAYMENT_WEIGHTS)[0]

        order_revenue  = 0
        order_cogs     = 0

        for item_seq in range(1, n_items + 1):
            # pick category - 70% preferred, 30% random
            cat = pref_cat if random.random() < 0.70 else random.choice(CATEGORIES)
            prod_name, mrp, cogs = random.choice(PRODUCTS[cat])
            qty      = random.choices([1, 2, 3], weights=[70, 20, 10])[0]
            unit_sp  = round(mrp * (1 - discount), 2)
            line_rev = round(unit_sp * qty, 2)
            line_cog = round(cogs  * qty, 2)

            order_revenue += line_rev
            order_cogs    += line_cog

            order_items.append({
                'order_item_id':  f'ITEM{order_id:07d}{item_seq}',
                'order_id':       oid,
                'customer_id':    cid,
                'product_name':   prod_name,
                'category':       cat,
                'mrp':            mrp,
                'selling_price':  unit_sp,
                'quantity':       qty,
                'line_revenue':   line_rev,
                'line_cogs':      line_cog,
            })

        order_revenue = round(order_revenue, 2)
        order_cogs    = round(order_cogs, 2)
        gross_profit  = round(order_revenue - order_cogs - SHIPPING_COST, 2)

        orders.append({
            'order_id':        oid,
            'customer_id':     cid,
            'order_date':      o_date.date(),
            'order_month':     o_date.strftime('%Y-%m'),
            'order_year':      o_date.year,
            'order_revenue':   order_revenue,
            'order_cogs':      order_cogs,
            'shipping_cost':   SHIPPING_COST,
            'discount_pct':    discount,
            'gross_profit':    gross_profit,
            'payment_mode':    payment,
            'is_first_order':  1 if o_date == session_orders[0] else 0,
        })
        order_id += 1

orders_df      = pd.DataFrame(orders)
order_items_df = pd.DataFrame(order_items)
print(f"  Orders: {len(orders_df)} | Order Items: {len(order_items_df)}")

# ────────────────────────────────────────────
# TABLE 4 - MARKETING SPEND
# ────────────────────────────────────────────
print("Generating marketing spend...")

marketing = []
current = START_DATE
while current <= END_DATE:
    month_str = current.strftime('%Y-%m')
    for ch in CHANNELS:
        base = {
            'Paid Instagram':  280000,
            'Paid Google':     220000,
            'Influencer':      180000,
            'Organic Search':  30000,
            'Email Referral':  20000,
            'Direct':          10000,
        }[ch]
        growth   = 1 + ((current - START_DATE).days / 365) * 0.15
        seasonal = 1.25 if current.month in [10, 11, 12] else (0.85 if current.month in [1, 2] else 1.0)
        spend    = round(base * growth * seasonal * random.uniform(0.90, 1.10), 2)
        impressions = int(spend * random.uniform(4.5, 7.5))
        clicks      = int(impressions * random.uniform(0.015, 0.045))
        new_custs   = len(customers_df[
            (customers_df['acquisition_channel'] == ch) &
            (customers_df['acquisition_date'].astype(str).str.startswith(month_str))
        ])

        marketing.append({
            'month':            month_str,
            'channel':          ch,
            'spend_inr':        spend,
            'impressions':      impressions,
            'clicks':           clicks,
            'new_customers_acquired': new_custs,
            'cpm':              round((spend / impressions) * 1000, 2) if impressions > 0 else 0,
            'cpc':              round(spend / clicks, 2) if clicks > 0 else 0,
            'cac_realized':     round(spend / new_custs, 2) if new_custs > 0 else 0,
        })
    current = (current.replace(day=1) + timedelta(days=32)).replace(day=1)

marketing_df = pd.DataFrame(marketing)
print(f"  Marketing rows: {len(marketing_df)}")

# ────────────────────────────────────────────
# TABLE 5 - RETURNS
# ────────────────────────────────────────────
print("Generating returns...")

returns = []
for _, order in orders_df.iterrows():
    channel      = customers_df.loc[
        customers_df['customer_id'] == order['customer_id'],
        'acquisition_channel'].values[0]
    return_prob  = CHANNEL_RETURN_PROB[channel]
    if random.random() < return_prob:
        return_days = random.randint(2, 15)
        return_date = pd.to_datetime(order['order_date']) + timedelta(days=return_days)
        if return_date.date() <= END_DATE.date():
            return_reason = random.choices(
                ['Product damaged', 'Wrong item', 'Not as described',
                 'Quality issue', 'Changed mind', 'Allergic reaction'],
                weights=[20, 15, 25, 20, 12, 8])[0]
            refund_amt = round(order['order_revenue'] * random.uniform(0.85, 1.0), 2)
            returns.append({
                'return_id':        f'RET{len(returns)+1:06d}',
                'order_id':         order['order_id'],
                'customer_id':      order['customer_id'],
                'return_date':      return_date.date(),
                'return_reason':    return_reason,
                'refund_amount':    refund_amt,
                'reverse_logistics':80,
                'restocking_cost':  round(order['order_cogs'] * 0.05, 2),
                'net_return_cost':  round(refund_amt + 80 + order['order_cogs'] * 0.05, 2),
            })

returns_df = pd.DataFrame(returns)
print(f"  Returns: {len(returns_df)}")

# ────────────────────────────────────────────
# SAVE ALL FILES
# ────────────────────────────────────────────
print("\nSaving files...")
out = os.path.join(os.path.dirname(__file__), '')

customers_df.to_csv(  out + 'customers.csv',    index=False)
orders_df.to_csv(     out + 'orders.csv',        index=False)
order_items_df.to_csv(out + 'order_items.csv',   index=False)
marketing_df.to_csv(  out + 'marketing_spend.csv',index=False)
returns_df.to_csv(    out + 'returns.csv',        index=False)

print("\n✅ All 5 datasets saved to data/raw/")
print(f"   customers.csv       → {len(customers_df):,} rows")
print(f"   orders.csv          → {len(orders_df):,} rows")
print(f"   order_items.csv     → {len(order_items_df):,} rows")
print(f"   marketing_spend.csv → {len(marketing_df):,} rows")
print(f"   returns.csv         → {len(returns_df):,} rows")