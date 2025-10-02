
-- count how many unique products they viewed per user
SELECT
visitorid,
COUNT(DISTINCT itemid) AS products_viewed 
FROM events 
WHERE event = 'view'
GROUP BY visitorid

--count unique views and purchases (if any) per user
-- COUNT(*) wouldnt work because it counts all rows regardless of the event type so we use 'SUM(CASE WHEN event = transaction' THEN 1 ELSE 0 END)
SELECT 
visitorid,
COUNT(DISTINCT itemid) AS products_viewed,
SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END) AS purchases
FROM events
GROUP BY visitorid

-- bin users by product variety and calculate conversion rate (how often purchases happen from viewing conversion rate)
-- Bin users by the number of unique products they viewed
-- and calculate conversion rate (the proportion who made purchases)

SELECT 
  CASE
    WHEN products_viewed BETWEEN 1 AND 5 THEN '1-5'
    WHEN products_viewed BETWEEN 6 AND 10 THEN '6-10'
    WHEN products_viewed BETWEEN 11 AND 20 THEN '11-20'
    ELSE '21+'
  END AS product_view_bin,  -- Create bins for product variety

  COUNT(*) AS total_users,  -- Count how many users fall into each bin
  SUM(CASE WHEN purchases > 0 THEN 1 ELSE 0 END) AS users_purchased,  
  -- Count users in each bin who made at least one purchase

  1.0 * SUM(CASE WHEN purchases > 0 THEN 1 ELSE 0 END) / COUNT(*) AS conversion_rate
  -- Calculate the conversion rate as proportion of purchasers over total users,
  -- multiplied by 1.0 to force decimal division
FROM (
  -- Subquery: For each visitor, count how many unique products viewed and purchases made
  SELECT
    visitorid,
    COUNT(DISTINCT itemid) AS products_viewed,
    SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END) AS purchases  -- Count purchase events
  FROM events
  GROUP BY visitorid
) AS user_summary  -- Alias for subquery results
GROUP BY product_view_bin  -- Group results by product variety bins
ORDER BY product_view_bin;  -- Order results by bin (ascending)


-- find users who viewed a lot of products but did not purchase anything
SELECT 
	visitorid,
	COUNT(DISTINCT itemid) AS products_viewed
FROM events 
WHERE event = 'view'
GROUP BY visitorid
HAVING products_viewed > 15
	AND visitorid NOT IN (
		SELECT DISTINCT visitorid
		FROM events
		WHERE event = 'transaction'
	);

--calculating total session length per user in minutes based on earlierst and latest event timestamps
SELECT 
visitorid,
MIN(timestamp) AS session_start,
MAX(timestamp) AS session_end,
 (MAX(timestamp)-MIN(timestamp)) / 60000.0 AS session_duration_minutes, -- 6000.0 number of milliseconds in one minute, dividing by that gives minutes. .0 makes it a decimal
 COUNT(*) AS session_events,
 SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END) AS purchases
 FROM events 
 GROUP BY events.visitorid 

-- finding abandonment rates for items using JOINs by category
SELECT
  ip.value AS categoryid,
  COUNT(DISTINCT e.visitorid) AS sessions,
  SUM(CASE WHEN s.purchases = 0 THEN 1 ELSE 0 END) AS non_purchase_sessions,
  1.0 * SUM(CASE WHEN s.purchases = 0 THEN 1 ELSE 0 END) / COUNT(DISTINCT e.visitorid) AS abandonment_rate
FROM (SELECT * FROM events LIMIT 10000) e
JOIN (
  SELECT visitorid,
    SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END) AS purchases
  FROM events
  GROUP BY visitorid
) s ON e.visitorid = s.visitorid
JOIN item_properties ip ON e.itemid = ip.itemid AND ip.property = 'categoryid'
GROUP BY ip.value
ORDER BY abandonment_rate DESC;


