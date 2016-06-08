
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Employee]') AND name = N'IX_Employee_EmployeeNumber')
BEGIN
	CREATE UNIQUE NONCLUSTERED INDEX IX_Employee_EmployeeNumber ON dbo.Employee(EmployeeNumber ASC);
END;