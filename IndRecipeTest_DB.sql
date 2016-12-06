USE master
GO

-- Drop the database if it already exists
IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'IndRecipeTest'
)
DROP DATABASE IndRecipeTest
GO

CREATE DATABASE IndRecipeTest
GO

--------------------------------------------------------------------------
-- CREATE Material Category Table
--------------------------------------------------------------------------

USE IndRecipeTest
GO

IF OBJECT_ID('dbo.MaterialType', 'U') IS NOT NULL
  DROP TABLE dbo.MaterialType
GO

CREATE TABLE dbo.MaterialType
(
	ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
	Name VARCHAR(50) UNIQUE NOT NULL
	  
)
GO

USE IndRecipeTest
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------------
-- CREATE Stored Procedures
--------------------------------------------------------------------------

CREATE PROCEDURE usp_MaterialTypeInsert 
	-- Parameters for the stored procedure here
	@Name VARCHAR(50)
AS
BEGIN
	
	SET NOCOUNT ON;
  SET XACT_ABORT ON
  
  BEGIN TRAN
  
    INSERT INTO MaterialType
      SELECT @Name
      
    SELECT SCOPE_IDENTITY()
  
  COMMIT
    
	RETURN
	
END
GO
--*****************************************************************************************
--*****************************************************************************************
-- Dummy Data
EXEC dbo.usp_materialTypeInsert 'Raw Material'
GO
EXEC dbo.usp_materialTypeInsert 'Formula'
GO
EXEC dbo.usp_materialTypeInsert 'Consumable'
GO

--*****************************************************************************************

CREATE PROCEDURE usp_MaterialTypeSelect
AS
BEGIN

  SET NOCOUNT ON;
  
  SELECT Name
    FROM MaterialType
    ORDER BY Name
  
  RETURN

END
GO

--------------------------------------------------------------------------
-- CREATE TABLE Material Category
--------------------------------------------------------------------------
IF OBJECT_ID('dbo.MaterialCategory', 'U') IS NOT NULL
  DROP TABLE dbo.MaterialCategory
GO

CREATE TABLE MaterialCategory(
 ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
 MatType_ID INT NOT NULL FOREIGN KEY REFERENCES MaterialType(ID),
 Name VARCHAR(50) NOT NULL
)
GO

--------------------------------------------------------------------------
-- CREATE Stored Procedures
--------------------------------------------------------------------------

CREATE PROCEDURE usp_MaterialCategorySelect
  @MatType VARCHAR(50)
AS
BEGIN

  SET NOCOUNT ON;
  
  SELECT mc.ID, mc.Name
    FROM MaterialCategory mc
     JOIN MaterialType mt
      ON mc.MatType_ID = mt.ID
    WHERE mt.Name = @MatType
    ORDER BY mc.Name
  
  RETURN

END
GO

CREATE PROCEDURE usp_MaterialCategoryInsert(
 @MatType NVARCHAR(50),
 @Name NVARCHAR(50)
)
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON
  
  BEGIN TRAN
  
  IF NOT EXISTS(SELECT mc.ID
                  FROM MaterialCategory mc
                    JOIN MaterialType mt
                      ON mc.MatType_ID = mt.ID
                    WHERE mt.Name = @MatType
                      AND mc.Name = @Name)
                      
    INSERT INTO MaterialCategory
      SELECT mt.ID, @Name
        FROM MaterialType mt
          WHERE mt.Name = @MatType
          
    SELECT SCOPE_IDENTITY()
    
  COMMIT
  
  RETURN

END
GO

-- Dummy Data
EXEC dbo.usp_MaterialCategoryInsert 'Raw Material', 'Dry Chemical'
Go
EXEC dbo.usp_MaterialCategoryInsert 'Raw Material', 'Wet Chemical'
GO
EXEC dbo.usp_MaterialCategoryInsert 'Raw Material', 'Catalyst'
GO
EXEC dbo.usp_MaterialCategoryInsert 'Raw Material', 'Pigment'
GO
EXEC dbo.usp_MaterialCategoryInsert 'Consumable', 'Drum'
GO
EXEC dbo.usp_MaterialCategoryInsert 'Consumable', 'Bucket'
GO
EXEC dbo.usp_MaterialCategoryInsert 'Formula', 'Industrial'
GO
EXEC dbo.usp_MaterialCategoryInsert 'Formula', 'Commercial'
GO

-------------------------------------------------------------------------
-- CREATE TABLE Material
--------------------------------------------------------------------------

IF OBJECT_ID('dbo.Material', 'U') IS NOT NULL
  DROP TABLE dbo.Material
GO

CREATE TABLE Material(
 ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
 MatCat_ID INT NOT NULL FOREIGN KEY REFERENCES MaterialCategory(ID),
 Name VARCHAR(50) NOT NULL,
 Price Money NOT NULL Default(2.5)
)
GO

--------------------------------------------------------------------------
-- CREATE Stored Procedures
--------------------------------------------------------------------------

