
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Employee]') AND type in (N'U'))
BEGIN
    
	CREATE TABLE dbo.Employee (
		EmployeeId		INT	IDENTITY (1, 1) NOT NULL, 	
		EmployeeNumber  NVARCHAR(15) NOT NULL,
		FirstName		NVARCHAR(100) NOT NULL,	
		LastName		NVARCHAR(100) NOT NULL,	  
		Salary			DECIMAL(8,2) NOT NULL CONSTRAINT DF_Employee_Salary DEFAULT 52000,
		[CreateUserId] INT NOT NULL CONSTRAINT [FK_Emplpoyee_User] REFERENCES [dbo].[User([UserId]),
		[CreateDateUtc] DATETIME NOT NULL CONSTRAINT [DF_Employee_CreateDateUtc] DEFAULT GETUTCDATE(),
		CONSTRAINT PK_Employee PRIMARY KEY CLUSTERED(EmployeeId ASC)
	);
	
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The unique identifier of user who has created this completion record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Employee', @level2type=N'COLUMN',@level2name=N'CreateUserId'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date of creation of this employee record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Employee', @level2type=N'COLUMN',@level2name=N'CreateDateUtc'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Employee]') AND name = N'IX_Employee_EmployeeNumber')
BEGIN
	CREATE UNIQUE NONCLUSTERED INDEX IX_Employee_EmployeeNumber ON dbo.Employee(EmployeeNumber ASC);
END;

GRANT SELECT ON [dbo].[Employee] TO AppRole
GRANT INSERT ON [dbo].[Employee] TO AppApp
GO
