USE MASTER

SET NOCOUNT ON

DECLARE @Command NVARCHAR(4000)
DECLARE @DatabaseName VARCHAR(250)

DECLARE DatabaseCursor CURSOR FOR
SELECT [name] FROM master.sys.databases
WHERE [name] LIKE '%'

OPEN DatabaseCursor
FETCH NEXT FROM DatabaseCursor INTO @DatabaseName

WHILE @@FETCH_STATUS <> -1
BEGIN										
	
	SET @Command = 'USE ' + @DatabaseName +  ' SELECT * FROM TABLE'
			
	EXEC sp_executesql @Command
	
	FETCH NEXT FROM DatabaseCursor INTO @DatabaseName	
END

CLOSE DatabaseCursor
DEALLOCATE DatabaseCursor

SET NOCOUNT OFF

