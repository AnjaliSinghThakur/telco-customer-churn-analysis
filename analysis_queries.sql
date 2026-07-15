-- ============================================================
-- Telco Customer Churn Analysis - SQL Queries
-- Author: Anjali Singh Thakur
-- Dataset: 7,032 customers | Table: customers
-- Source: Kaggle - Telco Customer Churn (blastchar)
-- ============================================================

-- ------------------------------------------------------------
-- 1. OVERALL CHURN RATE
-- ------------------------------------------------------------
SELECT
    Churn,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) AS percentage
FROM customers
GROUP BY Churn;


-- ------------------------------------------------------------
-- 2. CHURN RATE BY CONTRACT TYPE
-- ------------------------------------------------------------
SELECT
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY Contract
ORDER BY churn_rate_pct DESC;


-- ------------------------------------------------------------
-- 3. CHURN RATE BY INTERNET SERVICE TYPE
-- ------------------------------------------------------------
SELECT
    InternetService,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;


-- ------------------------------------------------------------
-- 4. CHURN RATE BY PAYMENT METHOD
-- ------------------------------------------------------------
SELECT
    PaymentMethod,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;


-- ------------------------------------------------------------
-- 5. TENURE (LOYALTY) vs CHURN
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN tenure <= 12 THEN '0-1 Year'
        WHEN tenure <= 24 THEN '1-2 Years'
        WHEN tenure <= 48 THEN '2-4 Years'
        ELSE '4+ Years'
    END AS tenure_bucket,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY tenure_bucket
ORDER BY MIN(tenure);


-- ------------------------------------------------------------
-- 6. SENIOR CITIZENS vs CHURN
-- ------------------------------------------------------------
SELECT
    CASE WHEN SeniorCitizen = 1 THEN 'Senior Citizen' ELSE 'Non-Senior' END AS customer_type,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY customer_type;


-- ------------------------------------------------------------
-- 7. AVERAGE MONTHLY & TOTAL CHARGES: CHURNED vs RETAINED
-- ------------------------------------------------------------
SELECT
    Churn,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
    ROUND(AVG(TotalCharges), 2)   AS avg_total_charges,
    ROUND(AVG(tenure), 1)         AS avg_tenure_months
FROM customers
GROUP BY Churn;


-- ------------------------------------------------------------
-- 8. TECH SUPPORT & ONLINE SECURITY IMPACT ON CHURN
-- ------------------------------------------------------------
SELECT
    TechSupport,
    OnlineSecurity,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY TechSupport, OnlineSecurity
ORDER BY churn_rate_pct DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 9. PAPERLESS BILLING vs CHURN
-- ------------------------------------------------------------
SELECT
    PaperlessBilling,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY PaperlessBilling;


-- ------------------------------------------------------------
-- 10. HIGHEST-RISK SEGMENT: Month-to-month + Fiber Optic + No Tech Support
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
WHERE Contract = 'Month-to-month'
  AND InternetService = 'Fiber optic'
  AND TechSupport = 'No';
