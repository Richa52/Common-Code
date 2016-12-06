SELECT * FROM [dbo].[EmployeeDetails]

--Step 1 
--CREATE FULLTEXT CATALOG catalogname WITH ACCENT_SENSITIVITY = ON

--CREATE FULLTEXT INDEX ON [dbo].[EmployeeDetails]
--(FullName,JobTitle)  
--KEY INDEX PK_EmployeeDetails
--ON catalogname  
--WITH STOPLIST = SYSTEM

--DROP  FULLTEXT CATALOG catalogname
--DROP FULLTEXT INDEX ON [dbo].[EmployeeDetails]

DECLARE @FullName VARCHAR(50) = 'Ga*', @JobTitle VARCHAR(50) = 'Buyer'
DECLARE @search  VARCHAR(50) =  '"' + @FullName + '" or "' + @JobTitle + '"'
SELECT * FROM [dbo].[EmployeeDetails] t1
WHERE CONTAINS(*,@search);  