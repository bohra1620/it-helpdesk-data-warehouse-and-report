# Helpdesk Medallion Data Warehouse (DWH)

## Project Overview
This project is an end-to-end Data Engineering and Analytics pipeline designed to process, clean, and analyze helpdesk ticket performance and agent metrics. 

The pipeline follows the **Medallion Architecture** (Bronze, Silver, Gold layers) to progressively structure and transform the data for final consumption in Power BI. To simulate a real-world data engineering environment, the raw data is intentionally generated with inconsistencies, nulls, logical errors, and duplicates.

## Tech Stack
*   **Data Generation:** Python (Pandas, NumPy)
*   **Database & Transformations:** SQL Server (SSMS), T-SQL
*   **BI & Visualization:** Power BI (Planned)

## Project Progress

### 1. Synthetic Data Generation (`dataset_generation.py`)
Created a Python script to generate a realistic, messy "Bronze layer" dataset (`raw_helpdesk_tickets_bronze.csv`). 
*   **Data Points:** Ticket ID, Agent Name, Category, Ticket Type, Status, Open/Close Timestamps, Resolution Time, Customer Satisfaction, and Feedback.
*   **Injected Anomalies (for cleaning practice):**
    *   Inconsistent string casing and typos (e.g., "incidnt", "REQ").
    *   Mixed date formats (ISO, US, EU).
    *   Logical errors (Close dates occurring before Open dates).
    *   Out-of-bounds metrics (Negative resolution times, text strings in integer columns, invalid feedback scores).
    *   Null values in critical fields.
    *   Simulated ingestion duplicates (~3%).

### 2. Database Creation (`01_create_database.sql`)
Wrote the foundational T-SQL scripts to safely establish the data warehouse environment:
*   Checked for existing instances to avoid conflicts.
*   Created the `dwh_helpdesk` database.
