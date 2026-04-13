# 🛍️ D2C Customer Profitability & Cohort Unit Economics Intelligence

> **End-to-end business analytics system** that identifies which customers, channels, and cohorts are truly profitable for a D2C brand - after accounting for acquisition cost, returns, and all variable costs.

---

## Business Problem

A fast-growing D2C health & wellness brand is scaling revenue 40% month-over-month but burning cash. Leadership believes the business will become profitable "once customers come back." But nobody has answered:

- Which acquisition channels produce customers who actually pay back their CAC?
- Are any cohorts profitable at Month 6 or Month 12?
- What is the true net profit per customer after returns and acquisition cost?
- Which customers are about to churn — and which are worth saving?

This project builds a complete intelligence system to answer all four questions with data.

---

## Architecture

Raw Data (Simulated)
│
▼
┌───────────────────┐
│  Python           │  Dataset generation (5 tables, 8K customers,
│  generate.py      │  12K orders, 36 months)
└────────┬──────────┘
│
▼
┌───────────────────┐
│  PostgreSQL       │  6 SQL analysis scripts - cohort logic,
│  d2c_analytics    │  LTV:CAC, profitability, returns, marketing
└────────┬──────────┘
│
▼
┌───────────────────┐
│  Python           │  EDA, cohort heatmap, RFM clustering,
│  Jupyter Notebook │  churn prediction model (Random Forest)
└────────┬──────────┘
│
▼
┌───────────────────┐
│  Power BI         │  5-page interactive dashboard
│  Dashboard        │  for business stakeholders
└───────────────────┘

---

## Dataset

Simulated dataset modelled after a real Indian D2C brand. All data is generated using Python with realistic business logic.

| Table | Rows | Description |
|---|---|---|
| `customers` | 8,000 | Customer master with acquisition channel, CAC, city, demographics |
| `orders` | 12,208 | 36 months of order history with revenue, COGS, discount |
| `order_items` | 18,340 | Product-level line items per order |
| `marketing_spend` | 216 | Monthly spend, impressions, clicks, CAC by channel |
| `returns` | 1,313 | Return transactions with refund, logistics, restocking cost |

**Channels:** Paid Instagram, Paid Google, Influencer, Organic Search, Email Referral, Direct

**Categories:** Skincare, Haircare, Supplements, Personal Care

---

## Key Business Metrics

| Metric | Definition |
|---|---|
| **True Net Profit** | Gross Profit - Acquisition CAC − Return Costs |
| **LTV:CAC Ratio** | Avg Customer Gross Profit ÷ Avg Acquisition Cost |
| **CAC Payback Period** | Orders needed to recover acquisition cost |
| **Cohort Retention Rate** | % of acquisition cohort still active at Month N |
| **Return Rate %** | Returns ÷ Total Orders |
| **Repeat Purchase Rate** | Customers with 2+ orders ÷ Total Customers |
| **RFM Segments** | Champions, Loyalists, At Risk, Lost/Dormant |
| **Churn Probability** | Random Forest score (ROC-AUC: 0.797) |

---

## Key Findings

### LTV:CAC by Channel

| Channel | LTV:CAC Ratio | Health |
|---|---|---|
| Direct | 17.07x | ✅ Exceptional |
| Organic Search | 7.74x | ✅ Excellent |
| Email Referral | 6.55x | ✅ Excellent |
| Paid Google | 1.62x | ⚠️ Marginal |
| Paid Instagram | 1.17x | ⚠️ Barely Viable |
| Influencer | 0.73x | ❌ Value Destroying |

### Business Recommendations

1. **Reallocate influencer budget** - 0.73x LTV:CAC means every ₹1 spent returns ₹0.73. Shift 30% of influencer spend to SEO and email retention programs.

2. **Organic and Direct channels are underinvested** - 17x and 7.7x LTV:CAC respectively, yet receive the lowest marketing spend. Content and community investment would generate disproportionate returns.

3. **Payback period insight** - Direct and Organic customers pay back their acquisition cost within the first order. Influencer customers require 3 orders - most never reach that threshold.

4. **Cohort profitability** - Early 2022 cohorts show 35–40% Month 6 retention. 2024 cohorts show declining retention at Month 3, suggesting product-market fit erosion or audience saturation in paid channels.

5. **Churn model** — Purchase frequency and total gross profit are the strongest churn predictors. Customers with fewer than 2 orders and GP below ₹500 have 78%+ churn probability. Early intervention at Day 45 post-purchase is recommended.

---

## Tech Stack

