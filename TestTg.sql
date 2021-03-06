
/****** Object:  Table [dbo].[tbl_Std_Details]    Script Date: 09/25/2015 10:53:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_Std_Details](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Age] [int] NULL,
	[Email] [varchar](50) NULL,
	[Address] [varchar](50) NULL,
 CONSTRAINT [PK_tbl_Std_Details] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Member]    Script Date: 09/25/2015 10:53:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_Member](
	[memberId] [int] IDENTITY(1,1) NOT NULL,
	[firstName] [varchar](50) NULL,
	[lastName] [varchar](50) NULL,
	[contactNo] [varchar](15) NULL,
	[emailAddress] [varchar](70) NULL,
 CONSTRAINT [PK_tbl_Member] PRIMARY KEY CLUSTERED 
(
	[memberId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[usps_proSelectMember]    Script Date: 09/25/2015 10:54:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usps_proSelectMember]
AS
SELECT * FROM tbl_Member
GO
/****** Object:  StoredProcedure [dbo].[usps_proInsMember]    Script Date: 09/25/2015 10:54:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usps_proInsMember]
(
 @fName varchar(50),@lName varchar(50),@coNo varchar(15),@emailAddr varchar(70) 
)
AS
INSERT INTO tbl_Member (firstName,lastName,contactNo,emailAddress)
VALUES(@fName,@lName,@coNo,@emailAddr)
GO
/****** Object:  StoredProcedure [dbo].[spp_InsertStudent]    Script Date: 09/25/2015 10:54:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spp_InsertStudent]
(
@Name varchar(50),
@Age int,
@Email varchar(70),
@Address varchar(50),
@Action  char(10),
@Id  int
)
As
  Begin try
     if @Action  = 'Insert'
     begin
         insert tbl_Std_Details(Name,Age,Email,Address)
         Values(@Name,@Age,@Email,@Address);
         select '200' as code,'save successfully' as msg
     end
     else if @Action = 'Update' and @Id <> 0
         begin
             Update tbl_Std_Details
             set
             Name = @Name,
             Age = @Age,
             Email = @Email,
             Address = @Address
             Where 
             ID = @Id
              select '200' as code,'update successfully' as msg
         End
      else if @Action = 'Select'
           Begin
               Select * from tbl_Std_Details
           End
      else if @Action  = 'Delete' and @Id <> 0
            Begin
                Delete tbl_Std_Details where ID = @Id
                select '200' as code,'Delete successfully' as msg
            end
      else if @Action  = 'SelectId' and @Id <> 0
            Begin
               Select * from tbl_Std_Details where ID = @Id
            end
  End try
  Begin catch
         select '400' as code,error_message() as msg
  End catch
GO
/****** Object:  StoredProcedure [dbo].[Spp_GetSTDList]    Script Date: 09/25/2015 10:54:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[Spp_GetSTDList]

AS
  Begin
      Select * from tbl_Std_Details
  End
GO
/****** Object:  StoredProcedure [dbo].[GetEmpDataById]    Script Date: 09/25/2015 10:54:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[GetEmpDataById]
(
@Id int
)
As
  begin
      select * from dbo.tbl_Std_Details where ID =@Id
  end
GO
