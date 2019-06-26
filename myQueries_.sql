/*================ Usage Volume Overview================== */

/* The total number of trips for the years of 2016 */
SELECT * FROM trips
WHERE `end_date` BETWEEN "2016-01-01" AND "2016-12-31" AND `start_date` BETWEEN "2016-01-01" AND "2016-12-31";

/* The total number of trips for the years of 2017 */
SELECT * FROM trips
WHERE `end_date` BETWEEN "2017-01-01" AND "2017-12-31" AND `start_date` BETWEEN "2017-01-01" AND "2017-12-31";

/* The total number of trips for the years of 2016 broken-down by month */
SELECT COUNT(*), MONTH(end_date)
FROM trips
WHERE `end_date` BETWEEN "2016-01-01" AND "2016-12-31" AND `start_date` BETWEEN "2016-01-01" AND "2016-12-31"
group by MONTH(end_date)
order by MONTH(end_date);

/* The total number of trips for the years of 2017 broken-down by month */
SELECT COUNT(*), MONTH(end_date)
FROM trips
WHERE `end_date` BETWEEN "2017-01-01" AND "2017-12-31" AND `start_date` BETWEEN "2017-01-01" AND "2017-12-31"
group by MONTH(end_date)
order by MONTH(end_date);

/* The average number of trips a day for each month of 2016 in the dataset*/
select avg(num)
FROM
(
SELECT COUNT(*) as num, DAY(end_date)
FROM trips
WHERE MONTH(end_date)= 4 and YEAR(end_date)= 2016 /* change month accordingly*/
group by DAY(end_date)
order by DAY(end_date)
) a

/* The average number of trips a day for each month of 2017 in the dataset*/
select avg(num) 
FROM
(
SELECT COUNT(*) as num, DAY(end_date)
FROM trips
WHERE MONTH(end_date)= 4 and YEAR(end_date)= 2017 /* change month accordingly*/
group by DAY(end_date)
order by DAY(end_date)
) a

/*The total number of trips in the year 2017 broken-down by membership status (member/non-member).*/
SELECT COUNT(*), is_member
FROM trips
WHERE YEAR(`end_date`)= 2017
group by is_member;

/* 2.	The fraction of total trips that were done by members for the year of 2017 broken-down by month. */
/* Getting the total trips in 2017 monthly breakdown*/

SELECT COUNT(*) as total, MONTH(end_date)
FROM trips
WHERE `end_date` BETWEEN "2017-01-01" AND "2017-12-31" AND `start_date` BETWEEN "2017-01-01" AND "2017-12-31"
group by MONTH(end_date)
order by MONTH(end_date)

/* Getting the total trips in 2017 monthly breakdown by members only*/
SELECT COUNT(*) as total, MONTH(end_date)
FROM trips
WHERE `end_date` BETWEEN "2017-01-01" AND "2017-12-31" AND `start_date` BETWEEN "2017-01-01" AND "2017-12-31" and is_member= 1
group by MONTH(end_date)
order by MONTH(end_date)

/*================ Trip Characteristics================== */

/* average trip time across entire dataset*/
SELECT avg(duration_sec)
FROM trips

/* average trip time by membership status*/
SELECT avg(duration_sec), is_member
FROM trips
group by is_member

/* average trip time monthly breakdown*/
SELECT avg(duration_sec), MONTH(end_date)
FROM trips
group by MONTH(end_date)
order by MONTH(end_date)

/* average trip time day of the week breakdown*/
SELECT avg(duration_sec), DAYOFWEEK(end_date)
FROM trips
group by DAYOFWEEK(end_date)
order by DAYOFWEEK(end_date)

/* station with longest trips on average*/
SELECT avg(duration_sec), start_station_code
FROM trips
group by start_station_code
order by avg(duration_sec) desc
limit 1

/* station with shortest trips on average*/
SELECT avg(duration_sec), start_station_code
FROM trips
group by start_station_code
order by avg(duration_sec) asc
limit 1

