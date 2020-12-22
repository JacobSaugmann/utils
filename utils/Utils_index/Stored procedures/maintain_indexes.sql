--EXEC util_index.maintain_index_data
CREATE PROC util_index.maintain_indexes
AS
SET NOCOUNT ON;
DECLARE @id INT, @is_drop BIT, @is_disable BIT, @drop_statement NVARCHAR(4000), @disblae_statement NVARCHAR(4000), @create_statement NVARCHAR(1000), @is_create BIT

DECLARE cursor_index_mgnt CURSOR
    FOR (
SELECT  i.id,
		i.[drop],
		i.disable,
		i.[create],
		ix.drop_statement,
		ix.disblae_stmt,
		ix.create_stmt
FROM [util_index].[indexes] i
CROSS APPLY util_index.get_index_statements(i.id) ix
WHERE i.[drop] = 1 OR i.[disable] = 1 OR i.[create] = 1)

OPEN cursor_index_mgnt
FETCH NEXT FROM cursor_index_mgnt INTO @id, @is_drop, @is_disable, @is_create,@drop_statement,@disblae_statement, @create_statement

WHILE @@FETCH_STATUS = 0  
    BEGIN
		/*Do Work*/

		IF @is_disable = 1
		BEGIN
			EXEC sp_executesql @disblae_statement
			RAISERROR('Index disabled',0,1) WITH NOWAIT
			UPDATE i	
				SET row_modified = GETDATE(),
					comment = 'Index disabled'
			FROM util_index.indexes i
			WHERE i.id = @id
		END
		IF @is_drop = 1
		BEGIN 

			EXEC sp_executesql @drop_statement
			UPDATE i	
				SET row_modified = GETDATE(),
					comment = 'Index dropped'
			FROM util_index.indexes i
			WHERE i.id = @id
		END
		IF @is_create = 1
		BEGIN 

			EXEC sp_executesql @create_statement
			UPDATE i	
				SET row_modified = GETDATE(),
					comment = 'Index re-created'
			FROM util_index.indexes i
			WHERE i.id = @id
		END

        FETCH NEXT FROM cursor_index_mgnt INTO @id,@is_drop,@is_disable, @is_create,@drop_statement,@disblae_statement,@create_statement
    END;

CLOSE cursor_index_mgnt
DEALLOCATE cursor_index_mgnt 

