# Data Warehouse and Analytics Project

Welcome to the Data Warehouse and Analytics Project repository! 
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

# 📖Project Overview
This project involves:

1. Data Architecture: Designing a Modern Data Warehouse Using Medallion Architecture Bronze, Silver, and Gold layers.
2. ETL Pipelines: Extracting, transforming, and loading data from source systems into the warehouse.
3. Data Modeling: Developing fact and dimension tables optimized for analytical queries.
4. Analytics & Reporting: Creating SQL-based reports and dashboards for actionable insights.
 
This repository is an excellent resource for :

SQL Development

Data Architect

Data Engineering

ETL Pipeline Developer

Data Modeling

Data Analytics

# 📂 Project Requirements
Building the Data Warehouse (Data Engineering)

1. Objective:
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

2. Specifications:
a. Data Sources: Import data from two source systems (ERP and CRM) provided as CSV files.
b. Data Quality: Cleanse and resolve data quality issues prior to analysis.
c. Integration: Combine both sources into a single, user-friendly data model designed for analytical queries.
d. Scope: Focus on the latest dataset only; historization of data is not required.
e. Documentation: Provide clear documentation of the data model to support both business stakeholders and analytics teams.
 
 
 ## BI: Analytics & Reporting (Data Analysis)

Objective:
Develop SQL-based analytics to deliver detailed insights into:

Customer Behavior

Product Performance

Sales Trends

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

# 📂 Repository Structure

![Screenshot (168)](https://github.com/user-attachments/assets/2b364607-1bca-492f-8ff7-a493e8a2b214)



# 🏗️ Data Architecture
The data architecture for this project follows Medallion Architecture Bronze, Silver, and Gold layers:

![Screenshot (167)](https://github.com/user-attachments/assets/0a64c05e-2d7e-4420-8059-55e7a04de58e)

1. Bronze Layer: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. Silver Layer: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. Gold Layer: Houses business-ready data modeled into a star schema required for reporting and analytics.



