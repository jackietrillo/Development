SELECT p.Name, c.TEXT 
FROM sys.procedures p
INNER JOIN syscomments c ON c.ID = p.object_ID
WHERE c.TEXT like '%%' 
AND p.NAME not like 'xyz'
order by name

