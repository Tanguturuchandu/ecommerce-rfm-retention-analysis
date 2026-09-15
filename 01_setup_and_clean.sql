-- =====================================================================
-- FILE 1 of 2: SETUP + IMPORT + CLEAN
-- Project: E-commerce Customer Retention Analysis using RFM Segmentation
-- Database: MySQL
--
-- Covers everything from an empty database to an analysis-ready
-- clean table: create DB -> staging table -> import CSV ->
-- fix date format -> build online_retail_clean.
--
-- Already run successfully once -- kept here as the single source
-- of truth / for re-running from scratch if ever needed.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS retail_rfm;
USE retail_rfm;


-- =====================================================================
-- PART 1: REBUILD STAGING TABLE (raw text date, no conversion yet)
-- =====================================================================
DROP TABLE IF EXISTS online_retail_staging;

CREATE TABLE online_retail_staging (
    InvoiceNo       VARCHAR(20),
    StockCode       VARCHAR(20),
    Description     VARCHAR(255),
    Quantity        INT,
    InvoiceDateRaw  VARCHAR(30),
    UnitPrice       DECIMAL(10,2),
    CustomerID      VARCHAR(20),
    Country         VARCHAR(100)
);

-- Import CSV -- update the file path if it changes
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/chenn/OneDrive/Desktop/CH/Online Retail - Online Retail.csv'
INTO TABLE online_retail_staging
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, InvoiceDateRaw, UnitPrice, CustomerID, Country);

SELECT COUNT(*) AS total_rows FROM online_retail_staging;   -- expect 541,909


-- =====================================================================
-- PART 2: CONVERT RAW DATE TEXT -> PROPER DATETIME
-- Confirmed format: M/D/YY H:MM (e.g. 5/6/11 11:26)
-- =====================================================================
ALTER TABLE online_retail_staging ADD COLUMN InvoiceDate DATETIME;

SET SQL_SAFE_UPDATES = 0;

UPDATE online_retail_staging
SET InvoiceDate = STR_TO_DATE(InvoiceDateRaw, '%m/%d/%y %H:%i');

SELECT COUNT(*) AS failed_conversions
FROM online_retail_staging
WHERE InvoiceDate IS NULL AND InvoiceDateRaw IS NOT NULL AND InvoiceDateRaw <> '';

SELECT MIN(InvoiceDate) AS earliest, MAX(InvoiceDate) AS latest
FROM online_retail_staging;


-- =====================================================================
-- PART 3: BUILD THE CLEAN TABLE
-- =====================================================================
DROP TABLE IF EXISTS online_retail_clean;

CREATE TABLE online_retail_clean AS
SELECT DISTINCT
    InvoiceNo,
    StockCode,
    TRIM(Description)              AS Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CAST(CustomerID AS UNSIGNED)   AS CustomerID,
    Country,
    ROUND(Quantity * UnitPrice, 2) AS TotalPrice
FROM online_retail_staging
WHERE
    InvoiceNo NOT LIKE 'C%'
    AND CustomerID IS NOT NULL AND CustomerID <> ''
    AND Quantity > 0
    AND UnitPrice > 0
    AND InvoiceDate IS NOT NULL;

ALTER TABLE online_retail_clean
    ADD INDEX idx_customer (CustomerID),
    ADD INDEX idx_invoicedate (InvoiceDate),
    ADD INDEX idx_invoiceno (InvoiceNo);


-- =====================================================================
-- PART 4: FINAL VERIFICATION
-- =====================================================================
SELECT COUNT(*) AS clean_rows FROM online_retail_clean;                        -- expect ~390,000-400,000
SELECT COUNT(DISTINCT CustomerID) AS clean_customers FROM online_retail_clean; -- expect ~4,300-4,340
SELECT MIN(InvoiceDate) AS first_txn, MAX(InvoiceDate) AS last_txn FROM online_retail_clean;
SELECT ROUND(SUM(TotalPrice), 2) AS total_revenue FROM online_retail_clean;    -- expect ~£8.9M
SELECT * FROM online_retail_clean LIMIT 10;
