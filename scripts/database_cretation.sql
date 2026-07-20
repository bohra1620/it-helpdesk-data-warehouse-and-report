-- CREATING DATABASE FOR HELPDESK DATA WAREHOUSE
USE master;
GO

-- Drop the database if it already exists
IF DB_ID('dwh_helpdesk') IS NOT NULL 
    DROP DATABASE dwh_helpdesk;
GO

-- Create the new database
CREATE DATABASE dwh_helpdesk;
GO 

-- Switch to the new database
USE dwh_helpdesk;
GO
