import pandas as pd
from sqlalchemy import create_engine
import os

# ── UPDATE THIS with your PostgreSQL credentials ──
DB_USER     = "postgres"
DB_PASSWORD = "NewStrongPassword%40123"
DB_HOST     = "localhost"
DB_PORT     = "5432"
DB_NAME     = "d2c_cohort_analytics"

engine = create_engine(
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

raw_path = os.path.dirname(__file__)

files = {
    "customers":       "customers.csv",
    "orders":          "orders.csv",
    "order_items":     "order_items.csv",
    "marketing_spend": "marketing_spend.csv",
    "returns":         "returns.csv",
}

# Load in correct order to respect foreign keys
load_order = ["customers", "orders", "order_items", "marketing_spend", "returns"]

print("Loading data into PostgreSQL...\n")
for table in load_order:
    df = pd.read_csv(os.path.join(raw_path, files[table]))
    df.to_sql(table, engine, if_exists="append", index=False)
    print(f"  ✅ {table:20s} → {len(df):,} rows loaded")

print("\n🎉 All tables loaded successfully into d2c_cohort_analytics")