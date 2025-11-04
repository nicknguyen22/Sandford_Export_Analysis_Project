-- ============================================
-- ETL Load Script - Data Transformation
-- Loads data from Staging to Dimension and Fact Tables
-- ============================================

USE SanfordDB;
GO

-- ============================================
-- STEP 1: Load Dimension Tables
-- ============================================

PRINT 'Starting ETL Process...';
GO

-- Load DimSpecies
PRINT 'Loading DimSpecies...';
INSERT INTO dbo.DimSpecies (SpeciesName, SpeciesCategory)
SELECT DISTINCT 
    Species,
    CASE 
        WHEN Species = 'Salmon' THEN 'Finfish'
        WHEN Species IN ('Mussels', 'Oysters') THEN 'Shellfish'
        ELSE 'Other'
    END AS SpeciesCategory
FROM dbo.StagingExports s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DimSpecies d 
    WHERE d.SpeciesName = s.Species
);
GO

-- Load DimProduct with categorization
PRINT 'Loading DimProduct...';
INSERT INTO dbo.DimProduct (ProductName, ProductType, ProcessingLevel)
SELECT DISTINCT 
    Product,
    CASE 
        WHEN Product LIKE '%Frozen%' THEN 'Frozen'
        WHEN Product LIKE '%Live%' THEN 'Live'
        WHEN Product LIKE '%Chilled%' OR Product LIKE '%Fresh%' THEN 'Chilled/Fresh'
        WHEN Product LIKE '%Smoked%' THEN 'Smoked'
        WHEN Product LIKE '%Processed%' OR Product LIKE '%Powder%' OR Product LIKE '%Oil%' THEN 'Processed'
        WHEN Product LIKE '%Dried%' OR Product LIKE '%Salted%' OR Product LIKE '%Brine%' THEN 'Preserved'
        ELSE 'Other'
    END AS ProductType,
    CASE 
        WHEN Product LIKE '%Powder%' OR Product LIKE '%Oil%' OR Product LIKE '%Processed%' 
             OR Product LIKE '%Smoked%' OR Product LIKE '%Cans%' OR Product LIKE '%Jars%' THEN 'Value-Added'
        WHEN Product LIKE '%Fillet%' OR Product LIKE '%Meat%' THEN 'Semi-Processed'
        WHEN Product LIKE '%Whole%' OR Product LIKE '%Live%' OR Product LIKE '%Shell%' THEN 'Raw'
        ELSE 'Other'
    END AS ProcessingLevel
FROM dbo.StagingExports s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DimProduct d 
    WHERE d.ProductName = s.Product
);
GO

-- Load DimCountry with regional categorization
PRINT 'Loading DimCountry...';
INSERT INTO dbo.DimCountry (CountryName, Region, SubRegion)
SELECT DISTINCT 
    Country,
    CASE 
        WHEN Country IN ('United States of America', 'Canada', 'Mexico') THEN 'North America'
        WHEN Country IN ('Australia', 'New Zealand') THEN 'Oceania'
        WHEN Country LIKE '%China%' OR Country LIKE '%Japan%' OR Country LIKE '%Korea%' 
             OR Country LIKE '%Taiwan%' OR Country LIKE '%Hong Kong%' 
             OR Country LIKE '%Singapore%' OR Country LIKE '%Malaysia%' 
             OR Country LIKE '%Thailand%' OR Country LIKE '%Viet Nam%' THEN 'Asia'
        WHEN Country IN ('United Kingdom', 'France', 'Germany', 'Netherlands', 'Belgium', 
                         'Denmark', 'Sweden', 'Spain', 'Portugal', 'Italy', 'Switzerland',
                         'Cyprus', 'Lithuania') THEN 'Europe'
        WHEN Country IN ('United Arab Emirates', 'Saudi Arabia', 'Israel', 'Kuwait', 
                         'Lebanon', 'Qatar', 'Jordan') THEN 'Middle East'
        WHEN Country LIKE '%Samoa%' OR Country LIKE '%Fiji%' OR Country LIKE '%Tonga%' 
             OR Country LIKE '%Cook Islands%' OR Country LIKE '%Vanuatu%' 
             OR Country LIKE '%French Polynesia%' OR Country LIKE '%Guam%' 
             OR Country LIKE '%New Caledonia%' OR Country LIKE '%Papua New Guinea%'
             OR Country LIKE '%Solomon Islands%' OR Country LIKE '%Niue%'
             OR Country LIKE '%Kiribati%' OR Country LIKE '%Marshall Islands%'
             OR Country LIKE '%Micronesia%' OR Country LIKE '%Wallis and Futuna%'
             OR Country LIKE '%Northern Mariana Islands%' THEN 'Pacific Islands'
        WHEN Country IN ('Dominican Republic', 'Guatemala', 'Jamaica') THEN 'Central America & Caribbean'
        WHEN Country IN ('Colombia') THEN 'South America'
        WHEN Country IN ('Mauritius', 'Reunion') THEN 'Africa'
        ELSE 'Other'
    END AS Region,
    CASE 
        WHEN Country LIKE '%China%' OR Country LIKE '%Hong Kong%' 
             OR Country LIKE '%Taiwan%' THEN 'Greater China'
        WHEN Country IN ('Japan', 'Korea, Republic of') THEN 'Northeast Asia'
        WHEN Country IN ('Singapore', 'Malaysia', 'Thailand', 'Viet Nam') THEN 'Southeast Asia'
        WHEN Country IN ('United Kingdom', 'France', 'Germany', 'Netherlands', 'Belgium') THEN 'Western Europe'
        WHEN Country IN ('Denmark', 'Sweden', 'Lithuania') THEN 'Northern Europe'
        WHEN Country IN ('Spain', 'Portugal', 'Italy', 'Cyprus') THEN 'Southern Europe'
        WHEN Country IN ('United States of America', 'Canada') THEN 'Northern America'
        ELSE NULL
    END AS SubRegion
