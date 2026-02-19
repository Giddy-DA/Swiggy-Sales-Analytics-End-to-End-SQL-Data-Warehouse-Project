USE Swiggy_Database
SELECT *
FROM Swiggy_Data;

--Data Validation & Cleaning
--Null Check

SELECT
	SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) Null_state,
	SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) Null_City,
	SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) Null_order_date,
	SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) Null_Restaurant_Name,
	SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) Null_Location,
	SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) Null_Category,
	SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) Null_Dish_Name,
	SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) Null_Price_INR,
	SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) Null_Rating,
	SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) Null_Rating_Count
FROM Swiggy_Data;

--blank or empty strings
SELECT *
FROM Swiggy_Data
WHERE State ='' OR City = '' OR Restaurant_Name ='' OR Location ='' OR Category ='' OR Dish_Name =''

--duplicate detection
SELECT 
State, City, Order_Date, Restaurant_Name, Location,Category,Dish_Name,Price_INR,Rating,Rating_Count,
COUNT(*) AS CNT
FROM Swiggy_Data
GROUP BY 
State, City, Order_Date, Restaurant_Name, Location,Category,Dish_Name,Price_INR,Rating,Rating_Count
HAVING COUNT(*)>1

--delete duplicates

WITH CTE AS(
SELECT * ,
	ROW_NUMBER() OVER(PARTITION BY 
		State, City,Order_Date,Restaurant_Name,Location,Category,Dish_Name,Price_INR,Rating,Rating_Count
	ORDER BY (SELECT NULL)
) RN
FROM swiggy_data
)
DELETE FROM CTE WHERE RN>1

---CREATING SCHEMA
---Dimension Table
--Date Table
CREATE TABLE dim_date(
	date_id INT IDENTITY(1,1) PRIMARY KEY,
	Full_date DATE,
	Year INT,
	Month INT,
	Month_Name varchar(20),
	Quarter INT,
	Day INT,
	Week INT
)
SELECT* FROM dim_date

--Location Table
CREATE TABLE dim_location(
	location_id INT IDENTITY(1,1) PRIMARY KEY,
	State VARCHAR(100),
	City VARCHAR(100),
	Location VARCHAR(200)
);

SELECT * FROM dim_location

--Restaurant Table
CREATE TABLE dim_restaurant(
	Restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
	Restaurant_name VARCHAR(200)
);
SELECT * FROM dim_restaurant

--Category Table
CREATE TABLE dim_category(
	Category_id INT IDENTITY(1,1) PRIMARY KEY,
	Dish_Name VARCHAR(200)
);
EXEC sp_rename 'dim_category.Dish_Name', 'Category', 'COLUMN';

SELECT * FROM dim_category

--dish_name Table
CREATE TABLE dim_dish(
	dish_id INT IDENTITY(1,1) PRIMARY KEY,
	Dish_name VARCHAR(200)
);
SELECT * FROM dim_dish
--Fact Table
CREATE TABLE fact_swiggy_orders(
	order_id INT IDENTITY(1,1) PRIMARY KEY,

	date_id INT,
	Price_INR DECIMAL(10,2),
	Rating DECIMAL (4,2),
	Rating_count INT,

	location_id INT,
	Restaurant_id INT,
	Category_id INT,
	dish_id INT,

	FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
	FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
	FOREIGN KEY (Restaurant_id) REFERENCES dim_restaurant(Restaurant_id),
	FOREIGN KEY (Category_id) REFERENCES dim_category(Category_id),
	FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);

SELECT * FROM fact_swiggy_orders

--INSERT DATA INTO THE TABLES
INSERT INTO dim_date (FULL_DATE, Year, Month, Month_Name, Quarter, Day, Week)
SELECT DISTINCT
	Order_Date,
	YEAR(Order_Date),
	Month(Order_Date),
	DATENAME(MONTH,Order_Date),
	DATEPART(QUARTER,Order_Date),
	DAY(Order_Date),
	DATEPART(WEEK, Order_Date)
FROM  Swiggy_Data
WHERE Order_Date IS NOT NULL;

--dim_location
INSERT INTO dim_location (State, City, Location)
SELECT DISTINCT
	State,
	City,
	Location
FROM swiggy_data;

--dim restaurant
INSERT INTO dim_restaurant (Restaurant_name)
SELECT DISTINCT
	Restaurant_Name
FROM Swiggy_Data

--dim category
INSERT INTO dim_category (Category)
SELECT DISTINCT
	Category
FROM Swiggy_Data;

--dim dish
INSERT INTO dim_dish (Dish_name)
SELECT DISTINCT
	Dish_Name
FROM Swiggy_Data;

--fact table
INSERT INTO fact_swiggy_orders
(
	date_id,
	Price_INR,
	Rating,
	Rating_count,
	location_id,
	Restaurant_id,
	Category_id,
	dish_id
)
SELECT
	dd.date_id,
	s.Price_INR,
	s.Rating,
	s.Rating_count,

	dl.location_id,
	dr.Restaurant_id,
	dc.Category_id,
	dsh.dish_id
FROM Swiggy_Data s

JOIN dim_date dd
	ON dd.FULL_DATE = s.Order_Date
