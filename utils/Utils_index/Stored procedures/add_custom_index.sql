CREATE PROC util_index.add_custom_index (@database_name VARCHAR(500), @schema_name  VARCHAR(500), @table_name VARCHAR(500), @index_statement  VARCHAR(500), @index_name VARCHAR(500))
AS
--DECLARE @database_name VARCHAR(500), @schema_name  VARCHAR(500), @table_name VARCHAR(500), @index_statement  VARCHAR(500), @index_name VARCHAR(500)

SET @index_name = REPLACE(REPLACE(@index_name, '[',''), ']','')
SET @table_name = REPLACE(REPLACE(@table_name, '[',''), ']','')
SET @schema_name = REPLACE(REPLACE(@schema_name, '[',''), ']','')
SET @database_name = REPLACE(REPLACE(@database_name, '[',''), ']','')

IF(
SELECT COUNT(*)
FROM util_index.indexes i
WHERE i.database_name = @database_name
AND i.schema_name = @schema_name
AND i.table_name = @table_name
AND i.index_name = @index_name) > 0
BEGIN

	RAISERROR('Index exists aborting',0,1) WITH NOWAIT
	RETURN;

END

INSERT INTO util_index.indexes (database_name, [create], create_stmt, table_name, schema_name, is_custom, index_name, comment, drop_statement)
VALUES(@database_name, 1,@index_statement, @table_name, @schema_name, 1, @index_name, 'cumtom index added by sp', 'DROP INDEX '+QUOTENAME(@index_name)+' ON '+QUOTENAME(@schema_name)+'.' +QUOTENAME(@table_name))

