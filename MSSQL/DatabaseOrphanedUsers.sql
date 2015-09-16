/*
Automatically resync users from a database that was restored from a backup from a different server

*/

CREATE PROCEDURE sp_Fix_Orphaned_Users
AS
BEGIN
declare @username varchar(128)
declare @Musername varchar(128)
declare @IsNtName bit
declare @sql_stmt varchar(500)

--cursor returns with names of each username to be tied to its respective
DECLARE user_cursor CURSOR FOR
SELECT su.name as Name, msu.name as MasterName , su.isntname 
FROM sysusers su
left join master.dbo.sysxlogins msu
on upper(su.name) = upper(msu.name)
WHERE su.sid > 0x00
ORDER BY Name

--for each user:
OPEN user_cursor
FETCH NEXT FROM user_cursor INTO @username, @Musername, @IsNtName
WHILE @@FETCH_STATUS = 0
BEGIN
IF @username NOT IN ('dbo', 'list of names you want to avoid') -- 
BEGIN
if @Musername is null 
begin
if @IsNtName = 1 
begin
print 'if not exists (select * from master.dbo.syslogins where loginname = N''NtDomain**\' + @username + ''')'
print ' begin '
print ' exec sp_grantlogin N''NtDomain**\' + @username + ''''
print ' exec sp_defaultdb N''NtDomain**\' + + @username + ''', N'''+ db_name() + ''''
print ' end'
set @sql_stmt = '--Windows account used'

end
else
begin
SELECT @sql_stmt = 'sp_change_users_login @Action = ''Auto_Fix'',@UserNamePattern = ''' + @username + ''''
end
end
else
begin
SELECT @sql_stmt = 'sp_change_users_login @Action = ''Update_One'',@UserNamePattern = ''' + @username + ''', @LoginName = ''' + @username + ''''
end

PRINT @sql_stmt
print 'go'
print '--*** Look here: exec stmt in comment !!! ***'
EXECUTE (@sql_stmt)
print Convert(Varchar,  @@ROWCOUNT) + 'Users affected'
END
FETCH NEXT FROM user_cursor INTO @username, @Musername, @IsNtName
END --of table-cursor loop

--clean up
CLOSE user_cursor
DEALLOCATE user_cursor

Print '** end User-sync **'

END
GO
