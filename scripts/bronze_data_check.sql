-- CHECK THE BRONZE QUALITY 
SELECT * FROM bronze.ca_raw_info

-- FIXING THE COLUMN 1 - ticket_id
SELECT 
*
FROM
(SELECT 
*,
ROW_NUMBER() OVER(PARTITION BY ticket_id ORDER BY open_date_time DESC) flag_last
FROM bronze.ca_raw_info)t
WHERE flag_last = 1 OR ticket_id IS NULL

-- FIXING COLUMN 2 - agent_name
-- Checking the Trim Lenght of the Agents 
-- Checking the Duplicates 
-- Checking NULL Values in Agent Name Column 
-- Fixing the Format of the Agent Name as UPPER CASE since the values in the column have different formats.
SELECT DISTINCT
TRIM(agent_name) agent_name
FROM 
bronze.ca_raw_info
WHERE LEN(agent_name) <> LEN(TRIM(agent_name)) OR agent_name IS NULL


-- COLUMN 3 - ticket_type 
-- CHECKING THE TRIM VALUES 
SELECT DISTINCT
ticket_type
FROM
bronze.ca_raw_info
WHERE LEN(ticket_type) <> LEN(TRIM(ticket_type)) OR ticket_type IS NULL
-- ==================
-- LENGTH ISSUE FOUND 
-- ==================
-- FIXING COLUMN 3 
SELECT DISTINCT
TRIM(ticket_type) ticket_type,
CASE            WHEN LOWER(ticket_type) LIKE '%r%' THEN 'Request'
	            WHEN LOWER(ticket_type) LIKE '%i%' THEN 'Incident'
ELSE ticket_type
END AS proper_ticket_type
FROM
bronze.ca_raw_info

-- Column #4: -- Data Imputation Required 
SELECT DISTINCT
category
FROM 
bronze.ca_raw_info
WHERE category IS NULL
-- ======================
-- NULL VALUE WAS FOUND 
-- ======================
SELECT DISTINCT
ISNULL(TRIM(category),'Other') category
FROM 
bronze.ca_raw_info

-- Column #5 -- NO ISSUES FOUND IN COLUMN 5 
SELECT DISTINCT
ticket_status
FROM bronze.ca_raw_info
WHERE LEN(ticket_status) <> LEN(TRIM(ticket_status)) OR ticket_status IS NULL


-- COLUMN #6
-- LENGTH CHECK 
SELECT 
open_date_time,
LEN(open_date_time)
FROM 
bronze.ca_raw_info
WHERE LEN(open_date_time) <> LEN(TRIM(open_date_time))

-- INVALID DATE COLUMNS 
-- FIXING COLUMN 6: open_date_time
SELECT 
*
FROM
(SELECT 
    open_date_time AS original_value,
    COALESCE(
        -- 1. Try standard universal format (YYYY-MM-DD or YYYY/MM/DD)
        TRY_CAST(LEFT(open_date_time, 10) AS DATE),
        
        -- 2. If that fails, try DD-MM-YYYY format (Style 105)
        TRY_CONVERT(DATE, LEFT(open_date_time, 10), 105),

        -- 3. If that fails, try DD/MM/YYYY format (Style 103)
        TRY_CONVERT(DATE, LEFT(open_date_time, 10), 103)
    ) AS clean_open_date
FROM 
    bronze.ca_raw_info)t

-- FIXING INVALID DATE COLUMNS 
SELECT *,
CASE WHEN COALESCE(TRY_CAST(LEFT(close_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(close_date_time,10),105),TRY_CONVERT(DATE,LEFT(close_date_time,10),103)) < COALESCE(TRY_CAST(LEFT(open_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(open_date_time,10),105),TRY_CONVERT(DATE,LEFT(open_date_time,10),103)) THEN COALESCE(TRY_CAST(LEFT(open_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(open_date_time,10),105),TRY_CONVERT(DATE,LEFT(open_date_time,10),103))
ELSE COALESCE(TRY_CAST(LEFT(close_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(close_date_time,10),105),TRY_CONVERT(DATE,LEFT(close_date_time,10),103))
END close_date_time
FROM 
(SELECT 
       ticket_status,
       COALESCE(TRY_CAST(LEFT(open_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(open_date_time,10),105),TRY_CONVERT(DATE,LEFT(open_date_time,10),103)) open_date_time,
       COALESCE(TRY_CAST(LEFT(close_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(close_date_time,10),105),TRY_CONVERT(DATE,LEFT(close_date_time,10),103)) close_date_time
FROM 
bronze.ca_raw_info)t
WHERE close_date_time < open_date_time AND ticket_status = 'Closed'