CREATE PROCEDURE usp_MaterialInsert(
  @MatCat VarChar(50),
  @Name VarChar(50),
  @Price Money = NULL
)
AS
BEGIN
  SET NOCOUNT ON
  SET XACT_ABORT ON
  
  BEGIN TRAN
  
    IF NOT EXISTS(SELECT m.ID
                   FROM Material m
                     JOIN MaterialCategory mc
                       ON m.MatCat_ID = mc.ID
                     WHERE m.Name = @Name
                      AND mc.Name = @MatCat)
                      
      INSERT INTO Material
        SELECT mc.ID, @Name, @Price
          FROM MaterialCategory mc
          WHERE mc.Name = @MatCat
          
    SELECT SCOPE_IDENTITY()
  
  COMMIT
  
  RETURN
  
END
  

GO

EXEC dbo.usp_materialInsert 'Dry Chemical', 'XYZ Powder', 1.76
GO
EXEC dbo.usp_materialInsert 'Dry Chemical', 'ABC Resin', 0.35
GO
EXEC dbo.usp_materialInsert 'Dry Chemical', 'Silicone Powder', 8.20
GO
EXEC dbo.usp_materialInsert 'Wet Chemical', 'CaneToad Oil', 14.50
GO
EXEC dbo.usp_materialInsert 'Pigment', 'Ti02', 5.50
GO
EXEC dbo.usp_materialInsert 'Pigment', 'Ultramarine Blue', 12.45
GO
EXEC dbo.usp_materialInsert 'Drum', '44 Gal - Steel', 55.00
GO
EXEC dbo.usp_materialInsert 'Drum', '44 Gal Plastic', 26.00
GO
EXEC dbo.usp_materialInsert 'Bucket', '20 Ltr Plastic', 5.00
GO
EXEC dbo.usp_materialInsert 'Bucket', '10 Ltr Plastic', 2.75
GO

CREATE PROCEDURE usp_MaterialSelect(
  @MatCat  VarChar(50)
)
AS
BEGIN
  SET NOCOUNT ON;
  
  SELECT m.ID, mc.Name As Category, m.Name As Material, Price
    FROM Material m
     Join MaterialCategory mc
       ON m.MatCat_ID = mc.ID
    WHERE mc.Name = @MatCat
    ORDER BY m.Name
   
   RETURN
   
END
GO

--------------------------------------------------------------------------
-- CREATE TABLE FormulaBOM
--------------------------------------------------------------------------

IF OBJECT_ID('dbo.FormulaBOM', 'U') IS NOT NULL
  DROP TABLE dbo.FormulaBOM
GO

CREATE TABLE FormulaBOM(
  ID Int Identity(1,1) Not Null Primary Key,
  Formula_ID Int Not Null Foreign Key References Material(ID),
  Material_ID Int Not Null Foreign Key References Material(ID),
  PPH Decimal(18,7) NOT NULL Check(PPH > 0)
)
GO

USE IndRecipeTest
GO

--------------------------------------------------------------------------
-- CREATE User Defined Type
--------------------------------------------------------------------------
IF OBJECT_ID('dbo.TVP_BOM', 'U') IS NOT NULL
  DROP TYPE dbo.TVO_BOM
GO

CREATE TYPE TVP_BOM AS TABLE(
  Mat_ID Int,
  PPH Decimal(18,7)
)
GO

--------------------------------------------------------------------------
-- CREATE Stored Procedures
--------------------------------------------------------------------------

CREATE PROCEDURE usp_FormulaBOMInsert(
  @Form_ID Int,
  @BOM AS TVP_BOM READONLY    -- MUST BE READONLY AND NOT OUTPUT
)
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON
  
  BEGIN TRAN
  
    IF EXISTS(SELECT TOP 1 (m.ID)
                FROM FormulaBOM bom
                  JOIN Material m
                    ON bom.Formula_ID = m.ID  
                WHERE  m.ID = @Form_ID)
               
      DELETE FormulaBOM
        WHERE Formula_ID = @Form_ID
      
    INSERT INTO FormulaBOM
      SELECT @Form_ID, Mat_ID, PPH
        FROM @BOM

    SELECT bom.ID, f.Name As Formula, m.Name As Material, PPH 
    FROM FormulaBOM bom
      JOIN Material f
        ON bom.Formula_ID = f.ID
      JOIN Material m
        ON bom.Material_ID = m.ID
    WHERE bom.Formula_ID = @Form_ID
    
  COMMIT

  RETURN
  
END
GO

CREATE PROCEDURE usp_FormulaBOMSelect(
  @Form VarChar(50)
)
AS
BEGIN
  SET NOCOUNT ON;
  
  SELECT m.ID, m.Name As [Material], PPH
  FROM FormulaBOM bom
  JOIN Material f
    ON bom.Formula_ID = f.ID
  JOIN Material m
    ON bom.Material_ID = m.ID
  WHERE f.Name = @Form
   ORDER BY PPH DESC

  RETURN
  
END
GO

--------------------------------------------------------------
-- END OF SCRIPT - CreateDatabase - IndRecipeTest
--
-- Andy Johnston 4/10/2009
-------------------------------------------------------------
