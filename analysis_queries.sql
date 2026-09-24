/* =====================================================================
   analysis_queries.sql
   Telco Customer Churn Analysis
   -----------------------------------------------------------------
   Table: customers  (loaded from telco_churn_clean.csv)
   Tested against SQLite; standard ANSI SQL, works on MySQL/Postgres
   too with minor syntax tweaks (e.g. ROUND, CAST) noted where relevant.
   ===================================================================== */


/* ---------------------------------------------------------------------
   1. OVERALL CHURN RATE
   How many customers churned vs. stayed, and what % of the base is that?
   --------------------------------------------------------------------- */
SELECT
    Churn,
    COUNT(*)                                              AS num_customers,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customers), 2) AS pct_of_total
FROM customers
GROUP BY Churn;


/* ---------------------------------------------------------------------
   2. CHURN RATE BY CONTRACT TYPE
   Month-to-month customers are expected to churn far more than
   customers locked into 1-year or 2-year contracts.
   --------------------------------------------------------------------- */
SELECT
    Contract,
    COUNT(*)                                              AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)        AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY Contract
ORDER BY churn_rate_pct DESC;


/* ---------------------------------------------------------------------
   3. CHURN RATE BY INTERNET SERVICE TYPE
   Fiber optic customers are a known high-churn segment in this dataset.
   --------------------------------------------------------------------- */
SELECT
    InternetService,
    COUNT(*)                                              AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)        AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;


/* ---------------------------------------------------------------------
   4. CHURN RATE BY PAYMENT METHOD
   Electronic check payers typically show the highest churn.
   --------------------------------------------------------------------- */
SELECT
    PaymentMethod,
    COUNT(*)                                              AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)        AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;


/* ---------------------------------------------------------------------
   5. CHURN RATE BY TENURE GROUP
   Newer customers (under a year) are the highest-risk segment.
   --------------------------------------------------------------------- */
SELECT
    TenureGroup,
    COUNT(*)                                              AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)        AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY TenureGroup
ORDER BY
    CASE TenureGroup
        WHEN '0-1 yr' THEN 1
        WHEN '1-2 yr' THEN 2
        WHEN '2-4 yr' THEN 3
        WHEN '4-5 yr' THEN 4
        WHEN '5+ yr'  THEN 5
    END;


/* ---------------------------------------------------------------------
   6. AVERAGE MONTHLY & TOTAL CHARGES: CHURNED vs. RETAINED
   Are churners paying more or less, on average, than loyal customers?
   --------------------------------------------------------------------- */
SELECT
    Churn,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
    ROUND(AVG(TotalCharges), 2)   AS avg_total_charges,
    ROUND(AVG(tenure), 1)         AS avg_tenure_months
FROM customers
GROUP BY Churn;


/* ---------------------------------------------------------------------
   7. REVENUE AT RISK
   Estimated monthly recurring revenue lost due to churned customers.
   --------------------------------------------------------------------- */
SELECT
    SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END) AS monthly_revenue_lost,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END) * 12, 2
    ) AS estimated_annual_revenue_lost
FROM customers;


/* ---------------------------------------------------------------------
   8. IMPACT OF ADD-ON SERVICES ON CHURN
   Does having Online Security / Tech Support reduce churn?
   --------------------------------------------------------------------- */
SELECT
    OnlineSecurity,
    TechSupport,
    COUNT(*)                                              AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)        AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY OnlineSecurity, TechSupport
ORDER BY churn_rate_pct DESC;


/* ---------------------------------------------------------------------
   9. CHURN RATE BY SENIOR CITIZEN STATUS & DEPENDENTS
   Are seniors, or customers without dependents, more likely to churn?
   --------------------------------------------------------------------- */
SELECT
    SeniorCitizen,
    Dependents,
    COUNT(*)                                              AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)        AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY SeniorCitizen, Dependents
ORDER BY churn_rate_pct DESC;


/* ---------------------------------------------------------------------
   10. TOP 10 HIGHEST-VALUE CUSTOMERS WHO CHURNED
   Useful for a "win-back" outreach list, sorted by revenue impact.
   --------------------------------------------------------------------- */
SELECT
    customerID, Contract, InternetService, PaymentMethod,
    tenure, MonthlyCharges, TotalCharges
FROM customers
WHERE Churn = 'Yes'
ORDER BY TotalCharges DESC
LIMIT 10;


/* ---------------------------------------------------------------------
   11. PAPERLESS BILLING vs. CHURN
   --------------------------------------------------------------------- */
SELECT
    PaperlessBilling,
    COUNT(*)                                              AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)        AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY PaperlessBilling
ORDER BY churn_rate_pct DESC;


/* ---------------------------------------------------------------------
   12. NUMBER OF SERVICES SUBSCRIBED vs. CHURN
   More bundled services generally correlate with lower churn ("stickiness").
   --------------------------------------------------------------------- */
SELECT
    (CASE WHEN OnlineSecurity   = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN OnlineBackup     = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN DeviceProtection = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN TechSupport      = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN StreamingTV      = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN StreamingMovies  = 'Yes' THEN 1 ELSE 0 END) AS num_addon_services,
    COUNT(*)                                              AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)        AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY num_addon_services
ORDER BY num_addon_services;
