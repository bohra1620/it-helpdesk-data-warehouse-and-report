-- CREATED A STORED PROCEDURE FOR FULL LOAD TECHNIQUE

CREATE OR ALTER PROCEDURE bronze.rawdata_load
AS
BEGIN

IF OBJECT_ID('bronze.ca_raw_info', 'U') IS NOT NULL
    DROP TABLE bronze.ca_raw_info

-- 2. Create the Bronze table with safe raw data types
CREATE TABLE bronze.ca_raw_info (
    ticket_id VARCHAR(50),               -- Changed from INT to accommodate 'TKT-10001'
    agent_name VARCHAR(50),
    ticket_type VARCHAR(50),
    category VARCHAR(50),
    ticket_status VARCHAR(50),
    open_date_time VARCHAR(100),         -- Changed from DATE to handle messy string injections
    close_date_time VARCHAR(100),        -- Changed from DATE to handle messy string injections
    resolution_time_hours VARCHAR(50),
    customer_satisfaction_score VARCHAR(50), -- Safe ingestion for nulls/weird values
    feedback_comments VARCHAR(MAX)           -- Using MAX is safer for free-text comments
)

-- BULK INSERT COMMANDS
BULK INSERT bronze.ca_raw_info
FROM 'C:\Users\bohra\OneDrive\Desktop\Dashboards PBI\dataset\helpdesk\ca.helpdesk_info.csv'
WITH 
(FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR = ',',    
ROWTERMINATOR = '\n',     
TABLOCK
)

END

-- RUNNING THE STORED PROCEDURE TO CHECK IT'S WORKING.
EXEC bronze.rawdata_load
