# Swiggy-Sales-Analytics-End-to-End-SQL-Data-Warehouse-Project
This project simulates a real-world food delivery analytics system. Raw transactional data was cleaned, transformed into a star schema, and analyzed to generate business KPIs such as revenue trends, top-performing cities, cuisine performance, and pricing insights.
Tools & Technologies

SQL Server

T-SQL

Dimensional Modeling (Star Schema)

Data Cleaning & Transformation

Aggregation & Window Functions
Star Schema Design

Designed and implemented a dimensional model:

Dimension Tables

dim_date

dim_location

dim_restaurant

dim_category

dim_dish

Fact Table

fact_swiggy_orders

Surrogate keys were used to maintain referential integrity and enable scalable analytics.
ETL Process

Extracted distinct dimension values from raw data

Loaded dimension tables

Mapped surrogate keys into the fact table

Established foreign key relationships
Business KPIs & Analysis

The following metrics were generated:

Total Orders

Total Revenue

Average Dish Price

Average Rating

Monthly Revenue & Order Trends

Quarterly & Yearly Performance

Top Cities by Revenue

Top Restaurants by Performance

Cuisine Revenue Contribution

Price Range Distribution

Rating Distribution Analysis

Most Ordered Dishes
Key Insights

Revenue concentration was observed in specific high-performing cities.

Mid-range priced dishes contributed significantly to overall order volume.

Cuisine performance varied in both order count and average rating.

Seasonal trends were visible across quarters and months.
Skills Demonstrated

Data Modeling & Schema Design

Fact-Dimension Relationships

Surrogate Key Mapping

Advanced Aggregations

Business KPI Development

Translating Business Questions into SQL Logic
Future Enhancements

Implement ranking using window functions (RANK(), DENSE_RANK())

Add revenue contribution percentages

Create indexed views for performance optimization

Develop a Power BI dashboard connected to the fact table
What I Learned

Through this project, I strengthened my ability to:

Structure raw transactional data into a scalable analytical model

Build fact and dimension tables from scratch

Think beyond queries and focus on business insight generation

Design SQL workflows that mirror real-world BI systems
