# E-commerce Customer Retention Analysis using RFM Segmentation

An end-to-end data analytics project analyzing ~540,000 transactions from a UK-based
online retailer to identify customer segments, quantify revenue concentration, and
flag high-value customers at risk of churning — using SQL for data engineering and
RFM scoring, and Power BI for an interactive 3-page dashboard.

## Background

Most e-commerce businesses earn the majority of their revenue from a small share of
repeat customers, while a much larger group of one-time or lapsed buyers quietly stop
purchasing with no warning signal. Without a systematic way to identify who's
disengaging — and how valuable they are — retention budget gets wasted on low-value
customers, or high-value customers are lost before anyone notices.

## Objective

1. Segment customers by purchasing behavior (Recency, Frequency, Monetary value)
2. Identify distinct segments — Champions, Loyal, At Risk, Hibernating, Lost, etc.
3. Quantify each segment's revenue contribution
4. Flag high-value customers at risk of churning
5. Recommend targeted retention actions by segment priority

## Dataset

UCI/Kaggle **"Online Retail"** dataset (`Online_Retail_Dataset.csv`) — transactional
data from a UK-based online retailer, December 2010 to December 2011.
- 541,909 raw transactions, cleaned down to ~397K valid line items
- 4,338 unique customers after cleaning
- Columns: InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice,
  CustomerID, Country

## Tools

- **MySQL 8** (MySQL Workbench) — data cleaning, RFM calculation, scoring, segmentation
- **Power BI Desktop** — interactive dashboard and visualization

## Methodology

### 1. Data Cleaning (SQL) — `01_setup_and_clean.sql`
- Imported raw CSV into a staging table
- Fixed date parsing (source format was `M/D/YY H:MM`, required a custom
  `STR_TO_DATE` conversion after the initial import)
- Removed cancelled orders, missing CustomerIDs, and invalid quantity/price rows
- Computed `TotalPrice` per line item, built the clean `online_retail_clean` table
  with supporting indexes

### 2. RFM Calculation & Scoring (SQL) — `02_rfm_scoring_segmentation.sql`
- **Recency**: days since each customer's last purchase (relative to the day after
  the dataset's last transaction)
- **Frequency**: distinct order count per customer
- **Monetary**: total spend per customer
- Used `NTILE(5)` window functions to score each metric 1–5
- Combined R/F/M scores into named segments via `CASE` logic, producing the
  `customer_rfm` table (also exported as `customer_rfm.csv`)

### 3. Dashboard (Power BI) — `RFM_Dashboard.pbix`
Three pages:
- **Overview** — KPI cards, segment distribution donuts, revenue-by-segment ranking,
  and a key-insight callout
- **Segment Deep-Dive** — RFM bubble chart (Recency × Frequency × Monetary) and a
  full segment comparison table
- **At-Risk Action List** — filterable drill-down of At Risk / Cant Lose Them
  customers with conditional formatting, plus recommended retention actions per segment

## Key Findings

- **Revenue concentration**: Champions (20.8% of customers) generate **63.7%** of
  all revenue — Champions + Loyal Customers (42.2% of customers) drive **79.1%** of
  revenue.
- **At-risk value**: 769 customers in the At Risk / Cant Lose Them segments hold
  **£921,938** in revenue — both segments spend well above the £2,049 average per
  customer, making this the highest-leverage retention target.
- **Low-priority tail**: Hibernating + Lost customers (20.2% of the base) contribute
  just 3.7% of revenue — not worth heavy retention spend.

Full breakdown and recommendations: see `business_summary.docx`.

## Files in this repository

| File | Description |
|---|---|
| `Online_Retail_Dataset.csv` | Raw source dataset (UCI/Kaggle Online Retail) |
| `01_setup_and_clean.sql` | Database setup, CSV import, date-format fix, data cleaning |
| `02_rfm_scoring_segmentation.sql` | RFM calculation, NTILE scoring, segment labeling |
| `customer_rfm.csv` | Final per-customer RFM output (exported from MySQL) |
| `RFM_Dashboard.pbix` | Power BI dashboard (3 pages) |
| `business_summary.docx` | One-page business insight summary with recommendations |
| `dashboard_design_guide.md` | Color palette and styling reference used for the dashboard |

## How to reproduce

1. Clone this repo (includes the dataset already)
2. Run `01_setup_and_clean.sql` in MySQL, updating the file path in the
   `LOAD DATA LOCAL INFILE` line to point to your local copy of
   `Online_Retail_Dataset.csv`
3. Run `02_rfm_scoring_segmentation.sql` to build the `customer_rfm` table
4. Open `RFM_Dashboard.pbix` in Power BI Desktop — either connect it directly to
   your MySQL `retail_rfm` database, or re-point it to the included
   `customer_rfm.csv`

## Notes on approach

- Chose a 5x5x5 RFM scoring model (NTILE-based quintiles) over a fixed-threshold
  model since it adapts to the actual distribution of this customer base rather than
  assuming fixed day/order-count cutoffs.
- Segment labels follow the widely-used RFM segmentation framework (Champions, Loyal
  Customers, At Risk, etc.) for interpretability.
