CREATE TRIGGER [util_index].[tgr_enableindex] 
   ON  [util_index].[indexes]
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	   
	DECLARE @disable_before BIT, 
			@disable_updated BIT,
			@created_before BIT,
			@created_updated BIT,
			@drop_before BIT,
			@drop_updated BIT

	SELECT  @disable_before = del.[disable],
			@created_before = del.[create],
			@drop_before = del.[drop]
	FROM  deleted del
           


	SELECT @disable_updated = [disable]
	FROM inserted
	 
	DECLARE @msg NVARCHAR(200)
	SET @msg = 'DEBUG (util_index.tgr_enableindex) -| ' 
	RAISERROR(@msg, 0,1) WITH NOWAIT

	DECLARE @sql_query NVARCHAR(4000)
	
	BEGIN TRY
		IF(@disable_before = 1 AND @disable_updated = 0)
		BEGIN
				
			SELECT @sql_query = ix.enable_stmt
			FROM inserted i 
			CROSS APPLY util_index.get_index_statements(i.id) AS ix

			EXEC sp_executesql @sql_query
		
			SET @msg = @msg + ' enabled index'
			RAISERROR(@msg, 0,1) WITH NOWAIT

		END
		
	/*	IF(@disable_before = 0 AND @disable_updated = 1)
		BEGIN

				
			SELECT @sql_query = ix.disblae_stmt
			FROM inserted i 
			CROSS APPLY util_index.get_index_statements(i.id) AS ix

			EXEC sp_executesql @sql_query
		
			SET @msg = @msg + ' disabled index'
			RAISERROR(@msg, 0,1) WITH NOWAIT

		END*/

	END TRY
	BEGIN CATCH

		SET @msg = @msg + ' error: ' +ERROR_MESSAGE()
		RAISERROR(@msg, 0,1) WITH NOWAIT

	END CATCH

END