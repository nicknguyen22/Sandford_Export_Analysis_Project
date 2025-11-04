# Sanford Export Analysis - Tech Test

## Overview

This project is a Business Intelligence Analyst technical test focused on New Zealand aquaculture export data (FY23-25). It evaluates the candidate’s skills in data ingestion, ETL development, and Power BI reporting, utilizing SQL Server Express as the data storage platform.

---

## Project Scope

- **Data Source:**  
  Three CSV files containing export data for fiscal years FY23, FY24, and FY25. Each includes columns for Species, Product, Country, Volume (kg), Value (NZD), and Fiscal Year.

- **Technology Stack:**  
  - SQL Server Express for ETL and data warehousing  
  - Power BI Desktop for data visualization and analysis

- **Deliverables:**  
  - ETL scripts for data cleaning and transformation  
  - Dimensional data model in SQL Server Express  
  - Power BI report answering key business questions  
  - This README serving as the sole project documentation integrating methodology and key findings

---

## Methodology

1. **Data Acquisition & Quality:**

- Source: 3 CSV files with export transactions  
- Columns include species, product, country, volume, value.
- Quality checks for nulls, zeros, and format consistency.

2. **Data Warehousing:**  

- Star schema for simplicity and performance  
- Dimensions for species, product, country, fiscal year  
- Central fact table with foreign keys and measures.

3. **Data Transformation: ETL Process**  

- Raw CSV files are loaded into staging tables via T-SQL BULK INSERT. Data quality measures address blank lines, commas within quoted text, and type mismatches.
- Populate dimensions with unique keys and business categories  
- Load fact data with volume, value, and calculated price per kg  
- Perform data validation throughout.

4. **Reporting and Analytics:** 

- Measures created with DAX focusing on answering business questions on market growth, product profitability and pricing  
- Star schema enables fast slice and dice, drill-down, and time intelligence  
- Visual story built around the right market, right product, and right price questions.

5. **Deliverables:**

- SQL scripts for schema, ETL, and transformations  
- Power BI report addressing Sanford’s export strategy through key business questions on market opportunity, product focus, and pricing.

6. **Limitations and Assumptions:**

- Retrospective data only (FY23-25) 
- No intra-year granularity.

---

## Business Questions & Key Findings

### 1. Executive Summary

The analysis of NZ aquaculture exports from FY23-25 reveals a total export value of **$156.48 million** across 479 transactions to 57 countries. The market is highly concentrated with the USA accounting for 45.4% of total value, presenting both opportunity and risk.

### 2. Right Market - Where are the best growth and revenue opportunities?  
- Australia, China, and the United States showed the strongest markets for FY23-FY25.  
- Europe and North America lead in total export values but growth is unstable.

#### High-Growth Markets
1. **Canada**: +396% (driven by frozen mussels surge)
2. **Malaysia**: +148% (emerging market opportunity)
3. **Korea**: +118% (increasing demand)
4. **Thailand**: +91% (Southeast Asia expansion)

#### Declining Markets
1. **USA**: -36% (FY24-25, market maturation)
2. **Taiwan**: -73% (product mix shift)
3. **UAE**: -25% (increased competition)

#### Stable Markets
- Australia: Consistent performer
- Japan: Steady premium market
- Hong Kong: Gateway to Greater China

### 3. Right Product - Which species/products should Sanford prioritize?  
- Salmon and Mussels contribute over 70% of export revenue.  
- Value-added and processed products show higher profitability margins than raw products.

#### Product Performance

##### By Species

**Mussels**
- Largest contributor by volume and value
- Multiple product formats (frozen, live, processed)
- Wide geographic distribution

**Salmon**
- Premium pricing ($25-35/kg average)
- Strong in North America and Asia
- Value-added products command $50-200/kg

**Oysters**
- Niche market
- Live and frozen formats
- Premium positioning in select markets

##### By Processing Level

**Value-Added Products**
- Mussel Oil: $2,225/kg (ultra-premium)
- Processed Powder: $62-78/kg
- Smoked products: $50-65/kg
- Low volume, highest margins

**Semi-Processed**
- Fillets, meat products
- $40-60/kg range
- Balance of volume and margin

**Raw Products**
- Live, whole, shell products
- $6-26/kg range
- Volume driver


### 4. Right Price - How can Sanford optimize pricing strategies?  
- European and Asian markets exhibit premium pricing segments (NZD 40+/kg).  
- Growth potential exists in elevating prices on high-volume but lower-priced categories via branding and quality improvements.

#### Premium Pricing Opportunities
- **Mussel Oil**: Highest margin product ($2,000+/kg)
- **Processed formats**: 3-5x raw product pricing
- **Smoked products**: 2-3x fresh product pricing
- **Japan market**: Commands 15-20% price premium

#### Competitive Pricing
- **USA frozen mussels**: Highly competitive at $11-12/kg
- **China live products**: Volume-driven at $4-6/kg
- **European frozen**: Mid-range at $12-14/kg
---

## How to Use This Project

1. **Run SQL scripts** on SQL Server Express to load and transform data into the dimensional model.  
2. **Open the Power BI Desktop report template**, connect to the SQL Server instance, and analyse the prebuilt report pages.  
3. **Interact with slicers and drill-downs** to explore the export data by year, product, and market.  
4. **Leverage insights for strategic decision-making** on Sanford’s export growth, product focus, and pricing.