JOIN dim_location dl
	ON dl.State = s.State
	AND dl.city = s.City
	AND dl.Location = s.Location
JOIN dim_restaurant dr
	ON dr.Restaurant_name = s.Restaurant_Name
JOIN dim_category dc
	ON dc.Category = s.Category
JOIN dim_dish dsh
	ON dsh.Dish_name = s.Dish_Name

SELECT * FROM fact_swiggy_orders

SELECT * FROM fact_swiggy_orders f
	JOIN dim_date d ON f.date_id = d.date_id
	JOIN dim_location l ON f.location_id = l.location_id
	JOIN dim_restaurant r ON f.Restaurant_id = r.Restaurant_id
	JOIN dim_category c ON f.Category_id = c.Category_id
	JOIN dim_dish di ON f.dish_id = di.dish_id

--KPIs
--Total Orders
SELECT COUNT(*) total_orders
FROM fact_swiggy_orders;

--Total Revenue
SELECT SUM(price_INR) total_revenue
FROM fact_swiggy_orders;

--Avg Dish price
SELECT AVG(price_INR) Avg_dish_price
FROM fact_swiggy_orders;

--Avg rating 
SELECT AVG(rating) Avg_rating
FROM fact_swiggy_orders;

--Monthly Order Trend
SELECT 
d.year,
d.Month,
d.Month_Name,
COUNT(*) Total_orders
FROM fact_swiggy_orders F
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.Month,d.Month_Name

--Monthly Revenue trend
SELECT 
d.year,
d.Month,
d.Month_Name,
SUM(price_INR) Total_revenue
FROM fact_swiggy_orders F
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.Month,d.Month_Name

--quarterly revenue trend
SELECT 
d.year,
d.quarter,
SUM(price_INR) Total_revenue
FROM fact_swiggy_orders F
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.quarter

--quarterly order trend
SELECT 
d.year,
d.quarter,
COUNT(*) Total_orders
FROM fact_swiggy_orders F
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.quarter

--Yearly trend
SELECT 
d.year,
COUNT(*) Total_orders
FROM fact_swiggy_orders F
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year

---Day of week pattern
SELECT 
	DATENAME (WEEKDAY, d.FULL_DATE) day_name, DATEPART (WEEKDAY, d.FULL_DATE),
	COUNT(*) total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY DATENAME (WEEKDAY, d.FULL_DATE), DATEPART (WEEKDAY, d.FULL_DATE)

--Top 10 cities by Revenue
SELECT TOP 10
l.City,
SUM(f.price_INR) AS Total_revenue FROM fact_swiggy_orders f
JOIN dim_location l 
ON l.location_id  = f.location_id
GROUP BY l.City
ORDER BY SUM(f.price_INR) ASC

--Revenue contribution by states
SELECT 
l.State,
SUM(f.price_INR) AS Total_revenue FROM fact_swiggy_orders f
JOIN dim_location l 
ON l.location_id  = f.location_id
GROUP BY l.State
ORDER BY SUM(f.price_INR) ASC

--Top 10 restaurants by Orders
SELECT TOP 10
r.Restaurant_name,
SUM(f.price_INR) AS Total_revenue FROM fact_swiggy_orders f
JOIN dim_restaurant r 
ON r.Restaurant_id  = f.Restaurant_id
GROUP BY r.Restaurant_name
ORDER BY SUM(f.price_INR) ASC


--Top categories (Indian, Chinese, etc.)
SELECT
c.Category,
SUM(f.price_INR) AS Total_revenue FROM fact_swiggy_orders f
JOIN dim_category c
ON c.Category_id  = f.Category_id
GROUP BY c.Category
ORDER BY SUM(f.price_INR) DESC

--Most ordered dishes
SELECT 
	d.Dish_name,
	COUNT(*)  order_count
FROM fact_swiggy_orders f
JOIN dim_dish d
ON d.dish_id  = f.dish_id
GROUP BY d.dish_name

--cuisine performance (Orders + Avg rating)
SELECT 
	c.category,
	COUNT(*) total_orders,
	AVG(f.rating) avg_rating
FROM fact_swiggy_orders f
JOIN dim_category c ON f.category_id = c.category_id
GROUP BY c.category
ORDER BY total_orders DESC

--Total orders by price range
SELECT
	CASE
		WHEN (price_INR) <100 THEN 'Under 100'
		WHEN (price_INR) BETWEEN 100 AND 199 THEN '100-199'
		WHEN (price_INR) BETWEEN 200 AND 299 THEN '200-299'
		WHEN (price_INR) BETWEEN 300 AND 499 THEN '300-499'
		ELSE '500+'
	END price_range,
	COUNT(*) total_orders
FROM fact_swiggy_orders
GROUP BY
	CASE
		WHEN (price_INR) <100 THEN 'Under 100'
		WHEN (price_INR) BETWEEN 100 AND 199 THEN '100-199'
		WHEN (price_INR) BETWEEN 200 AND 299 THEN '200-299'
		WHEN (price_INR) BETWEEN 300 AND 499 THEN '300-499'
		ELSE '500+'
	END
ORDER BY total_orders

--rating count distribution
SELECT
	rating,
	COUNT(*) rating_count
FROM fact_swiggy_orders
GROUP BY Rating
ORDER BY COUNT(*) DESC