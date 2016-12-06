declare @todt datetime= GETDATE()
declare @frmdt datetime = DATEADD(YEAR,10,@todt)

--select @todt [to], @frmdt as [from]


--select datepart (dw, @todt) as dayOfTheWeek,
--       datename (dw, @todt) as NameOfDay
SET NOCOUNT ON
 DECLARE @temtbl TABLE
 (
 Id INT IDENTITY(1,1),
 [Date] DATETIME,
 dayid INT,
 [dayname] VARCHAR(10)
 )


 DECLARE @tempdate DATETIME = @todt
 DECLARE @n INT = 0, @Id int
 

 WHILE(@tempdate<=@frmdt)
   BEGIN
   if datepart(dw,@tempdate) = 2
       begin
       INSERT @temtbl(Date,dayid,dayname)
	   VALUES(@tempdate,datepart (dw, @tempdate),datename(dw,@tempdate))
	   end

	   SET @tempdate = @tempdate + 1
   END

   SELECT * FROM @temtbl 
   
   set @Id = SCOPE_IDENTITY();
   select @Id as Id