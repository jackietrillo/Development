SELECT t.name AS table_name, SCHEMA_NAME(t.schema_id) AS schema_name, 
c.name AS column_name, y.name as DataType, c.precision, c.scale
FROM sys.tables AS t
INNER JOIN sys.columns c ON t.OBJECT_ID = c.OBJECT_ID
INNER JOIN sys.types y ON y.user_type_id = c.user_type_id
WHERE c.name LIKE '%Percent%'
ORDER BY schema_name, table_name;


SELECT Table_Schema, Table_Name, Column_Name, Data_Type
FROM information_schema.columns
WHERE table_name in ( select name from LDCTrunk..sysobjects
where xtype = 'U' )
and column_name like '%Percent%'
order by table_schema, table_name

