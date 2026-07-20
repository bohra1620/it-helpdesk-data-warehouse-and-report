-- CREATING THE BRONZE DDL SCRIPT 
-- COLUMN NAMES IN THE RAW DATA 
-- TicketID	AgentName	TicketType	Category	Status	OpenDateTime	CloseDateTime	ResolutionTimeHours	CustomerSatisfactionScore	FeedbackComments

IF OBJECT_ID('bronze.ca_raw_info','U') IS NOT NULL
DROP TABLE bronze.ca_raw_info
GO

-- DDL SCRIPT for bronze table
CREATE TABLE bronze.ca_raw_info
(
ticket_id INT,
agent_name VARCHAR(50),
ticket_type VARCHAR(50),
category VARCHAR(50),
ticket_status VARCHAR(50),
open_date_time DATE,
close_date_time VARCHAR(50),
resolution_time_hours VARCHAR(50),
customer_satisfacation_score INT,
feedback_comments VARCHAR(200)
)

-- TO CHECK IF THE TABLE WAS CREATED OR NOT.
SELECT * FROM bronze.ca_raw_info