/* Fraction of round trips broken down by membership status*/
SELECT sum(case when start_station_code = end_station_code then 1 else 0 end)/count(*) as total, is_member
FROM trips
group by is_member

/* Fraction of round trips broken down by day of the week*/
SELECT sum(case when start_station_code = end_station_code then 1 else 0 end)/count(*) as total, DAYOFWEEK(end_date)
FROM trips
group by DAYOFWEEK(end_date)
order by DAYOFWEEK(end_date)

/*================ Popular Stations================== */

/* Names of the most popular starting stations*/
SELECT count(*), trips.start_station_code, stations.name
FROM trips
INNER JOIN stations ON trips.start_station_code = stations.code
group by trips.start_station_code, stations.name
order by count(*) desc
limit 5


/* Names of the most popular ending stations*/
SELECT count(*), trips.end_station_code, stations.name
FROM trips
INNER JOIN stations ON trips.end_station_code = stations.code
group by trips.end_station_code, stations.name
order by count(*) desc
limit 5

/* Distribution of starts for station Mackay / de Maisonneuve */
select count(*), a.time_of_day
from
(
SELECT count(*) as total, start_date, start_station_code,
CASE
    WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
    WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
    WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
    ELSE "night"
END AS "time_of_day"
FROM trips
where start_station_code= '6100'
group by start_date, start_station_code
) a
group by a.time_of_day
order by a.time_of_day;

/* Distribution of ends for station Mackay / de Maisonneuve */
select count(*), a.time_of_day
from
(
SELECT count(*) as total, end_date, start_station_code,
CASE
    WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN "morning"
    WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN "afternoon"
    WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN "evening"
    ELSE "night"
END AS "time_of_day"
FROM trips
where start_station_code= '6100'
group by end_date, start_station_code
) a
group by a.time_of_day
order by a.time_of_day;

/* Station with the least number of member trips -- consider stations with at least 10 starting and ending trips*/
SELECT count(*), trips.end_station_code, stations.name
FROM trips
INNER JOIN stations ON trips.end_station_code = stations.code
where is_member=1
group by trips.end_station_code, stations.name
having count(trips.end_station_code) >=10 and count(trips.start_station_code) >=10
order by count(*) asc
limit 1

/* Station with the most number of member trips -- consider stations with at least 10 starting and ending trips*/
SELECT count(*), trips.end_station_code, stations.name
FROM trips
INNER JOIN stations ON trips.end_station_code = stations.code
where is_member=1
group by trips.end_station_code, stations.name
having count(trips.end_station_code) >=10 and count(trips.start_station_code) >=10
order by count(*) desc
limit 1

/* all stations for which at least 10% of trips are round trips -- consider stations with at least 50 starting trips */
/* Query that counts the number of starting trips per station */
SELECT count(*), trips.start_station_code, stations.name
FROM trips
INNER JOIN stations ON trips.end_station_code = stations.code
group by trips.start_station_code, stations.name

/* query that counts, for each station, the number of round trips. */
SELECT sum(case when start_station_code = end_station_code then 1 else 0 end) as total, trips.start_station_code, stations.name
FROM trips
INNER JOIN stations ON trips.end_station_code = stations.code
group by trips.start_station_code, stations.name

/* the fraction of round trips to the total number of starting trips for each station. -- considering stations with at least 50 starting trips*/
SELECT sum(case when start_station_code = end_station_code then 1 else 0 end)/count(*) as fraction, stations.name
FROM trips
INNER JOIN stations ON trips.end_station_code = stations.code
group by stations.name
having count(trips.start_station_code) >=50

/* FINAL RESULTS FOR Q5 -- all stations for which at least 10% of trips are round trips -- considering stations with at least 50 starting trips */
SELECT sum(case when start_station_code = end_station_code then 1 else 0 end)/count(*) as fraction, stations.name
FROM trips
INNER JOIN stations ON trips.end_station_code = stations.code
group by stations.name
having count(trips.start_station_code) >=50 and fraction >=0.10
order by fraction