FROM dbo.StagingExports s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DimCountry d 
    WHERE d.CountryName = s.Country
);
GO

-- Load DimFiscalYear
PRINT 'Loading DimFiscalYear...';
INSERT INTO dbo.DimFiscalYear (FiscalYear, YearNumber)
SELECT DISTINCT 
    FiscalYear,
    CAST(REPLACE(FiscalYear, 'FY', '20') AS INT) AS YearNumber
FROM dbo.StagingExports s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DimFiscalYear d 
    WHERE d.FiscalYear = s.FiscalYear
);
GO

-- ============================================
-- STEP 2: Load Fact Table
-- ============================================

PRINT 'Loading FactExports...';
INSERT INTO dbo.FactExports (SpeciesKey, ProductKey, CountryKey, FiscalYearKey, Volume, Value, PricePerKg)
SELECT 
    ds.SpeciesKey,
    dp.ProductKey,
    dc.CountryKey,
    df.FiscalYearKey,
    s.Volume,
    s.Value,
    CASE 
        WHEN s.Volume > 0 THEN CAST(s.Value AS DECIMAL(18,4)) / s.Volume
        ELSE NULL
    END AS PricePerKg
FROM dbo.StagingExports s
INNER JOIN dbo.DimSpecies ds ON s.Species = ds.SpeciesName
INNER JOIN dbo.DimProduct dp ON s.Product = dp.ProductName
INNER JOIN dbo.DimCountry dc ON s.Country = dc.CountryName
INNER JOIN dbo.DimFiscalYear df ON s.FiscalYear = df.FiscalYear;
GO

-- ============================================
-- STEP 3: Data Quality Checks
-- ============================================

PRINT 'Performing Data Quality Checks...';

-- Check row counts
DECLARE @StagingCount INT, @FactCount INT;
SELECT @StagingCount = COUNT(*) FROM dbo.StagingExports;
SELECT @FactCount = COUNT(*) FROM dbo.FactExports;

PRINT 'Staging Records: ' + CAST(@StagingCount AS VARCHAR(10));
PRINT 'Fact Records: ' + CAST(@FactCount AS VARCHAR(10));

-- Check for dimension records
DECLARE @SpeciesCount INT, @ProductCount INT, @CountryCount INT, @FiscalYearCount INT;

SELECT @SpeciesCount = COUNT(*) FROM dbo.DimSpecies;
SELECT @ProductCount = COUNT(*) FROM dbo.DimProduct;
SELECT @CountryCount = COUNT(*) FROM dbo.DimCountry;
SELECT @FiscalYearCount = COUNT(*) FROM dbo.DimFiscalYear;

PRINT 'Species Count: ' + CAST(@SpeciesCount AS VARCHAR(10));
PRINT 'Product Count: ' + CAST(@ProductCount AS VARCHAR(10));
PRINT 'Country Count: ' + CAST(@CountryCount AS VARCHAR(10));
PRINT 'Fiscal Year Count: ' + CAST(@FiscalYearCount AS VARCHAR(10));

-- Validate totals
DECLARE @StagingValue BIGINT, @FactValue BIGINT;
SELECT @StagingValue = SUM(Value) FROM dbo.StagingExports;
SELECT @FactValue = SUM(Value) FROM dbo.FactExports;

PRINT 'Staging Total Value: ' + CAST(@StagingValue AS VARCHAR(20));
PRINT 'Fact Total Value: ' + CAST(@FactValue AS VARCHAR(20));

IF @StagingValue = @FactValue
    PRINT 'Value Totals Match - ETL Successful';
ELSE
    PRINT 'WARNING: Value Totals Do Not Match!';

PRINT 'ETL Process Completed Successfully';
GO