

declare @PageNo int = 1
declare @PageSize int = 5

Select ID,Name,Age,Address
from tbl_Std_Details
Order By ID
OFFSET (@PageNo - 1)*@PageSize ROWS
FETCH NEXT @PageSize ROWS Only


select * from (
select ID,Name,Age,ROW_NUMBER() over(Order by ID) As Row from tbl_Std_Details
) tbl
where tbl.Row>=1 and tbl.Row<=5