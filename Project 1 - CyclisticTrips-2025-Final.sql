SELECT *
FROM [Portfolio Project - Cyclistic].dbo.TripData2025


--COMPARING CASUALS VS. MEMBERS: BIKE TRIPS
--Looking at Trip Totals
SELECT 
    Member_Casual, 
    COUNT(*) as Trip_Totals
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual
ORDER BY Trip_Totals DESC;

SELECT 
    Member_Casual, 
    COUNT(*) as Trip_Totals, 
    COUNT(*)*1.0/SUM(COUNT(*)) OVER() AS Trip_Percentage
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual
ORDER BY Trip_Totals DESC;


--CASUAL VS. MEMBER: TRIP TIMES
--Looking at Total Trip Time & Percentages
SELECT 
    Member_Casual, 
    (SUM(CAST(Trip_Time AS DECIMAL(30,2))))/60 AS Trip_Time_Totals, 
    SUM(CAST(Trip_Time AS DECIMAL(30,2)))*1.0/SUM(SUM(CAST(Trip_Time AS DECIMAL(30,2)))) OVER() AS Trip_Time_Percentage,
    AVG(CAST(Trip_Time AS DECIMAL(20,2))) AS Avg_Time_Totals
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual
ORDER BY Trip_Time_Totals DESC;

--Looking at Total Trip Time, Percentage, & Average
SELECT 
    Member_Casual, 
    SUM(CAST(Trip_Time AS DECIMAL(30,2))) AS Trip_Time_Totals, 
    SUM(CAST(Trip_Time AS DECIMAL(30,2)))*1.0/SUM(SUM(CAST(Trip_Time AS DECIMAL(30,2)))) OVER() AS Trip_Time_Percentage,
    AVG(CAST(Trip_Time AS DECIMAL(20,2))) AS Avg_Time_Totals
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual
ORDER BY Trip_Time_Totals DESC;


--CASUAL VS. MEMBER: BIKE TYPES
--Looking at Bike Type Totals
SELECT 
    Rideable_Type, COUNT(*) as Bike_Total
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Rideable_Type
ORDER BY Bike_Total DESC;

--Looking at Bike Type Totals, Averages, & Bike Type Percentages
SELECT 
    Member_Casual, 
    Rideable_Type, 
    COUNT(*) AS Bike_Total, 
    COUNT(*)*1.0/SUM(COUNT(*)) OVER (PARTITION BY Member_Casual) AS bike_percentage
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual, Rideable_Type
ORDER BY Member_Casual, Bike_Total DESC;


--CASUAL VS MEMBER: LOOKING AT DAYS & MONTHS
--Looking at Total Trips Per Day
SELECT 
    DATENAME(WEEKDAY, Start_Date) AS Day_of_Week, 
    COUNT(*) AS Total_Trips_Per_Day, 
    COUNT(DISTINCT CAST(Start_Date AS DATE)) AS Occurrences_of_Day
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY DATENAME(WEEKDAY, Start_Date)
ORDER BY DATEPART(WEEKDAY, MIN(Start_Date))

SELECT 
    Member_Casual, 
    DATENAME(WEEKDAY, Start_Date) AS Day_of_Week, 
    COUNT(*) AS Total_Trips_Per_Day, 
    COUNT(DISTINCT CAST(Start_Date AS DATE)) AS Occurrences_of_Day,
    COUNT(*) OVER(PARTITION BY Member_Casual) AS Membership
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual, DATENAME(WEEKDAY, Start_Date)
ORDER BY Member_Casual, DATEPART(WEEKDAY, MIN(Start_Date))

--Looking at Total Trips Per Day & Averages
SELECT 
    Member_Casual, 
    DATENAME(WEEKDAY, Start_Date) AS Day_of_Week, 
    (DATEDIFF(day, -1, Start_Date) % 7 + 1) AS Day_Number, COUNT(*) AS Total_Trips, 
    COUNT(*)*1.0/SUM(COUNT(*)) OVER(PARTITION BY Member_Casual) AS Trip_Percentage
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY DATENAME(WEEKDAY, Start_Date), (DATEDIFF(DAY, -1, Start_Date) % 7 + 1), Member_Casual
ORDER BY Member_Casual, DATEPART(WEEKDAY, MIN(Start_Date))

