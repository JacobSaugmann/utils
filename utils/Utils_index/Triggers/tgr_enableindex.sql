CREATE TRIGGER [util_index].[tgr_enableindex] 
   ON  [util_index].[indexes]
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	   
	DECLARE @disable_before BIT, @disable_updated BIT
	SELECT @disable_before = del.[disable]
	FROM  deleted del
           


	SELECT @disable_updated = [disable]
	FROM inserted
	 
	--DECLARE @msg NVARCHAR(200)
	--SET @msg = CONCAT('value before ', @disable_before,' value after ', @disable_updated)
	--RAISERROR(@msg, 0,1) WITH LOG


	IF(@disable_before = 1 AND @disable_updated = 0)
	BEGIN
		
		DECLARE @sql_query NVARCHAR(4000)
		SELECT @sql_query = ix.enable_stmt
		FROM inserted i 
		CROSS APPLY util_index.get_index_statements(i.id) AS ix

		EXEC sp_executesql @sql_query

	END


END