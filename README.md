# Supply Chain Performance Analysis using PostgreSQL

## Project Overview

This project analyzes a supply chain dataset using **PostgreSQL** to
uncover operational inefficiencies, supplier performance issues,
delivery delays, and shipping cost leakages.

## Business Objectives

-   Measure supplier delivery performance
-   Track OTIF deliveries
-   Identify shipping cost overruns
-   Detect high-risk suppliers
-   Analyze regional delivery delays
-   Monitor monthly cost leakage trends
-   Find purchase orders with quantity shortages

## Tools Used

-   PostgreSQL
-   pgAdmin 4
-   SQL

## Database Schema

-   deliveries
-   purchase_orders
-   suppliers
-   products
-   shipment_modes

## Data Preparation

-   Imported CSV files
-   Joined tables into a reusable analytical view named **supply_chain**

## KPIs

-   Delivery Delay
-   OTIF (On-Time In-Full)
-   Cost Overrun

## Business Questions Solved

1.  High-risk suppliers
2.  Shipping modes with highest cost overruns
3.  Regional delivery delays
4.  Short shipment analysis
5.  Monthly cost leakage trend

## SQL Concepts

-   Joins
-   Views
-   CASE
-   Aggregate Functions
-   GROUP BY
-   HAVING
-   FILTER
-   Date Functions

## Skills Demonstrated

-   SQL
-   Supply Chain Analytics
-   KPI Development
-   Business Analysis

## Repository Structure

``` text
├── supply-chain-gem.sql
├── deliveries.csv
├── purchase_orders.csv
├── products.csv
├── suppliers.csv
├── shipment_modes.csv
└── README.md
```

## Key Takeaway

This project demonstrates practical SQL skills by solving real-world
supply chain business problems and generating actionable operational
insights.
