CREATE OR ALTER PROCEDURE silver.load_info 
AS
BEGIN
    -- Prevents SQL Server from sending row count messages, which speeds up execution
    SET NOCOUNT ON; 

    -- Declare variables for time tracking
    DECLARE @StartTime DATETIME2;
    DECLARE @EndTime DATETIME2;
    DECLARE @DurationSeconds INT;

    BEGIN TRY
        -- Capture exact start time
        SET @StartTime = SYSDATETIME();

        PRINT '=============================================================';
        PRINT 'STARTING SILVER LAYER LOAD: silver.ca_helpdesk_info';
        PRINT 'Start Time: ' + CAST(@StartTime AS VARCHAR(30));
        PRINT '=============================================================';

        -- STEP 1: Drop Table
        PRINT 'STEP 1: Checking for existing table...';
        IF OBJECT_ID('silver.ca_helpdesk_info') IS NOT NULL 
        BEGIN
            PRINT '        Existing table found. Dropping silver.ca_helpdesk_info...';
            DROP TABLE silver.ca_helpdesk_info;
        END
        ELSE
        BEGIN
            PRINT '        No existing table found. Proceeding...';
        END

        -- STEP 2: Create Table
        PRINT 'STEP 2: Creating new silver.ca_helpdesk_info table...';
        CREATE TABLE silver.ca_helpdesk_info(
              [ticket_id] VARCHAR(50) PRIMARY KEY,
              [agent_name] VARCHAR(50),
              [ticket_type]  VARCHAR(50),
              [category]  VARCHAR(50),
              [ticket_status]  VARCHAR(50),
              [open_date_time] DATE,
              [close_date_time] DATE,
              [resolution_time_hours] INT,
              [customer_satisfaction_score] INT,
              [feedback_comments]  VARCHAR(150),
              [dwh_creation_date] DATETIME2
        );

        -- STEP 3: Insert Data
        PRINT 'STEP 3: Cleaning and loading data from Bronze to Silver...';
        INSERT INTO silver.ca_helpdesk_info(
               [ticket_id]
              ,[agent_name]
              ,[ticket_type]
              ,[category]
              ,[ticket_status]
              ,[open_date_time]
              ,[close_date_time]
              ,[resolution_time_hours]
              ,[customer_satisfaction_score]
              ,[feedback_comments]
              ,[dwh_creation_date]
         )      
         SELECT TRIM(ticket_id) ticket_id,                   
               UPPER(TRIM(agent_name)) agent_name,                     
               CASE
                        WHEN LOWER(ticket_type) LIKE '%r%' THEN 'Request'
                        WHEN LOWER(ticket_type) LIKE '%i%' THEN 'Incident'
                   ELSE ticket_type
               END ticket_type,                             
               ISNULL(TRIM(category),'Other') category,     
               TRIM(ticket_status) ticket_status,                               
               COALESCE(TRY_CAST(LEFT(open_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(open_date_time,10),105),TRY_CONVERT(DATE,LEFT(open_date_time,10),103)) open_date_time,
               CASE 
                        WHEN COALESCE(TRY_CAST(LEFT(close_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(close_date_time,10),105),TRY_CONVERT(DATE,LEFT(close_date_time,10),103)) < COALESCE(TRY_CAST(LEFT(open_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(open_date_time,10),105),TRY_CONVERT(DATE,LEFT(open_date_time,10),103)) THEN COALESCE(TRY_CAST(LEFT(open_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(open_date_time,10),105),TRY_CONVERT(DATE,LEFT(open_date_time,10),103))
                    ELSE COALESCE(TRY_CAST(LEFT(close_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(close_date_time,10),105),TRY_CONVERT(DATE,LEFT(close_date_time,10),103))
               END close_date_time,
               ABS(TRY_CAST(REPLACE(REPLACE(LOWER(resolution_time_hours), 'hours', ''), 'hrs', '') AS INT)) AS resolution_time_hours,
               CASE
                    WHEN TRY_CAST(customer_satisfaction_score AS FLOAT) NOT IN (1,2,3,4,5,6,7,8,9,10) THEN NULL
                    ELSE CAST(TRY_CAST(customer_satisfaction_score AS FLOAT) AS INT)
               END AS customer_satisfaction_score,
               ISNULL(NULLIF(TRIM(feedback_comments), ''), 'N/A') AS feedback_comments,
               getdate() dwh_creation_date
          FROM   (
          SELECT 
          *,
          ROW_NUMBER() OVER(PARTITION BY TRIM(ticket_id) ORDER BY open_date_time DESC) as flag_last
          FROM 
          bronze.ca_raw_info
          )t
          WHERE flag_last = 1 AND TRIM(ticket_id) IS NOT NULL;

        -- Capture end time and calculate duration
        SET @EndTime = SYSDATETIME();
        SET @DurationSeconds = DATEDIFF(SECOND, @StartTime, @EndTime);

        PRINT '=============================================================';
        PRINT 'SUCCESS: Silver Layer Load Completed!';
        PRINT 'End Time: ' + CAST(@EndTime AS VARCHAR(30));
        PRINT 'Time Taken: ' + CAST(@DurationSeconds AS VARCHAR(10)) + ' seconds';
        PRINT '=============================================================';

    END TRY
    
    BEGIN CATCH
        -- Capture end time on failure as well
        SET @EndTime = SYSDATETIME();
        SET @DurationSeconds = DATEDIFF(SECOND, @StartTime, @EndTime);

        PRINT '=============================================================';
        PRINT 'ERROR: Silver Layer Load Failed!';
        PRINT 'Time of Failure: ' + CAST(@EndTime AS VARCHAR(30));
        PRINT 'Time Elapsed Before Failure: ' + CAST(@DurationSeconds AS VARCHAR(10)) + ' seconds';
        PRINT '=============================================================';
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        PRINT 'Error Details: ' + @ErrorMessage;
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END;
