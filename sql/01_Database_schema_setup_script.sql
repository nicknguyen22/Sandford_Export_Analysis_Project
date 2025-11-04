-- ============================================
-- Sanford Aquaculture Export Database Schema
-- Database Schema Setup Script
-- ============================================

USE master;
GO


-- Create database if not exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SanfordDB')
BEGIN
    CREATE DATABASE SanfordDB;
END
GO

USE SanfordDB;
GO

-- ============================================
-- Drop existing tables if they exist
-- ============================================
IF OBJECT_ID('dbo.FactExports', 'U') IS NOT NULL DROP TABLE dbo.FactExports;
IF OBJECT_ID('dbo.DimCountry', 'U') IS NOT NULL DROP TABLE dbo.DimCountry;
IF OBJECT_ID('dbo.DimProduct', 'U') IS NOT NULL DROP TABLE dbo.DimProduct;
IF OBJECT_ID('dbo.DimSpecies', 'U') IS NOT NULL DROP TABLE dbo.DimSpecies;
IF OBJECT_ID('dbo.DimFiscalYear', 'U') IS NOT NULL DROP TABLE dbo.DimFiscalYear;
IF OBJECT_ID('dbo.StagingExports', 'U') IS NOT NULL DROP TABLE dbo.StagingExports;
GO

-- ============================================
-- Create Staging Table
-- ============================================
CREATE TABLE dbo.StagingExports (
    Species NVARCHAR(100) NOT NULL,
    Product NVARCHAR(200) NOT NULL,
    Country NVARCHAR(200) NOT NULL,
    Volume INT NOT NULL,
    Value INT NOT NULL,
    FiscalYear NVARCHAR(10) NOT NULL,
);
GO

-- ============================================
-- Create Dimension Tables
-- ============================================

-- Dimension: Species
CREATE TABLE dbo.DimSpecies (
    SpeciesKey INT IDENTITY(1,1) PRIMARY KEY,
    SpeciesName NVARCHAR(100) NOT NULL UNIQUE,
    SpeciesCategory NVARCHAR(50), -- Can be extended for categorization
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);
GO

-- Dimension: Product
CREATE TABLE dbo.DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(200) NOT NULL UNIQUE,
    ProductType NVARCHAR(100), -- e.g., Frozen, Live, Processed, Smoked
    ProcessingLevel NVARCHAR(50), -- e.g., Raw, Processed, Value-Added
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);
GO

-- Dimension: Country
CREATE TABLE dbo.DimCountry (
    CountryKey INT IDENTITY(1,1) PRIMARY KEY,
    CountryName NVARCHAR(200) NOT NULL UNIQUE,
    Region NVARCHAR(100), -- e.g., Asia-Pacific, North America, Europe
    SubRegion NVARCHAR(100),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);
GO

-- Dimension: Fiscal Year
CREATE TABLE dbo.DimFiscalYear (
    FiscalYearKey INT IDENTITY(1,1) PRIMARY KEY,
    FiscalYear NVARCHAR(10) NOT NULL UNIQUE,
    YearNumber INT, -- e.g., 23, 24, 25
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);
GO

-- ============================================
-- Create Fact Table
-- ============================================
CREATE TABLE dbo.FactExports (
    ExportKey INT IDENTITY(1,1) PRIMARY KEY,
    SpeciesKey INT NOT NULL,
    ProductKey INT NOT NULL,
    CountryKey INT NOT NULL,
    FiscalYearKey INT NOT NULL,
    Volume INT NOT NULL,
    Value INT NOT NULL,
    PricePerKg DECIMAL(18,4),
    CreatedDate DATETIME DEFAULT GETDATE(),

    -- Foreign Keys
    CONSTRAINT FK_FactExports_Species FOREIGN KEY (SpeciesKey) 
        REFERENCES dbo.DimSpecies(SpeciesKey),
    CONSTRAINT FK_FactExports_Product FOREIGN KEY (ProductKey) 
        REFERENCES dbo.DimProduct(ProductKey),
    CONSTRAINT FK_FactExports_Country FOREIGN KEY (CountryKey) 
        REFERENCES dbo.DimCountry(CountryKey),
    CONSTRAINT FK_FactExports_FiscalYear FOREIGN KEY (FiscalYearKey) 
        REFERENCES dbo.DimFiscalYear(FiscalYearKey)
);
GO

-- ============================================
-- Create Indexes for Performance
-- ============================================
CREATE INDEX IX_FactExports_SpeciesKey ON dbo.FactExports(SpeciesKey);
CREATE INDEX IX_FactExports_ProductKey ON dbo.FactExports(ProductKey);
CREATE INDEX IX_FactExports_CountryKey ON dbo.FactExports(CountryKey);
CREATE INDEX IX_FactExports_FiscalYearKey ON dbo.FactExports(FiscalYearKey);
CREATE INDEX IX_FactExports_Value ON dbo.FactExports(Value);
GO

PRINT 'Database schema created successfully';
GO
