SELECT p.Name, c.TEXT 
FROM sys.procedures p
INNER JOIN syscomments c ON c.ID = p.object_ID
WHERE c.TEXT like '%ExpirationDate%' 
AND p.NAME not like 'xyz'
order by name



SELECT c.name AS ColName, t.name AS TableName
FROM sys.columns c
    JOIN sys.tables t ON c.object_id = t.object_id
WHERE c.name LIKE '%ItemIdAsNumeric%'