
CREATE 
--ALTER 
PROC util_index.pre_index_table (@database_name SYSNAME)
AS

IF @database_name IS NULL
	SET @database_name = DB_NAME()

--DECLARE @database_name SYSNAME = 'AdventureWorks2008R2'
DECLARE @sql_query NVARCHAR(4000) = '
SELECT sc.name [schema_name],
	   t.name table_name,
	   ix.name AS index_name,
	   CASE
		                   WHEN ix.is_unique = 1
			THEN ''UNIQUE '' ELSE ''''
	END AS is_unique,
	   ix.type_desc AS index_type,
	   CASE
		                            WHEN ix.is_padded = 1
			THEN ''PAD_INDEX = ON, '' ELSE ''PAD_INDEX = OFF, ''
	END + CASE
		                                   WHEN ix.allow_page_locks = 1
			THEN ''ALLOW_PAGE_LOCKS = ON, '' ELSE ''ALLOW_PAGE_LOCKS = OFF, ''
	END + CASE
		                                  WHEN ix.allow_row_locks = 1
			THEN ''ALLOW_ROW_LOCKS = ON, '' ELSE ''ALLOW_ROW_LOCKS = OFF, ''
	END + CASE
		                                         WHEN INDEXPROPERTY(t.object_id, ix.name, ''IsStatistics'') = 1
			THEN ''STATISTICS_NORECOMPUTE = ON, '' ELSE ''STATISTICS_NORECOMPUTE = OFF, ''
	END + CASE
		                                 WHEN ix.ignore_dup_key = 1
			THEN ''IGNORE_DUP_KEY = ON, '' ELSE ''IGNORE_DUP_KEY = OFF, ''
	END + ''SORT_IN_TEMPDB = OFF, FILLFACTOR ='' + CAST(ix.fill_factor AS VARCHAR(3)) AS IndexOptions,
	   ix.is_disabled,
	   FILEGROUP_NAME(ix.data_space_id) FileGroupName
FROM '+@database_name+ '.sys.tables t            
	INNER JOIN '+ @database_name+'.sys.indexes ix
			ON t.object_id = ix.object_id
	INNER JOIN  '+ @database_name+'.sys.schemas sc
			ON t.schema_id = sc.schema_id
WHERE ix.type > 0
	AND ix.is_primary_key = 0
	AND ix.is_unique_constraint = 0 
	AND t.is_ms_shipped = 0
	AND t.name <> ''sysdiagrams''
ORDER BY schema_name(t.schema_id) , t.name , ix.name'
--PRINT @sql_query
EXEC sp_executesql @sql_query
