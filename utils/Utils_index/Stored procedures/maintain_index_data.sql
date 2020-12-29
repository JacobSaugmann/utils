CREATE PROC util_index.maintain_index_data
AS

	--TRUNCATE TABLE util_index.indexes

	IF OBJECT_ID('util_index.tmp_backup_index', 'U') IS NOT NULL
	BEGIN
		TRUNCATE TABLE util_index.tmp_backup_index
		RAISERROR('INFO:  (util_index.maintain_index_data)  | table util_index.tmp_backup_index truncated',0,1) WITH NOWAIT
	END

	DROP TABLE IF EXISTS #db_names
	SELECT s.id,
    	   util.quotename_if_required(s.value) AS database_name
    	INTO #db_names
    FROM config.settings s
    WHERE s.category = 'index_mgnt'
    	AND s.[key] = 'database_name'

	/* LOOP */
	WHILE (SELECT MIN(id)
           FROM #db_names) IS NOT NULL
	BEGIN
		DECLARE @id INT = (SELECT MIN(id)
                           FROM #db_names)
		DECLARE @db_name NVARCHAR(500) = (SELECT database_name
                                          FROM #db_names
                                          WHERE id = @id)

		EXEC util_index.get_index_by_database_name
			@database_name = @db_name,@append = 1

		IF (SELECT COUNT(*)
            FROM util_index.tmp_backup_index) > 0
		BEGIN

			MERGE util_index.indexes AS i
			USING (SELECT stmt,
                   	      [database_name],
                   	      schema_name,
                   	      index_name,
                   	      table_name
                   FROM util_index.tmp_backup_index ) AS BI
			ON (
				i.[database_name] = bi.[database_name]
				AND i.index_name = bi.index_name
				AND i.schema_name = bi.schema_name)
			WHEN MATCHED AND i.create_stmt <> bi.stmt THEN
			UPDATE
			SET   i.create_stmt =  bi.stmt
				, i.row_modified = GETDATE()
			WHEN NOT MATCHED THEN
			INSERT ([database_name], create_stmt, schema_name, table_name, index_name, drop_statement,is_system, comment)
			VALUES (bi.[database_name],bi.stmt , bi.schema_name, bi.table_name ,bi.index_name, 'DROP INDEX '+QUOTENAME(bi.index_name)+' ON '+QUOTENAME(bi.schema_name)+'.' +QUOTENAME(bi.table_name) ,1, 'loaded from storedprocedure')
			;

			DELETE FROM #db_names
			WHERE id = @id

		END
	END


	--SELECT *
 --   FROM [util_index].[indexes]