-- CREATING SILVER LAYER

SELECT TRIM(ticket_id) ticket_id,                   -- FIXED THE TICKET_ID DUPLICATE ISSUE 
       UPPER(TRIM(agent_name)) agent_name,                     -- FIXED THE FORMAT OF THE AGENT NAME TO UPPERCASE 
       CASE
                WHEN LOWER(ticket_type) LIKE '%r%' THEN 'Request'
	            WHEN LOWER(ticket_type) LIKE '%i%' THEN 'Incident'
           ELSE ticket_type
       END ticket_type,                             -- FIXED THE TICKET TYPE INCORRECTLY WRITTEN
       ISNULL(TRIM(category),'Other') category,     -- FIXED THE NULL CATEGORY ISSUE 
       TRIM(ticket_status) ticket_status,                               -- NO ISSUES FOUND WITH THIS COLUMN 
       COALESCE(TRY_CAST(LEFT(open_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(open_date_time,10),105),TRY_CONVERT(DATE,LEFT(open_date_time,10),103)) open_date_time,
       CASE 
                WHEN COALESCE(TRY_CAST(LEFT(close_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(close_date_time,10),105),TRY_CONVERT(DATE,LEFT(close_date_time,10),103)) < COALESCE(TRY_CAST(LEFT(open_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(open_date_time,10),105),TRY_CONVERT(DATE,LEFT(open_date_time,10),103)) THEN COALESCE(TRY_CAST(LEFT(open_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(open_date_time,10),105),TRY_CONVERT(DATE,LEFT(open_date_time,10),103))
            ELSE COALESCE(TRY_CAST(LEFT(close_date_time,10) AS DATE),TRY_CONVERT(DATE,LEFT(close_date_time,10),105),TRY_CONVERT(DATE,LEFT(close_date_time,10),103))
       END close_date_time,
       resolution_time_hours,
       customer_satisfaction_score,
       feedback_comments
  FROM 
  (
  SELECT 
  *,
  ROW_NUMBER() OVER(PARTITION BY TRIM(ticket_id) ORDER BY open_date_time DESC) as flag_last
  FROM 
  bronze.ca_raw_info
  )t
  WHERE flag_last = 1 OR TRIM(ticket_id) IS NULL
