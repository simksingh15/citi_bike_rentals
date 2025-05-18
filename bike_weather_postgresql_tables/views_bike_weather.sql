--Table to count number of trips: daily--
CREATE VIEW citi_bike_weather.daily_trip_counts AS
SELECT date_info.datekey,
    date_info.date,
    date_info.month_name,
	date_info.month,
    date_info.day,
    date_info.day_name,
    date_info.weekend,
    COUNT(trips.trip_id) AS trips_total,
    COUNT(demo.user_type_id) FILTER (WHERE demo.user_type_id = 2) AS subscriber_trips,
    COUNT(demo.user_type_id) FILTER (WHERE demo.user_type_id = 1) AS customer_trips,
    COUNT(demo.user_type_id) FILTER (WHERE demo.user_type_id = 0) AS unknown_trips
   FROM citi_bike_weather.trip_info trips 
     RIGHT JOIN citi_bike_weather.date_info ON trips.datekey = date_info.datekey
     LEFT JOIN citi_bike_weather.trip_user_info demo ON trips.trip_id = demo.trip_id
	 LEFT JOIN citi_bike_weather.user_type u ON demo.user_type_id = u.id
  GROUP BY date_info.datekey
  ORDER BY date_info.datekey;



--Table to count number of trips by day and weather: daily--
CREATE VIEW citi_bike_weather.daily_weather_counts AS
SELECT 
	counts.datekey,
    counts.date,
	counts.month_name,
	counts.month,
    counts.day,
    counts.day_name,
    counts.weekend,
	counts.trips_total,
	counts.subscriber_trips,
	counts.customer_trips,
	counts.unknown_trips,
	weather.awnd,
	weather.snow,
	weather.snwd,
	weather.snow_fall,
	weather.prcp,
	weather.rain_fall,
	weather.tavg,
	weather.tmax,
	weather.tmin
FROM citi_bike_weather.daily_trip_counts counts
	 LEFT JOIN citi_bike_weather.weather_info weather ON counts.datekey = weather.datekey
ORDER BY counts.datekey;


--Table to count number of trips by month and weather: monthly--
CREATE VIEW citi_bike_weather.monthly_trip_sumary AS
SELECT 
	dw_counts.month_name,
	SUM(dw_counts.trips_total) AS total_trips,
	ROUND(AVG(dw_counts.trips_total)) AS daily_avg_total_trips,
	SUM(dw_counts.subscriber_trips) AS subscriber_total_trips,
	ROUND(AVG(dw_counts.subscriber_trips)) AS daily_avg_subscriber_trips,
	SUM(dw_counts.customer_trips) AS customer_total_trips,
	ROUND(AVG(dw_counts.customer_trips)) AS daily_avg_customer_trips,
	SUM(dw_counts.unknown_trips) AS unknown_total_trips,
	ROUND(AVG(dw_counts.unknown_trips)) AS daily_avg_unknown_trips,
	ROUND(AVG(dw_counts.tavg)) AS avg_tavg,
	COUNT(dw_counts.datekey)FILTER(WHERE dw_counts.snow_fall = true) AS days_with_snow,
	ROUND(AVG(dw_counts.snow) FILTER(WHERE dw_counts.snow > 0)) AS avg_snow_inches,
	MAX(dw_counts.snow) AS max_snow_amt,
	COUNT(dw_counts.datekey)FILTER(WHERE dw_counts.rain_fall = true) AS days_with_rain,
	ROUND(AVG(dw_counts.prcp) FILTER(WHERE dw_counts.prcp > 0)) AS avg_precipitation,
	MAX(dw_counts.prcp) AS max_precipitation
FROM citi_bike_weather.daily_weather_counts dw_counts 
GROUP BY dw_counts.month, dw_counts.month_name
ORDER BY dw_counts.month;


--Flagged trips past 24 hour time limit--
CREATE VIEW citi_bike_weather.trips_over_24hrs AS
SELECT 
trip_id,
date.datekey,
trip.start_time,
trip.stop_time,
trip.duration_hours,
start_station.name AS start_station,
start_station.latitude AS start_latitude,
start_station.longitude AS start_longitude,
end_station.name AS end_station,
end_station.latitude AS end_latitude,
end_station.longitude AS end_longitude, 
weather.snow_fall,
weather.snow,
weather.rain_fall,
weather.prcp AS precipitation,
weather.tavg AS average_temperature,
weather.tmin AS min_temperature,
weather.tmax AS max_temperature
FROM citi_bike_weather.trip_info trip
	INNER JOIN citi_bike_weather.date_info date ON trip.datekey = date.datekey
	INNER JOIN citi_bike_weather.bike_station start_station ON trip.start_station_id = start_station.id
	INNER JOIN citi_bike_weather.bike_station end_station ON trip.end_station_id = end_station.id
	INNER JOIN citi_bike_weather.weather_info weather ON trip.datekey = weather.datekey