-- site wide average
WITH
  ordered_events AS (
    SELECT
      visitorid,
      event,
      itemid,
      timestamp,
      LAG(timestamp) OVER (PARTITION BY visitorid ORDER BY timestamp) AS prev_timestamp
    FROM events
  ),
  session_marked AS (
    SELECT *,
      CASE
        WHEN prev_timestamp IS NULL THEN 0
        WHEN (timestamp - prev_timestamp) > 1800000 THEN 1
        ELSE 0
      END AS session_break_flag
    FROM ordered_events
  ),
  sessionized AS (
    SELECT
      visitorid,
      timestamp,
      itemid,
      event,
      SUM(session_break_flag) OVER (PARTITION BY visitorid ORDER BY timestamp) AS session_number
    FROM session_marked
  ),
  session_summary AS (
    SELECT
      visitorid,
      session_number,
      (MAX(timestamp) - MIN(timestamp)) / 60000.0 AS session_duration_minutes,
      COUNT(DISTINCT itemid) AS products_viewed,
      SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END) AS purchases
    FROM sessionized
    GROUP BY visitorid, session_number
  ),
  persona_sessions AS (
    SELECT
      session_duration_minutes,
      products_viewed,
      purchases,
      CASE
        WHEN products_viewed BETWEEN 1 AND 5   AND session_duration_minutes <  8 THEN 'Casual Browser'
        WHEN products_viewed BETWEEN 6 AND 11  AND session_duration_minutes >= 10 THEN 'Indecisive Navigator'
        WHEN products_viewed >= 12             AND session_duration_minutes >= 10 THEN 'Power Shopper'
        ELSE 'Other'
      END AS persona_type,
      CASE
        WHEN session_duration_minutes <= 5            THEN 'Short'
        WHEN session_duration_minutes BETWEEN 6 AND 15 THEN 'Medium'
        ELSE 'Long'
      END AS session_length
    FROM session_summary
  )

SELECT
  'Site Wide' AS persona_type,
  NULL       AS session_length,
  COUNT(*)                                AS total_sessions,
  ROUND(AVG(session_duration_minutes), 2) AS avg_session_duration,
  ROUND(AVG(products_viewed), 1)          AS avg_items_viewed,
  ROUND(AVG(CASE WHEN purchases > 0 THEN 1 ELSE 0 END) * 100, 2) AS conversion_rate_percent,
  ROUND((1 - AVG(CASE WHEN purchases > 0 THEN 1 ELSE 0 END)) * 100, 2) AS abandonment_rate_percent
FROM persona_sessions;

-- PERSONA METRICS

WITH ordered_events AS (
  SELECT
    visitorid,
    event,
    itemid,
    timestamp,
    LAG(timestamp) OVER (PARTITION BY visitorid ORDER BY timestamp) AS prev_timestamp
  FROM events
),
session_marked AS (
  SELECT *,
    CASE 
      WHEN prev_timestamp IS NULL THEN 0
      WHEN (timestamp - prev_timestamp) > 1800000 THEN 1
      ELSE 0
    END AS session_break_flag
  FROM ordered_events
),
sessionized AS (
  SELECT
    visitorid,
    event,
    itemid,
    timestamp,
    SUM(session_break_flag) OVER (PARTITION BY visitorid ORDER BY timestamp) AS session_number
  FROM session_marked
),
session_summary AS (
  SELECT
    visitorid,
    session_number,
    MIN(timestamp) AS session_start,
    MAX(timestamp) AS session_end,
    (MAX(timestamp) - MIN(timestamp)) / 60000.0 AS session_duration_minutes,
    COUNT(DISTINCT itemid) AS products_viewed,
    SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END) AS purchases
  FROM sessionized
  GROUP BY visitorid, session_number
),
persona_sessions AS (
  SELECT *,
    CASE
      WHEN products_viewed BETWEEN 1 AND 5 AND session_duration_minutes < 8 THEN 'Casual Browser'
      WHEN products_viewed >= 12 AND session_duration_minutes >= 10 THEN 'Power Shopper'
      WHEN products_viewed BETWEEN 6 AND 11 AND session_duration_minutes >= 10 THEN 'Indecisive Navigator'
      ELSE 'Other'
    END AS persona_type
  FROM session_summary
)
SELECT
  persona_type,
  COUNT(*) AS total_sessions,
  ROUND(AVG(session_duration_minutes), 2) AS avg_session_duration,
  ROUND(AVG(products_viewed), 1) AS avg_items_viewed,
  ROUND(AVG(CASE WHEN purchases > 0 THEN 1 ELSE 0 END) * 100, 2) AS conversion_rate_percent,
  ROUND((1 - AVG(CASE WHEN purchases > 0 THEN 1 ELSE 0 END)) * 100, 2) AS abandonment_rate_percent
FROM persona_sessions
GROUP BY persona_type;


-- Funnel chart to see where personas drop off

