-- ============================================
-- Bulk Insert Script - Load CSV Files to Staging
-- Run this after creating the database schema
-- ============================================

USE SanfordDB;
GO

/*
Step 1: Initialize - Clear staging table to prevent duplicate data
*/
TRUNCATE TABLE dbo.StagingExports;
GO

/*
Step 2: Load FY2023 Export Data
- Creates temporary table for data validation
- Performs bulk insert with UTF-8 encoding
- Transfers data to staging table with fiscal year tag
*/
CREATE TABLE #TempExports (
    Species NVARCHAR(100),
    Product NVARCHAR(200),
    Country NVARCHAR(200),
    Volume INT,
    Value INT
);
GO

BULK INSERT #TempExports
FROM 'C:/Sanford_Export_Analysis_Project/data/exports-by-product-jul-23.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

INSERT INTO dbo.StagingExports (Species, Product, Country, Volume, Value, FiscalYear)
SELECT Species, Product, Country, Volume, Value, 'FY23' AS FiscalYear
FROM #TempExports;
GO

DROP TABLE #TempExports;
GO

/*
Step 3: Load FY2024 Export Data
- Recreates temporary table for fresh data load
- Performs bulk insert with same configuration
- Transfers data with FY24 identifier
*/
CREATE TABLE #TempExports (
    Species NVARCHAR(100),
    Product NVARCHAR(200),
    Country NVARCHAR(200),
    Volume INT,
    Value INT
);
GO

BULK INSERT #TempExports
FROM 'C:/Sanford_Export_Analysis_Project/data/exports-by-product-jul-24.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

INSERT INTO dbo.StagingExports (Species, Product, Country, Volume, Value, FiscalYear)
SELECT Species, Product, Country, Volume, Value, 'FY24' AS FiscalYear
FROM #TempExports;
GO

DROP TABLE #TempExports;
GO

/*
Step 4: Load FY2025 Export Data
- Recreates temporary table for final data load
- Performs bulk insert with consistent configuration
- Transfers data with FY25 identifier
*/
CREATE TABLE #TempExports (
    Species NVARCHAR(100),
    Product NVARCHAR(200),
    Country NVARCHAR(200),
    Volume INT,
    Value INT
);
GO

BULK INSERT #TempExports
FROM 'C:/Sanford_Export_Analysis_Project/data/exports-by-product-jul-25.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

INSERT INTO dbo.StagingExports (Species, Product, Country, Volume, Value, FiscalYear)
SELECT Species, Product, Country, Volume, Value, 'FY25' AS FiscalYear
FROM #TempExports;
GO

DROP TABLE #TempExports;
GO

PRINT 'Data Loading Completed';
GO