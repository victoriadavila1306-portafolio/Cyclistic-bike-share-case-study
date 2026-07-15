-- Union of 12 datasets
CREATE OR REPLACE TABLE `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_Alltrips` as
SELECT * FROM  `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_January2025`
UNION ALL
SELECT * FROM `case-study-501702.Cyclistis_Dataset_202501.Cylistic_February2025`
UNION ALL
SELECT * FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_March2025`
UNION ALL
SELECT * FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_April2025`
UNION ALL
SELECT * FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_May2025`
UNION ALL
SELECT * FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_June2025`
UNION ALL
SELECT * FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_July2025`
UNION ALL
SELECT * FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_August2025`
UNION ALL
SELECT * FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_September2025`
UNION ALL
SELECT * FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_October2025`
UNION ALL
SELECT * FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_November2025`
UNION ALl
SELECT * FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_December2025`
----------------------------------------------------------------------------------

-- Create new variables
CREATE OR REPLACE TABLE `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_Final_Analysis` as

SELECT
  ride_id,
  rideable_type,
  started_at,
  ended_at,
  start_station_name,
  start_station_id,
  end_station_name,
  end_station_id,
  start_lat,
  start_lng,
  end_lat,
  end_lng,
  member_casual,

  DATE(started_at) as ride_date,

  CASE
    WHEN ended_at >= started_at
    THEN TIMESTAMP_DIFF(ended_at, started_at, SECOND) / 60.0
    ELSE NULL
  END AS ride_length_minutes,

  FORMAT_TIMESTAMP('%A', started_at) as day_of_week,

  FORMAT_TIMESTAMP('%B', started_at) as month,

  EXTRACT(HOUR FROM started_at) as hour,

  CASE 
    WHEN EXTRACT (DAYOFWEEK FROM started_at) in (1, 7)
      THEN 'Weekend'
    ELSE 'Weekday'
  END as day_type,

  CASE 
    WHEN ended_at < started_at
      THEN TRUE
    ELSE FALSE
  END AS invalid_duration,

  CASE 
    WHEN TIMESTAMP_DIFF (ended_at, started_at, SECOND) > 86400
      THEN TRUE
    ELSE FALSE
  END AS long_ride_over_24h,

  CASE 
    WHEN start_station_name IS NOT NULL
      AND start_station_id IS NOT NULL  
      AND end_station_name IS NOT NULL  
      AND end_station_id IS NOT NULL  
      THEN TRUE
    ELSE FALSE
  END AS complete_station_data


FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_Alltrips`; 
-----------------------------------------------------------------------------------
-- Total rides per type of member
SELECT
  member_casual,
  COUNT(*) as total_rides
FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_Final_Analysis` 
GROUP BY member_casual;
------------------------------------------------------------------------------------
-- Average ride duration
SELECT
  member_casual,
  ROUND(AVG(ride_length_minutes),2) AS avg_duration
FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_Final_Analysis` 
WHERE invalid_duration = FALSE
GROUP BY member_casual;
--------------------------------------------------------------------------------------
-- Rides per type of bicyle
SELECT
  member_casual,
  rideable_type,
  COUNT (*) as rides
FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_Final_Analysis` 
GROUP BY member_casual, rideable_type
ORDER BY member_casual;
------------------------------------------------------------------------------------
-- Rides per day of the week
SELECT
  member_casual,
  day_of_week,
  COUNT(*) as rides
FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_Final_Analysis` 
GROUP BY member_casual, day_of_week;
--------------------------------------------------------------------------------------
-- Rides per month
SELECT
  member_casual,
  month,
  COUNT(*) as rides
FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_Final_Analysis` 
WHERE invalid_duration = FALSE
GROUP BY member_casual, month
ORDER BY member_casual;
---------------------------------------------------------------------------------------
-- Rides per hour of the day
SELECT
  member_casual,
  hour,
  COUNT(*) as rides
FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_Final_Analysis` 
WHERE invalid_duration = FALSE
GROUP BY member_casual, hour
ORDER BY hour;
------------------------------------------------------------------------------------
-- Top 10 most popular starting stations in casual riders
SELECT
  start_station_name,
  COUNT(*) AS stations
FROM `case-study-501702.Cyclistis_Dataset_202501.Cyclistic_Final_Analysis` 
WHERE complete_station_data = TRUE
  AND member_casual = 'casual'
GROUP BY start_station_name
ORDER BY stations DESC
LIMIT 10;