| Tool | Usage |
|---|---|
| **Python 3.10** | Data generation, EDA, modeling |
| **Pandas / NumPy** | Data manipulation |
| **Scikit-learn** | K-Means clustering, Random Forest churn model |
| **Matplotlib / Seaborn** | Analysis visualizations |
| **PostgreSQL** | Data warehouse, SQL analysis layer |
| **SQLAlchemy / psycopg2** | Python-PostgreSQL connector |
| **Power BI Desktop** | 5-page interactive dashboard |
| **DAX** | Calculated measures and KPIs |
| **Jupyter Notebook** | Analysis and modeling environment |

---

## Project Structure

d2c-cohort-unit-economics-intelligence/
│
├── data/
│   ├── raw/
│   │   ├── generate_dataset.py       # Generates all 5 tables
│   │   ├── load_to_postgres.py       # Loads CSVs into PostgreSQL
│   │   ├── customers.csv
│   │   ├── orders.csv
│   │   ├── order_items.csv
│   │   ├── marketing_spend.csv
│   │   └── returns.csv
│   ├── processed/
│   │   └── customer_profitability.csv
│   └── exports/                      # Power BI source files
│       ├── dim_customers.csv
│       ├── fact_orders.csv
│       ├── fact_returns.csv
│       ├── fact_marketing.csv
│       ├── cohort_retention.csv
│       ├── customer_profitability_full.csv
│       ├── rfm_segments.csv
│       ├── ltv_cac_by_channel.csv
│       └── customer_churn_scores.csv
│
├── notebooks/
│   └── 01_eda_and_modeling.ipynb     # Full analysis notebook
│
├── sql/
│   ├── 01_customer_acquisition_analysis.sql
│   ├── 02_cohort_analysis.sql
│   ├── 03_ltv_cac_analysis.sql
│   ├── 04_customer_profitability.sql
│   ├── 05_returns_analysis.sql
│   └── 06_marketing_efficiency.sql
│
├── powerbi/
│   └── D2C_Cohort_Unit_Economics.pbix
│
├── assets/
│   ├── 01_acquisition_eda.png
│   ├── 02_cohort_retention_heatmap.png
│   ├── 03_ltv_cac_analysis.png
│   ├── 04_rfm_segmentation.png
│   └── 05b_churn_model_clean.png
│
├── reports/
│   └── business_brief.pdf
│
├── requirements.txt
└── README.md

---

## How to Run

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/d2c-cohort-unit-economics-intelligence.git
cd d2c-cohort-unit-economics-intelligence
```

### 2. Set up environment
```bash
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Generate dataset
```bash
cd data/raw
python generate_dataset.py
```

### 4. Load into PostgreSQL
```bash
# Update DB credentials in load_to_postgres.py first
python load_to_postgres.py
```

### 5. Run SQL analysis

Open pgAdmin → d2c_cohort_analytics database
Run scripts in sql/ folder in order (01 through 06)

### 6. Run Python notebook
```bash
cd notebooks
jupyter notebook
# Open 01_eda_and_modeling.ipynb and run all cells
```

### 7. Open Power BI Dashboard

Open powerbi/D2C_Cohort_Unit_Economics.pbix in Power BI Desktop
Refresh data source paths if needed

---

## Dashboard Pages

| Page | Content |
|---|---|
| **1. Executive Summary** | Revenue, True Net Profit, LTV:CAC, Gross Margin KPIs + trend visuals |
| **2. Cohort & Retention** | Retention heatmap, cohort revenue curves, average retention trend |
| **3. LTV & CAC Intelligence** | LTV:CAC by channel, CAC vs LTV bubble chart, payback period |
| **4. Customer Profitability** | RFM segments, profit distribution, churn risk scatter |
| **5. Returns & Marketing** | Return rate by channel, return reasons, marketing spend efficiency |

---

## Requirements

pandas==2.0.3
numpy==1.24.3
faker==19.6.2
scipy==1.11.2
scikit-learn==1.3.0
matplotlib==3.7.2
seaborn==0.12.2
plotly==5.16.1
openpyxl==3.1.2
sqlalchemy==2.0.20
psycopg2-binary==2.9.7
lifetimes==0.11.3
statsmodels==0.14.0
jupyter==1.0.0

---

## Author

**Mohsin Raza**
Aspiring Business / BI Data Analyst

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/mohsinraza-data/)
[![Email](https://img.shields.io/badge/Email-Contact-EA4335?style=for-the-badge&logo=gmail&logoColor=white)](mailto:mohsinansari1799@gmail.com)

---

## License

MIT License - free to use, modify, and distribute with attribution.
