# Telco Customer Churn Analysis

A SQL-driven exploratory analysis of customer churn for a telecom company,
using the [IBM Telco Customer Churn dataset](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)
(7,043 customers, 21 attributes). The goal: find out **who churns, why, and
how much revenue it costs** — using SQL queries and a set of chart visuals
that together act as a lightweight dashboard.

## Project Structure

```
telco-customer-churn-analysis/
├── README.md
├── telco_churn_clean.csv       # Cleaned dataset used for all analysis
├── analysis_queries.sql        # 12 SQL queries answering key churn questions
├── churn_distribution.png      # Chart: overall churn split
├── churn_by_contract.png       # Chart: churn rate by contract type
├── churn_by_internet.png       # Chart: churn rate by internet service
├── churn_by_payment.png        # Chart: churn rate by payment method
└── churn_by_tenure.png         # Chart: churn rate by tenure group
```

## Data Cleaning

The raw dataset has one quirk: `TotalCharges` is stored as text and has 11
blank values for brand-new customers (`tenure = 0`). The cleaning step:
- Converts `TotalCharges` to numeric.
- Fills blanks with `MonthlyCharges × tenure` (a fair estimate for new
  customers).
- Recodes `SeniorCitizen` from `0/1` to `No/Yes` for readability in SQL
  and BI tools.
- Adds a `TenureGroup` column (`0-1 yr`, `1-2 yr`, `2-4 yr`, `4-5 yr`,
  `5+ yr`) to make tenure-based grouping easy in SQL.

The result, `telco_churn_clean.csv`, has **0 missing values** across all
7,043 rows and 22 columns.

## SQL Analysis

`analysis_queries.sql` contains 12 queries (tested and verified against the
cleaned data), covering:

1. Overall churn rate
2. Churn rate by contract type
3. Churn rate by internet service type
4. Churn rate by payment method
5. Churn rate by tenure group
6. Average charges: churned vs. retained customers
7. Estimated monthly/annual revenue at risk from churn
8. Impact of Online Security + Tech Support on churn
9. Churn by senior citizen status and dependents
10. Top 10 highest-value churned customers (win-back list)
11. Paperless billing vs. churn
12. Number of bundled add-on services vs. churn

The queries are written in standard SQL (tested on SQLite) and work with
minor tweaks on MySQL/PostgreSQL as well — load `telco_churn_clean.csv`
into a table called `customers` and run them directly.

## Key Findings

**Overall churn rate: 26.5%** (1,869 of 7,043 customers churned)

| Dimension | Highest-risk segment | Churn rate |
|---|---|---|
| Contract type | Month-to-month | **42.7%** (vs. 11.3% one-year, 2.8% two-year) |
| Internet service | Fiber optic | **41.9%** (vs. 19.0% DSL, 7.4% no internet) |
| Payment method | Electronic check | **45.3%** (vs. 15–19% for other methods) |
| Tenure | Under 1 year | **47.4%** (drops steadily to 6.6% for 5+ year customers) |

**Revenue impact**: churned customers represented **$139,131 in lost
monthly recurring revenue**, or roughly **$1.67M annualized**.

**Service bundling matters**: customers without Online Security or Tech
Support churn at a much higher rate than those with both add-ons —
suggesting bundling is a viable retention lever, not just an upsell.

## Business Recommendations

1. **Push month-to-month customers onto annual contracts** (via discounts
   or perks) — this is the single largest churn driver in the data.
2. **Investigate fiber optic service quality/pricing** — churn there is
   more than double the DSL rate.
3. **Incentivize a move away from electronic check** payments toward
   automatic bank transfer or credit card, which show much lower churn.
4. **Target the first 12 months** of the customer lifecycle with proactive
   retention outreach — that's where churn risk is highest.
5. **Bundle security/support add-ons** into base plans for new customers to
   increase stickiness early on.

## How to Reproduce

1. Load `telco_churn_clean.csv` into SQLite (or any SQL database):
   ```bash
   sqlite3 telco_churn.db
   .mode csv
   .import telco_churn_clean.csv customers
   ```
2. Run the queries in `analysis_queries.sql` against that table.
3. Charts were generated with Python (pandas + matplotlib/seaborn) directly
   from the same cleaned CSV, using the same groupings as the SQL queries
   above.

## Tech Stack

SQL (SQLite-compatible) · Python (pandas, matplotlib, seaborn) for
visualization

## License

MIT