WITH ordered_events AS (
  SELECT
    visitorid,
    event,
    itemid,
    timestamp,
    LAG(timestamp) OVER (PARTITION BY visitorid ORDER BY timestamp) AS prev_timestamp
  FROM events
),
session_marked AS (
  SELECT *,
    CASE 
      WHEN prev_timestamp IS NULL THEN 0
      WHEN (timestamp - prev_timestamp) > 1800000 THEN 1
      ELSE 0
    END AS session_break_flag
  FROM ordered_events
),
sessionized AS (
  SELECT
    visitorid,
    event,
    itemid,
    timestamp,
    SUM(session_break_flag) OVER (PARTITION BY visitorid ORDER BY timestamp) AS session_number
  FROM session_marked
),
session_summary AS (
  SELECT
    visitorid,
    session_number,
    MIN(timestamp) AS session_start,
    MAX(timestamp) AS session_end,
    (MAX(timestamp) - MIN(timestamp)) / 60000.0 AS session_duration_minutes,
    COUNT(DISTINCT itemid) AS products_viewed
  FROM sessionized
  GROUP BY visitorid, session_number
),
persona_sessions AS (
  SELECT *,
    CASE
      WHEN products_viewed BETWEEN 1 AND 5   AND session_duration_minutes <  8 THEN 'Casual Browser'
      WHEN products_viewed >= 12             AND session_duration_minutes >= 10 THEN 'Power Shopper'
      WHEN products_viewed BETWEEN 6 AND 11  AND session_duration_minutes >= 10 THEN 'Indecisive Navigator'
      ELSE 'Other'
    END AS persona_type
  FROM session_summary
)
SELECT
  persona_type,
  session_duration_minutes,
  event,
  COUNT(*) AS event_count
FROM sessionized s
JOIN persona_sessions p
  ON s.visitorid = p.visitorid
 AND s.session_number = p.session_number
GROUP BY persona_type, session_duration_minutes, event;

-- persona x session-length

WITH
  ordered_events AS (
    SELECT
      visitorid,
      event,
      itemid,
      timestamp,
      LAG(timestamp) OVER (PARTITION BY visitorid ORDER BY timestamp) AS prev_timestamp
    FROM events
  ),
  session_marked AS (
    SELECT *,
      CASE
        WHEN prev_timestamp IS NULL THEN 0
        WHEN (timestamp - prev_timestamp) > 1800000 THEN 1
        ELSE 0
      END AS session_break_flag
    FROM ordered_events
  ),
  sessionized AS (
    SELECT
      visitorid,
      event,
      itemid,
      timestamp,
      SUM(session_break_flag) OVER (PARTITION BY visitorid ORDER BY timestamp) AS session_number
    FROM session_marked
  ),
  session_summary AS (
    SELECT
      visitorid,
      session_number,
      (MAX(timestamp) - MIN(timestamp)) / 60000.0 AS session_duration_minutes,
      COUNT(DISTINCT itemid) AS products_viewed,
      SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END) AS purchases
    FROM sessionized
    GROUP BY visitorid, session_number
  ),
  persona_sessions AS (
    SELECT
      visitorid,
      session_number,
      session_duration_minutes,
      products_viewed,
      purchases,
      -- assign persona based on views + duration
      CASE
        WHEN products_viewed BETWEEN 1 AND 5
             AND session_duration_minutes < 8 THEN 'Casual Browser'
        WHEN products_viewed BETWEEN 6 AND 11
             AND session_duration_minutes >= 10 THEN 'Indecisive Navigator'
        WHEN products_viewed >= 12
             AND session_duration_minutes >= 10 THEN 'Power Shopper'
        ELSE 'Other'
      END AS persona_type,
      CASE
        WHEN session_duration_minutes <= 5 THEN 'Short'
        WHEN session_duration_minutes BETWEEN 6 AND 15 THEN 'Medium'
        ELSE 'Long'
      END AS session_length
    FROM session_summary
  )

SELECT
  persona_type,
  NULL AS session_length, -- Make columns match for UNION
  COUNT(*) AS total_sessions,
  ROUND(AVG(session_duration_minutes), 2) AS avg_session_duration,
  ROUND(AVG(products_viewed), 1) AS avg_items_viewed,
  ROUND(AVG(CASE WHEN purchases > 0 THEN 1 ELSE 0 END) * 100, 2) AS conversion_rate_percent,
  ROUND((1 - AVG(CASE WHEN purchases > 0 THEN 1 ELSE 0 END)) * 100, 2) AS abandonment_rate_percent
FROM persona_sessions
GROUP BY persona_type

UNION ALL

SELECT
  persona_type,
  session_length,
  COUNT(*) AS total_sessions,
  ROUND(AVG(session_duration_minutes), 2) AS avg_session_duration,
  ROUND(AVG(products_viewed), 1) AS avg_items_viewed,
  ROUND(AVG(CASE WHEN purchases > 0 THEN 1 ELSE 0 END) * 100, 2) AS conversion_rate_percent,
  ROUND((1 - AVG(CASE WHEN purchases > 0 THEN 1 ELSE 0 END)) * 100, 2) AS abandonment_rate_percent
FROM persona_sessions
GROUP BY persona_type, session_length

ORDER BY persona_type, session_length;


