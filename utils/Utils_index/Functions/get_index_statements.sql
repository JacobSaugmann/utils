

CREATE FUNCTION util_index.get_index_statements (@id INT)
RETURNS TABLE
AS
--DECLARE @id INT = 97
RETURN(
SELECT create_stmt,
	   'USE '+ QUOTENAME(database_name) + '; ' + drop_statement AS drop_statement,
	   'USE '+ QUOTENAME(database_name) + '; ' + ' ALTER INDEX '+QUOTENAME(index_name) +' ON '+QUOTENAME(schema_name)+'.' +QUOTENAME(table_name) + ' DISABLE;' AS disblae_stmt
FROM util_index.indexes i
WHERE i.id = @id
)

 