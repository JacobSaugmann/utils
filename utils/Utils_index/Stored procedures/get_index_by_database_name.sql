

CREATE 
--ALTER
PROC [util_index].[get_index_by_database_name](@database_name NVARCHAR(500), @append BIT = 1)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--BACKUP ALL indexes
--DECLARE @database_name SYSNAME = 'AdventureWorks2008R2'
DECLARE @msg NVARCHAR(2000)


SET @msg = 'Getting index information from: '+@database_name
RAISERROR(@msg, 0,1) WITH NOWAIT

IF(@append = 0)
BEGIN
	DROP TABLE IF EXISTS util_index.tmp_backup_index
	CREATE TABLE util_index.tmp_backup_index (
		stmt NVARCHAR(MAX),
		database_name NVARCHAR(500),
		schema_name NVARCHAR(500),
		index_name NVARCHAR(500),
		table_name NVARCHAR(500)
	)
END
IF(@append = 1 AND OBJECT_ID('util_index.tmp_backup_index', 'U') IS NULL)
BEGIN

	CREATE TABLE util_index.tmp_backup_index (
		stmt NVARCHAR(MAX),
		database_name NVARCHAR(500),
		schema_name NVARCHAR(500),
		index_name NVARCHAR(500),
		table_name NVARCHAR(500)
	)

END


DECLARE @SchemaName NVARCHAR(100)
DECLARE @TableName NVARCHAR(256)
DECLARE @IndexName NVARCHAR(256)
DECLARE @ColumnName VARCHAR(100)
DECLARE @is_unique VARCHAR(100)
DECLARE @IndexTypeDesc VARCHAR(100)
DECLARE @FileGroupName VARCHAR(100)
DECLARE @is_disabled VARCHAR(100)
DECLARE @IndexOptions VARCHAR(MAX)
DECLARE @IndexColumnId INT
DECLARE @IsDescendingKey INT
DECLARE @IsIncludedColumn INT
DECLARE @TSQLScripCreationIndex VARCHAR(MAX)
DECLARE @TSQLScripDisableIndex VARCHAR(MAX)

DROP TABLE IF EXISTS #pre_index

CREATE TABLE #pre_index (
	schema_name NVARCHAR(500) NULL,
	table_name NVARCHAR(500) NULL,
	index_name NVARCHAR(500) NULL,
	is_unique NVARCHAR(30) NULL,
	index_type NVARCHAR(25) NULL,
	indexoptions NVARCHAR(1000) NULL,
	is_disabled NVARCHAR(30) NULL,
	filegroupname NVARCHAR(500) NULL
)


INSERT INTO #pre_index
EXEC util_index.pre_index_table @database_name = 'AdventureWorks2008R2'

DECLARE CursorIndex CURSOR
FOR
SELECT *
FROM #pre_index


OPEN CursorIndex

FETCH NEXT
FROM CursorIndex
INTO @SchemaName
,@TableName
,@IndexName
,@is_unique
,@IndexTypeDesc
,@IndexOptions
,@is_disabled
,@FileGroupName

WHILE (@@FETCH_STATUS = 0)
BEGIN
	DECLARE @IndexColumns VARCHAR(MAX)
	DECLARE @IncludedColumns VARCHAR(MAX)

	SET @msg = 'DEBUG INFO: Variables: Schema: ' + @SchemaName +' | Table: ' + @TableName + ' | Index_name: ' + @IndexName
	RAISERROR(@msg,0,1) WITH NOWAIT

	SET @IndexColumns = ''
	SET @IncludedColumns = ''

	DROP TABLE IF EXISTS #index_include

	CREATE TABLE #index_include (
		column_name VARCHAR(500) NULL,
		is_descending_key VARCHAR(30) NULL,
		is_included_column VARCHAR(30) NULL,
		index_column_id VARCHAR(10) NULL
	)



	INSERT INTO #index_include ( column_name, is_descending_key, is_included_column, index_column_id )
	EXEC util_index.pre_index_include_columns @database_name = @database_name, @SchemaName = @SchemaName, @TableName = @TableName, @IndexName = @IndexName


	DECLARE CursorIndexColumn CURSOR
	FOR
	SELECT column_name,
    	   is_descending_key,
    	   is_included_column
    FROM #index_include
    ORDER BY index_column_id

	OPEN CursorIndexColumn

	FETCH NEXT
	FROM CursorIndexColumn
	INTO @ColumnName
	,@IsDescendingKey
	,@IsIncludedColumn

	WHILE (@@FETCH_STATUS = 0)
	BEGIN

		--SET @msg = 'DEBUG INFO: Variables: '+ @IndexColumns + ' | ' + @ColumnName
		--RAISERROR(@msg, 0,1) WITH NOWAIT

		IF @IsIncludedColumn = 0
			SET @IndexColumns = @IndexColumns + @ColumnName + CASE
				                   WHEN @IsDescendingKey = 1
					THEN ' DESC, ' ELSE ' ASC, '
			END
		ELSE
			SET @IncludedColumns = @IncludedColumns + @ColumnName + ', '

		FETCH NEXT
		FROM CursorIndexColumn
		INTO @ColumnName
		,@IsDescendingKey
		,@IsIncludedColumn
	END

	CLOSE CursorIndexColumn
	DEALLOCATE CursorIndexColumn


	SET @IndexColumns = substring(@IndexColumns, 1, len(@IndexColumns) - 1)
	SET @IncludedColumns = CASE
		                                                                   WHEN len(@IncludedColumns) > 0
			THEN substring(@IncludedColumns, 1, len(@IncludedColumns) - 1) ELSE ''
	END
	--  print @IndexColumns
	--  print @IncludedColumns
	SET @TSQLScripCreationIndex = ''
	SET @TSQLScripDisableIndex = ''
	SET @TSQLScripCreationIndex = 'CREATE ' + @is_unique + @IndexTypeDesc + ' INDEX ' + QUOTENAME(@IndexName) + ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + '(' + @IndexColumns + ') ' + CASE
		                                                         WHEN len(@IncludedColumns) > 0
			THEN CHAR(13) + 'INCLUDE (' + @IncludedColumns + ')' ELSE ''
	END + CHAR(13) + 'WITH (' + @IndexOptions + ') ON ' + QUOTENAME(@FileGroupName) + ';'

	IF @is_disabled = 1
		SET @TSQLScripDisableIndex = CHAR(13) + 'ALTER INDEX ' + QUOTENAME(@IndexName) + ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' DISABLE;' + CHAR(13)

	INSERT INTO util_index.tmp_backup_index ( stmt, database_name, schema_name, index_name, table_name )
	VALUES (
		@TSQLScripCreationIndex,
		@database_name,
		@SchemaName,
		@IndexName,
		@TableName
	)

	IF @TSQLScripDisableIndex <> ''
		INSERT INTO util_index.tmp_backup_index ( stmt, database_name, schema_name, index_name, table_name )
		VALUES (
			@TSQLScripDisableIndex,
			@database_name,
			@SchemaName,
			@IndexName,
			@TableName
		)

	FETCH NEXT
	FROM CursorIndex
	INTO @SchemaName
	,@TableName
	,@IndexName
	,@is_unique
	,@IndexTypeDesc
	,@IndexOptions
	,@is_disabled
	,@FileGroupName
END

CLOSE CursorIndex
DEALLOCATE CursorIndex


--SELECT *
--FROM #backup_index

DROP TABLE IF EXISTS #index_include
DROP TABLE IF EXISTS #backup_index



GO
