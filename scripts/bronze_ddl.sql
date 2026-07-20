-- CREATING THE BRONZE DDL SCRIPT 
-- COLUMN NAMES IN THE RAW DATA 
-- TicketID	AgentName	TicketType	Category	Status	OpenDateTime	CloseDateTime	ResolutionTimeHours	CustomerSatisfactionScore	FeedbackComments

-- DDL SCRIPT for bronze table
-- Switch to your data warehouse
USE dwh_helpdesk;
GO

-- 1. Drop the table if it exists (Added the word 'TABLE')
IF OBJECT_ID('bronze.ca_raw_info', 'U') IS NOT NULL
    DROP TABLE bronze.ca_raw_info;
GO

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
);
GO

-- TO CHECK IF THE TABLE WAS CREATED OR NOT.
SELECT * FROM bronze.ca_raw_info

