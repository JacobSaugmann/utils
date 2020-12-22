
CREATE 
--ALTER 
PROC util_index.pre_index_include_columns (@database_name SYSNAME, @SchemaName NVARCHAR(500), @TableName NVARCHAR(500), @IndexName NVARCHAR(500))
AS

--DECLARE @SchemaName    SYSNAME = 'Production',
--        @TableName     SYSNAME = 'ProductReview',
--        @IndexName     SYSNAME ='IX_ProductReview_ProductID_Name',
--        @database_name SYSNAME = 'AdventureWorks2008R2'

DECLARE @sql_query NVARCHAR(4000) ='
SELECT col.name,
	   ixc.is_descending_key,
	   ixc.is_included_column,
	   ixc.index_column_id
FROM '+@database_name+'.sys.tables tb                  
	INNER JOIN  '+@database_name+'.sys.indexes ix       
			ON tb.object_id = ix.object_id
	INNER JOIN  '+@database_name+'.sys.index_columns ixc
			ON ix.object_id = ixc.object_id
				AND ix.index_id = ixc.index_id
	INNER JOIN  '+@database_name+'.sys.columns col      
			ON ixc.object_id = col.object_id
				AND ixc.column_id = col.column_id
	INNER JOIN  '+ @database_name+'.sys.schemas sc
			ON tb.schema_id = sc.schema_id
WHERE ix.type > 0
	AND (
		ix.is_primary_key = 0
		OR ix.is_unique_constraint = 0)
	AND sc.name = '''+ @SchemaName +
	''' AND tb.name = '''+ @TableName +
	''' AND ix.name = '''+ @IndexName +
''' ORDER BY ixc.index_column_id'
--PRINT @sql_query
EXEC sp_executesql @sql_query

