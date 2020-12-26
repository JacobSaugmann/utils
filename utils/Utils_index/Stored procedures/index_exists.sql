CREATE PROC util_index.index_exists( @database_name VARCHAR(500), @schema_name  VARCHAR(500),  @index_name VARCHAR(500), @exists BIT = 0 OUT)
AS
BEGIN
--DECLARE @database_name VARCHAR(500), @schema_name  VARCHAR(500), @table_name VARCHAR(500), @index_statement  VARCHAR(500), @index_name VARCHAR(500)

SELECT  @schema_name = i.schema_name,
		@index_name = i.index_name,
		@database_name = i.database_name
FROM util_index.indexes i
WHERE id = 92

DECLARE @sql    NVARCHAR(MAX)
,   @objid  INT

SET @sql = N'
    USE '+@database_name+' 

    SELECT  @id = COUNT(*)
	FROM sys.indexes i
		INNER jOIN sys.tables t
			ON i.object_id = t.object_id
		INNER JOIN sys.schemas s
			ON t.schema_id = s.schema_id
WHERE s.name = '''+@schema_name+''' AND i.name = '''+@index_name+'''
'

EXEC sp_executesql @sql
    ,   N'@id INT OUTPUT'
    ,   @id = @objid OUTPUT



SELECT @exists = (CASE WHEN @objid > 0 THEN 1 ELSE 0 END )

END