--Looking at Total Trips on Weekdays vs. Weekends
SELECT
    CASE 
        WHEN (DATEDIFF(DAY, 0, start_date) % 7) IN (5, 6) THEN 'Weekend' -- 5=Saturday, 6=Sunday
        ELSE 'Weekday'
    END AS DayType,
    COUNT(*) AS Total_Trips
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY 
    CASE 
        WHEN (DATEDIFF(DAY, 0, start_date) % 7) IN (5, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END;

--Looking at Total Trips & Percentages on Weekdays vs. Weekends
SELECT 
    Member_Casual,
    CASE 
        WHEN (DATEDIFF(DAY, 0, start_date) % 7) IN (5, 6) THEN 'Weekend' -- 5=Saturday, 6=Sunday
        ELSE 'Weekday'
    END AS DayType,
    COUNT(*) AS Total_Trips, COUNT(*)*1.0/SUM(COUNT(*)) OVER(PARTITION BY Member_Casual) AS Trip_Percentage
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual,
    CASE 
        WHEN (DATEDIFF(DAY, 0, start_date) % 7) IN (5, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END;

--Looking at Trips per Month & Percentages
SELECT 
    Member_Casual, 
    MONTH(Start_Date) AS Month_Number, 
    COUNT(*) AS Trip_Count, 
    COUNT(*)*1.00/SUM(COUNT(*)) OVER(PARTITION BY Member_Casual) AS Trip_Percentage
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual, MONTH(Start_Date)
ORDER BY Member_Casual, Month_Number ASC

--Looking at Trips per Quarter
SELECT 
    DATEPART(qq, Start_Date) AS QuarterNumber, 
    COUNT(*) AS Trip_Count,
    COUNT(*)*1.0/SUM(COUNT(*)) OVER() AS Trip_Percentage
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY DATEPART(qq, Start_Date)
ORDER BY QuarterNumber ASC

--Looking at Trips per Quarter with Membership Status
SELECT 
    Member_Casual, 
    DATEPART(qq, Start_Date) AS QuarterNumber, 
    COUNT(*) AS Trip_Count,
    COUNT(*)*1.00/SUM(COUNT(*)) OVER(PARTITION BY Member_Casual) AS Trip_Percentage
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY DATEPART(qq, Start_Date), Member_Casual
ORDER BY Member_Casual, QuarterNumber ASC

--CASUAL VS MEMBER: TRIP START TIMES/HOUR 
--Looking at Combined Total Trips Per Start Hour
SELECT 
    Start_Hour, 
    COUNT(*) AS Trip_Count
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Start_Hour
ORDER BY Start_Hour ASC, Trip_Count

--Looking at Total Trips Per Start Hour (Ordered by Rank)
SELECT 
    Member_Casual, 
    Start_Hour, 
    COUNT(*) AS Trip_Count, 
    RANK() OVER (PARTITION BY Member_Casual ORDER BY COUNT(Start_Hour) DESC) AS Trip_Count_Rank
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual, Start_Hour
ORDER BY Member_Casual, Trip_Count DESC, Trip_Count_Rank

--Looking at the Top 10 Total Trips Per Start Hour (Ordered by Rank)
SELECT 
    TOP 10 Member_Casual, 
    Start_Hour, COUNT(*) AS Trip_Count, 
    RANK() OVER (PARTITION BY Member_Casual ORDER BY COUNT(Start_Hour) DESC) AS Sub_Status
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual, Start_Hour
ORDER BY Member_Casual, Trip_Count DESC, Sub_Status 

--Looking at the Top 10 Trip Totals Per Start Hour: Grouped by Membership Status (Ordered by Rank)
SELECT 
    Member_Casual, 
    Start_Hour, 
    Trip_Count, 
    Trip_Count_Rank 
FROM 
	(
	SELECT 
        Member_Casual, 
        Start_Hour, 
        COUNT(*) AS Trip_Count, 
        RANK() OVER (PARTITION BY Member_Casual ORDER BY COUNT(Start_Hour) DESC) AS Trip_Count_Rank
	FROM [Portfolio Project - Cyclistic].dbo.TripData2025
	GROUP BY Member_Casual, Start_Hour
	) t
WHERE Trip_Count_Rank <=10
GROUP BY Member_Casual, Start_Hour, Trip_Count, Trip_Count_Rank
ORDER BY Member_Casual, Trip_Count_Rank ASC

--Looking at the Average Start Hour Per Day
SELECT 
    Member_Casual, 
    DATENAME(WEEKDAY, Start_Date) AS Day_Name, 
    (DATEDIFF(day, -1, Start_Date) % 7 + 1) AS Day_Number, 
    AVG(Total_Start_Hour) AS Avg_Start_Time,
    RANK() OVER(PARTITION BY Member_Casual ORDER BY AVG(CAST(trip_time AS DECIMAL(10,2)))) AS Trip_Rank
FROM
    (
    SELECT 
        Member_Casual, 
        Start_Date, 
        Start_Hour, 
        Trip_Time, 
        SUM(Start_Hour) AS Total_Start_Hour
    FROM [Portfolio Project - Cyclistic].dbo.TripData2025
    GROUP BY Member_Casual, Start_Date, Start_Hour, Trip_Time
    )t
GROUP BY Member_Casual, DATENAME(WEEKDAY, Start_Date), (DATEDIFF(day, -1, Start_Date) % 7 + 1)
ORDER BY Member_Casual, Day_Number ASC

--Looking at Trip Start Hour Totals & Percentages
WITH HourlyTrips AS (
    SELECT 
        Member_Casual, 
        Start_Hour, 
        COUNT(*) AS Total_Trips
    FROM [Portfolio Project - Cyclistic].dbo.TripData2025
    GROUP BY Member_Casual, Start_Hour
)
SELECT 
    Member_Casual,
    Start_Hour,
    Total_Trips,
    Total_Trips * 1.0 
        / SUM(Total_Trips) OVER (PARTITION BY Member_Casual) 
        AS Start_Hour_Percentage
FROM HourlyTrips
ORDER BY Member_Casual, Start_Hour;


--Looking at Top 5 Trip Start Hour
SELECT 
    Member_Casual, 
    Start_Hour, 
    Total_Trip_Count, 
    Trip_Percentage, 
    Start_Hours_Rank
FROM (
    SELECT 
        Member_Casual, 
        Start_Hour, 
        COUNT(*) AS Total_Trip_Count,
        RANK() OVER(PARTITION BY Member_Casual ORDER BY COUNT(*)DESC) AS Start_Hours_Rank, 
        COUNT(*)*1.0/SUM(COUNT(*)) OVER(PARTITION BY Member_Casual) AS Trip_Percentage
    FROM [Portfolio Project - Cyclistic].dbo.TripData2025
    GROUP BY Member_Casual, Start_Hour
    )t
WHERE Start_Hours_Rank <= '5'
ORDER BY Member_Casual, Start_Hours_Rank, Start_Hour

--Looking at Most Used Trip Start Hour
SELECT 
    Member_Casual, 
    (DATEDIFF(day, -1, Start_Date) % 7 + 1) AS DayNumber, 
    Count(*) AS Total_Trips 
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY (DATEDIFF(day, -1, Start_Date) % 7 + 1), Member_Casual
ORDER BY Member_Casual, Total_Trips DESC, DayNumber ASC


--CASUAL VS MEMBER: TRIP DURIATION
--Looking at Total Trip Duriation Per Start Hour (Ordered by Rank)
SELECT 
    Member_Casual, 
    Start_Hour, 
    SUM(Trip_Time) AS Total_Trip_Time,
    RANK() OVER(PARTITION BY Member_Casual ORDER BY SUM(Trip_Time)) AS Trip_Rank
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual, Start_Hour
ORDER BY Member_Casual, Trip_Rank;

--Looking at the Average Trip Duriation Per Day
SELECT 
    DATENAME(WEEKDAY, Start_Date) AS Day_Name, 
    (DATEDIFF(day, -1, Start_Date) % 7 + 1) AS Day_Number, 
    AVG(CAST(trip_time AS DECIMAL(10,2))) AS Average_Trip 
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY DATENAME(WEEKDAY, Start_Date), (DATEDIFF(day, -1, Start_Date) % 7 + 1)
ORDER BY Day_Number ASC 

--Looking at the Average Trip Duriation Per Day (Including Membership Status)
SELECT 
    Member_Casual, 
    DATENAME(WEEKDAY, Start_Date) AS Day_Name, 
    (DATEDIFF(DAY, -1, Start_Date) % 7 + 1) AS Day_Number,
    AVG(CAST(trip_time AS DECIMAL(10,2))) AS Average_Trip_Time,
    RANK() OVER(PARTITION BY Member_Casual ORDER BY AVG(CAST(trip_time AS DECIMAL(10,2)))) AS Trip_Rank
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual, DATENAME(WEEKDAY, Start_Date), (DATEDIFF(DAY, -1, Start_Date) % 7 + 1)
ORDER BY Member_Casual, Day_Number ASC, Trip_Rank;

--Looking at Max Trip Duration
SELECT 
    Member_Casual, 
    Start_Hour, 
    RANK() OVER(PARTITION BY Member_Casual ORDER BY MAX(CAST(Trip_Time AS DECIMAL(10,2)))) AS Max_Trip_Duration 
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual, Start_Hour
ORDER BY Member_Casual, MAX(CAST(Trip_Time AS DECIMAL(10,2))) DESC


--ANALYZING TRIPS BY START STATIONS
--Identifying When Tracking Stations Began
SELECT 
    Start_Station_Name, 
    Start_Date
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
WHERE Start_Station_Name IS NOT NULL
ORDER BY Start_Date

SELECT 
    Start_Station_Name, 
    COUNT (*) AS Start_Station_Count,
    COUNT(*)*1.00/SUM(COUNT(*)) OVER() AS Percent_of_Count
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Start_Station_Name
ORDER BY Start_Station_Name

SELECT 
    Start_Station_Name, 
    Start_Station_ID,
    COUNT(Start_Station_ID) AS Start_Station_Count,
    SUM(Trip_Time) AS Total_Trip_Time,
    COUNT(*)*1.00/SUM(COUNT(*)) OVER() AS Percent_of_Count,
    Member_Casual 
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
WHERE Start_Station_Name IS NOT NULL AND Start_Station_ID IS NOT NULL
GROUP BY Start_Station_Name, Start_Station_Id, Member_Casual
ORDER BY Start_Station_Count DESC, Member_Casual DESC;

--Route Information Including Latitude & Longitude (Map)
SELECT 
    Start_Station_Name, 
    End_Station_Name, 
    Start_Lat, 
    Start_Lng, 
    End_Lat, 
    End_Lng, 
    COUNT(*) AS Route_Trip_Total, 
    AVG(Trip_Time) AS Avg_Trip_Duration
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
WHERE Start_Station_Name IS NOT NULL
GROUP BY Start_Station_Name, End_Station_Name, Start_Lat, Start_Lng, End_Lat, End_Lng
ORDER BY Route_Trip_Total DESC, Start_Station_Name DESC;

SELECT 
    Member_Casual, 
    Start_Station_Name, 
    End_Station_Name, 
    Start_Lat, 
    Start_Lng, 
    End_Lat, 
    End_Lng, 
    COUNT(*) AS Route_Trip_Total
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
WHERE Start_Station_Name IS NOT NULL
GROUP BY Member_Casual, Start_Station_Name, End_Station_Name, Start_Lat, Start_Lng, End_Lat, End_Lng
ORDER BY Member_Casual, Route_Trip_Total DESC, Start_Station_Name DESC; 

SELECT 
    Start_Station_Name, 
    End_Station_Name, 
    'Start' AS Point_Type,
    Start_Lat AS Latitude, 
    Start_Lng AS Longitude,
    COUNT(*) AS Route_Trip_Total, 
    AVG(Trip_Time) AS Avg_Trip_Duration
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
WHERE Start_Station_Name IS NOT NULL
GROUP BY Start_Station_Name, End_Station_Name, Start_Lat, Start_Lng
UNION ALL
SELECT
    Start_Station_Name, 
    End_Station_Name, 
    'End' AS Point_Type,
    End_Lat AS Latitude, 
    End_Lng AS Longitude,
    COUNT(*) AS Route_Trip_Total, 
    AVG(Trip_Time) AS Avg_Trip_Duration
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
WHERE Start_Station_Name IS NOT NULL
GROUP BY Start_Station_Name, End_Station_Name, End_Lat, End_Lng
ORDER BY Route_Trip_Total DESC, Start_Station_Name DESC;

--
WITH RouteStats AS (
    SELECT 
        Ride_Id,
        Start_Station_Name,
        Start_Station_Id,
        End_Station_Name,
        End_Station_Id,
        Start_Lat, 
        Start_Lng,
        End_Lat,
        End_Lng,
        Trip_Time,
        --Calculating the route total across the whole dataset
        COUNT(*) OVER(PARTITION BY Start_Station_Name, End_Station_Name) AS Route_Trip_Total, 
        AVG(Trip_Time) OVER(PARTITION BY Start_Station_Name, End_Station_Name) AS Avg_Trip_Duration
    FROM [Portfolio Project - Cyclistic].dbo.TripData2025
    WHERE Start_Station_Name IS NOT NULL AND End_Station_Name IS NOT NULL
)
SELECT 
    Ride_Id,
    Start_Station_Name,
    Start_Station_Id,
    End_Station_Name,
    End_Station_Id, 'Start' AS Point_Type, 
    Start_Lat AS Latitude, 
    Start_Lng AS Longitude, 
    Route_Trip_Total, 
    Avg_Trip_Duration
FROM RouteStats
WHERE Route_Trip_Total >= 3000

UNION ALL

SELECT 
    Ride_Id, 
    Start_Station_Name,
    Start_Station_Id,
    End_Station_Name,
    End_Station_Id, 'End' AS Point_Type, 
    End_Lat AS Latitude, 
    End_Lng AS Longitude, 
    Route_Trip_Total, 
    Avg_Trip_Duration

FROM RouteStats
WHERE Route_Trip_Total >= 3000;

--Top 10 Start Stations (Add popular locations around these stations to presentation)
SELECT 
    TOP 10 COUNT(*) AS Station_Count, 
    Start_Station_Name
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
WHERE Start_Station_Name IS NOT NULL
GROUP BY Start_Station_Name 
ORDER BY Station_Count DESC;

SELECT 
    TOP 10 COUNT(*) AS Station_Count, 
    Start_Station_Name, 
    Member_Casual 
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
WHERE Member_Casual ='casual' AND Start_Station_Name IS NOT NULL
GROUP BY Start_Station_Name, Member_Casual
ORDER BY Member_Casual, Station_Count DESC;

SELECT 
    TOP 10 COUNT(Start_Station_Name) AS Station_Count, 
    Start_Station_Name, 
    Member_Casual 
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
WHERE Member_Casual ='member' AND Start_Station_Name IS NOT NULL
GROUP BY Start_Station_Name, Member_Casual
ORDER BY Member_Casual, Station_Count DESC;

--Top 10 Start Stations by Day
WITH StationRankings AS (
    SELECT 
        DATENAME(WEEKDAY, Start_Date) AS Day_Name, 
        (DATEDIFF(day, -1, Start_Date) % 7 + 1) AS Day_Number,
        Start_Station_Name,
        COUNT(*) AS Station_Count,
        ROW_NUMBER() OVER (PARTITION BY DATENAME(WEEKDAY, Start_Date) ORDER BY COUNT(*) DESC) AS Rank_Per_Day
    FROM [Portfolio Project - Cyclistic].dbo.TripData2025
    WHERE Start_Station_Name IS NOT NULL
    GROUP BY DATENAME(WEEKDAY, Start_Date), (DATEDIFF(day, -1, Start_Date) % 7 + 1), Start_Station_Name
)
SELECT 
    Day_Name, 
    Station_Count, 
    Start_Station_Name
FROM StationRankings
WHERE Rank_Per_Day <= 10
ORDER BY Day_Number, Station_Count DESC;

--VISUALIZATION VIEWS FOR TABLEAU DASHBOARD
--DASHBOARD #1 VISUALIZATION
--Dashboard #1 | View #1: Casual vs. Member: Total Trips (PieChart)
CREATE VIEW TotalTrips AS 
SELECT 
    Member_Casual, 
    COUNT(*) as Trip_Totals
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual
ORDER BY Trip_Totals DESC;

--Dashboard #1 | View #2: Casual vs. Member: Total Trip Time & Average (PieChart)
CREATE VIEW TotalTripTime AS 
SELECT 
    Member_Casual, 
    (SUM(CAST(Trip_Time AS DECIMAL(30,2))))/60 AS Trip_Time_Totals, 
    SUM(CAST(Trip_Time AS DECIMAL(30,2)))*1.0/SUM(SUM(CAST(Trip_Time AS DECIMAL(30,2)))) OVER() AS Trip_Time_Percentage,
    AVG(CAST(Trip_Time AS DECIMAL(20,2))) AS Avg_Time_Totals
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual
ORDER BY Trip_Time_Totals DESC;

--Dashboard #1 | View #3: Casual vs. Member: Bike Type (PieChart)
CREATE VIEW BikeTypes AS 
SELECT 
    Member_Casual, 
    Rideable_Type, 
    COUNT(*) AS Bike_Total, 
    COUNT(*)*1.0/SUM(COUNT(*)) OVER (PARTITION BY Member_Casual) AS bike_percentage
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual, Rideable_Type
ORDER BY Member_Casual, Bike_Total DESC;

--Dashboard #1 | View #4: Total Trips Per Day
CREATE VIEW TotalTripsPerDay AS 
SELECT 
    Member_Casual, 
    DATENAME(WEEKDAY, Start_Date) AS Day_of_Week, 
    COUNT(*) AS Total_Trips_Per_Day, 
    COUNT(DISTINCT CAST(Start_Date AS DATE)) AS Occurrences_of_Day,
    COUNT(*) OVER(PARTITION BY Member_Casual) AS Membership
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual, DATENAME(WEEKDAY, Start_Date)
ORDER BY Member_Casual, DATEPART(WEEKDAY, MIN(Start_Date))

--Dashboard #1 | View #5: Combined Total Trips Per Start Hour
CREATE VIEW TotalTripsPerStartHour AS 
SELECT 
    Start_Hour, 
    COUNT(*) AS Trip_Count
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Start_Hour
ORDER BY Start_Hour ASC, Trip_Count

--Dashboard #1 | View #6: Start Stations
CREATE VIEW BikeStartStations AS 
SELECT 
    Start_Station_Name, 
    Start_Station_ID,
    COUNT(Start_Station_ID) AS Start_Station_Count,
    SUM(Trip_Time) AS Total_Trip_Time,
    COUNT(*)*1.00/SUM(COUNT(*)) OVER() AS Percent_of_Count,
    Member_Casual 
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
WHERE Start_Station_Name IS NOT NULL AND Start_Station_ID IS NOT NULL
GROUP BY Start_Station_Name, Start_Station_Id, Member_Casual
ORDER BY Start_Station_Count DESC, Member_Casual DESC;


--DASHBOARD #2 VISUALIZATION
--Dashboard #2 | View #1: Total Trips per Quarter with Membership Status
CREATE VIEW TripsPerQuarter AS 
SELECT 
    Member_Casual, 
    DATEPART(qq, Start_Date) AS QuarterNumber, 
    COUNT(*) AS Trip_Count,
    COUNT(*)*1.00/SUM(COUNT(*)) OVER(PARTITION BY Member_Casual) AS Trip_Percentage
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY DATEPART(qq, Start_Date), Member_Casual
ORDER BY Member_Casual, QuarterNumber ASC

--Dashboard #2 | View #2: Total Trips per Month & Percentages
CREATE VIEW TripsPerMonth AS 
SELECT 
    Member_Casual, 
    MONTH(Start_Date) AS Month_Number, 
    COUNT(*) AS Trip_Count, 
    COUNT(*)*1.00/SUM(COUNT(*)) OVER(PARTITION BY Member_Casual) AS Trip_Percentage
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual, MONTH(Start_Date)
ORDER BY Member_Casual, Month_Number ASC

--Dashboard #2 | View #3: Total Trips Per Day & Averages
CREATE VIEW TripsPerDay AS 
SELECT 
    Member_Casual, 
    DATENAME(WEEKDAY, Start_Date) AS Day_of_Week, 
    (DATEDIFF(day, -1, Start_Date) % 7 + 1) AS Day_Number, 
    COUNT(*) AS Total_Trips, 
    COUNT(*)*1.0/SUM(COUNT(*)) OVER(PARTITION BY Member_Casual) AS Trip_Percentage
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY DATENAME(WEEKDAY, Start_Date), (DATEDIFF(DAY, -1, Start_Date) % 7 + 1), Member_Casual
ORDER BY Member_Casual, DATEPART(WEEKDAY, MIN(Start_Date))

--Dashboard #2 | View #4: Casual vs Member: On Weekdays & Weekends
CREATE VIEW WeekdaysVsWeekends AS 
SELECT Member_Casual,
    CASE 
        WHEN (DATEDIFF(DAY, 0, start_date) % 7) IN (5, 6) THEN 'Weekend' -- 5=Saturday, 6=Sunday
        ELSE 'Weekday'
    END AS DayType,
    COUNT(*) AS Total_Trips, 
    COUNT(*)*1.0/SUM(COUNT(*)) OVER(PARTITION BY Member_Casual) AS Trip_Percentage,
    SUM(Trip_Time) AS Total_Trip_Time
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual,
    CASE 
        WHEN (DATEDIFF(DAY, 0, start_date) % 7) IN (5, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END;

--Dashboard #2 | View #5: Average Start Hour Per Day & Trip Duration
CREATE VIEW AverageStartHour AS
SELECT 
    Member_Casual, 
    DATENAME(WEEKDAY, Start_Date) AS Day_Name, 
    (DATEDIFF(day, -1, Start_Date) % 7 + 1) AS Day_Number, 
    AVG(start_hour) AS Avg_Start_Time,
    RANK() OVER(PARTITION BY Member_Casual ORDER BY AVG(CAST(trip_time AS DECIMAL(10,2)))) AS Trip_Rank,
    SUM(Trip_Time) AS Total_Trip_Time
FROM [Portfolio Project - Cyclistic].dbo.TripData2025
GROUP BY Member_Casual, DATENAME(WEEKDAY, Start_Date), (DATEDIFF(day, -1, Start_Date) % 7 + 1)
ORDER BY Member_Casual, Day_Number ASC

--Dashboard #2 | View #6: Trip Start Hour Totals, Averages, & Percentages
CREATE VIEW TripStartHour AS 
WITH HourlyTrips AS (
    SELECT 
        Member_Casual, 
        Start_Hour, 
        COUNT(*) AS Total_Trips
    FROM [Portfolio Project - Cyclistic].dbo.TripData2025
    GROUP BY Member_Casual, Start_Hour
)
SELECT 
    Member_Casual,
    Start_Hour,
    Total_Trips,
    Total_Trips * 1.0 
        / SUM(Total_Trips) OVER (PARTITION BY Member_Casual) 
        AS Start_Hour_Percentage
FROM HourlyTrips
ORDER BY Member_Casual, Start_Hour;

