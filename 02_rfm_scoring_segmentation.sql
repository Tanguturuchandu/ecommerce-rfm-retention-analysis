-- =====================================================================
-- FILE 2 of 2: RFM CALCULATION + SCORING + SEGMENTATION
-- Project: E-commerce Customer Retention Analysis using RFM Segmentation
-- Database: MySQL
-- Input:  online_retail_clean (from File 1)
-- Output: customer_rfm (Recency/Frequency/Monetary + RFM scores + segment)
-- =====================================================================

USE retail_rfm;

-- ---------------------------------------------------------------------
-- 1. Find the analysis date (one day after the last transaction)
-- ---------------------------------------------------------------------
SELECT DATE_ADD(MAX(InvoiceDate), INTERVAL 1 DAY) AS analysis_date
FROM online_retail_clean;
-- Confirm this matches 2011-12-10 before running the next block.
-- If it differs, update the DATEDIFF date below to match.

-- ---------------------------------------------------------------------
-- 2. Calculate raw RFM metrics + NTILE scores + segment, all in one pass
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS customer_rfm;

CREATE TABLE customer_rfm AS
WITH rfm_raw AS (
    SELECT
        CustomerID,
        DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS Recency,
        COUNT(DISTINCT InvoiceNo)                AS Frequency,
        ROUND(SUM(TotalPrice), 2)                AS Monetary,
        MIN(InvoiceDate) AS FirstPurchaseDate,
        MAX(InvoiceDate) AS LastPurchaseDate
    FROM online_retail_clean
    GROUP BY CustomerID
),
rfm_scored AS (
    SELECT
        *,
        -- NTILE splits customers into 5 even buckets.
        -- Recency: LOWER days = BETTER, so we reverse the bucket order (6 - n)
        -- so that Score 5 = most recent, Score 1 = most lapsed.
        (6 - NTILE(5) OVER (ORDER BY Recency))   AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency)       AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary)        AS M_Score
    FROM rfm_raw
)
SELECT
    *,
    CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,
    CASE
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
        WHEN R_Score >= 3 AND F_Score >= 3                   THEN 'Loyal Customers'
        WHEN R_Score >= 4 AND F_Score <= 2                   THEN 'New Customers'
        WHEN R_Score >= 3 AND F_Score <= 2 AND M_Score >= 3  THEN 'Potential Loyalist'
        WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4  THEN 'At Risk'
        WHEN R_Score <= 2 AND F_Score >= 3                   THEN 'Cant Lose Them'
        WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2  THEN 'Hibernating'
        WHEN R_Score = 1 AND F_Score = 1                     THEN 'Lost'
        ELSE 'Needs Attention'
    END AS Segment
FROM rfm_scored;

-- ---------------------------------------------------------------------
-- 3. Verify
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS total_customers FROM customer_rfm;   -- expect ~4,300+

SELECT
    MIN(Recency)   AS min_recency,   MAX(Recency)   AS max_recency,
    MIN(Frequency) AS min_frequency, MAX(Frequency) AS max_frequency,
    MIN(Monetary)  AS min_monetary,  MAX(Monetary)  AS max_monetary
FROM customer_rfm;

-- Segment distribution + revenue contribution (this feeds the dashboard)
SELECT
    Segment,
    COUNT(*)                                    AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_customers,
    ROUND(SUM(Monetary), 2)                     AS total_revenue,
    ROUND(SUM(Monetary) * 100.0 / SUM(SUM(Monetary)) OVER (), 1) AS pct_of_revenue,
    ROUND(AVG(Monetary), 2)                     AS avg_customer_value
FROM customer_rfm
GROUP BY Segment
ORDER BY total_revenue DESC;

-- High-value customers at risk of churning (flag for retention action)
SELECT CustomerID, Recency, Frequency, Monetary, RFM_Score, Segment
FROM customer_rfm
WHERE Segment IN ('At Risk', 'Cant Lose Them')
ORDER BY Monetary DESC;