WHERE trip.duration_hours > 24
ORDER BY start_time;


--Daily trip duration summary--
CREATE VIEW citi_bike_weather.daily_duration_summary AS
SELECT date_info.datekey,
    date_info.date,
    date_info.month_name,
	date_info.month,
    date_info.day,
    date_info.day_name,
    date_info.weekend,
    ROUND(AVG(trips.duration_minutes)) AS avg_duration_mins,
	ROUND(MIN(trips.duration_minutes)) AS min_duration_mins,
	ROUND(MAX(trips.duration_minutes)) AS max_duration_mins,
    ROUND(AVG(trips.duration_minutes) FILTER (WHERE demo.user_type_id = 2)) AS avg_subscriber_duration_mins,
    ROUND(AVG(trips.duration_minutes) FILTER (WHERE demo.user_type_id = 1)) AS avg_customer_duration_mins,
    ROUND(AVG(trips.duration_minutes) FILTER (WHERE demo.user_type_id = 0)) AS avg_unknown_duration_mins
   FROM citi_bike_weather.trip_info trips 
     RIGHT JOIN citi_bike_weather.date_info ON trips.datekey = date_info.datekey
     LEFT JOIN citi_bike_weather.trip_user_info demo ON trips.trip_id = demo.trip_id
  GROUP BY date_info.datekey
  ORDER BY date_info.datekey;


--Monthly trip duration summary--
CREATE VIEW citi_bike_weather.monthly_duration_summary AS
SELECT
    date_info.month_name,
	date_info.month,
    ROUND(AVG(trips.duration_minutes)) AS avg_duration_mins,
	ROUND(MIN(trips.duration_minutes)) AS min_duration_mins,
	ROUND(MAX(trips.duration_minutes)) AS max_duration_mins,
    ROUND(AVG(trips.duration_minutes) FILTER (WHERE demo.user_type_id = 2)) AS avg_subscriber_duration_mins,
    ROUND(AVG(trips.duration_minutes) FILTER (WHERE demo.user_type_id = 1)) AS avg_customer_duration_mins,
    ROUND(AVG(trips.duration_minutes) FILTER (WHERE demo.user_type_id = 0)) AS avg_unknown_duration_mins
   FROM citi_bike_weather.trip_info trips 
     RIGHT JOIN citi_bike_weather.date_info ON trips.datekey = date_info.datekey
     LEFT JOIN citi_bike_weather.trip_user_info demo ON trips.trip_id = demo.trip_id
  GROUP BY date_info.month, date_info.month_name
  ORDER BY date_info.month; 


--Summary of trips throughout the year by weekday--
CREATE VIEW citi_bike_weather.weekday_summary AS
SELECT 
 daily.day_name,
 round(avg(daily.trips_total)) AS avg_total_trips,
 round(avg(daily.subscriber_trips)) AS avg_subscriber_trips,
 round(avg(daily.customer_trips)) AS avg_customer_trips,
 round(avg(daily.unknown_trips)) AS avg_unknown_trips
FROM citi_bike_weather.daily_trip_counts daily
 GROUP BY daily.day_name
 ORDER BY (round(avg(daily.trips_total))) DESC;


--Summary of trips throughout the year by demographics--
CREATE VIEW citi_bike_weather.demographic_summary AS
SELECT
	demo.age,
	gender.gender,
	ut.user_type,
	COUNT(trips.trip_id) AS num_trips
FROM citi_bike_weather.trip_info trips
	LEFT JOIN citi_bike_weather.trip_user_info demo ON trips.trip_id = demo.trip_id
	LEFT JOIN citi_bike_weather.user_type ut ON demo.user_type_id = ut.id
	LEFT JOIN citi_bike_weather.gender gender ON demo.gender_id = gender.id
GROUP BY demo.age, gender.gender, ut.user_type
ORDER BY demo.age, gender.gender, ut.user_type;


--Summary of trips throughout the year by hour--
CREATE VIEW citi_bike_weather.hourly_summary AS
SELECT 
	EXTRACT(HOUR FROM trips.start_time) AS start_hour,
    COUNT(*) AS trips_total,
	COUNT(trips.trip_id) FILTER (WHERE demo.user_type_id = 2) AS subscriber_trips,
    COUNT(trips.trip_id) FILTER (WHERE demo.user_type_id = 1) AS customer_trips,
    COUNT(trips.trip_id) FILTER (WHERE demo.user_type_id = 0) AS unknown_trips
FROM citi_bike_weather.trip_info trips
	LEFT JOIN citi_bike_weather.trip_user_info demo ON trips.trip_id = demo.trip_id
GROUP BY (EXTRACT(HOUR FROM trips.start_time))
ORDER BY (EXTRACT(HOUR FROM trips.start_time));

