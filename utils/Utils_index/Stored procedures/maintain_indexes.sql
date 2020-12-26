--EXEC util_index.maintain_index_data
CREATE PROC util_index.maintain_indexes
AS
SET NOCOUNT ON;
DECLARE @id INT, @is_drop BIT, @is_disable BIT, @drop_statement NVARCHAR(4000), @disblae_statement NVARCHAR(4000), @create_statement NVARCHAR(1000), @is_create BIT, @database_name VARCHAR(500),@index_name VARCHAR(500), @schema_name  VARCHAR(500)

DECLARE @msg NVARCHAR(2000) = ''

DECLARE cursor_index_mgnt CURSOR
    FOR (
SELECT  i.id,
		i.[drop],
		i.disable,
		i.[create],
		ix.drop_statement,
		ix.disblae_stmt,
		ix.create_stmt,
		i.database_name,
		i.index_name,
		i.schema_name
FROM [util_index].[indexes] i
CROSS APPLY util_index.get_index_statements(i.id) ix
WHERE (i.[drop] = 1 OR i.[disable] = 1 OR i.[create] = 1)  AND i.ignore = 0)

OPEN cursor_index_mgnt
FETCH NEXT FROM cursor_index_mgnt INTO @id, @is_drop, @is_disable, @is_create,@drop_statement,@disblae_statement, @create_statement, @database_name,@index_name, @schema_name
DECLARE @index_exists BIT = 0

WHILE @@FETCH_STATUS = 0  
    BEGIN
		/*Do Work*/

		SET @msg = 'DEBUG (util_index.maintain_indexes) -| is_drop: '+IIF(@is_drop = 1, 'Yes', 'No') + ' is_disable: '+IIF(@is_disable = 1, 'Yes', 'No')+ ' is create: ' + IIF(@is_create = 1, 'Yes', 'No')
		RAISERROR(@msg,0,1) WITH NOWAIT


		EXEC util_index.index_exists @database_name = @database_name, @schema_name = @schema_name, @index_name = @index_name, @exists = @index_exists OUT
		
		IF NULLIF(@index_exists,'') IS NULL
			SET @index_exists = 0



		IF @is_disable = 1 AND @index_exists = 1
		BEGIN
			EXEC sp_executesql @disblae_statement

			SET @msg = 'DEBUG (util_index.maintain_indexes) -| Index ' + @index_name + ' is now disabled'
			RAISERROR(@msg,0,1) WITH NOWAIT

			UPDATE i	
				SET row_modified = GETDATE(),
					comment = 'Index disabled'
			FROM util_index.indexes i
			WHERE i.id = @id
		END
		IF @is_drop = 1 AND @index_exists = 1
		BEGIN 

			EXEC sp_executesql @drop_statement

			SET @msg = 'DEBUG (util_index.maintain_indexes) -| Index ' + @index_name + ' is now dropped'
			RAISERROR(@msg,0,1) WITH NOWAIT

			UPDATE i	
				SET row_modified = GETDATE(),
					comment = 'Index dropped'
			FROM util_index.indexes i
			WHERE i.id = @id
		END
		
		IF @is_create = 1 AND @index_exists = 0
		BEGIN 

			EXEC sp_executesql @create_statement

			SET @msg = 'DEBUG (util_index.maintain_indexes) -| Index ' + @index_name + ' is now created'
			RAISERROR(@msg,0,1) WITH NOWAIT

			UPDATE i	
				SET row_modified = GETDATE(),
					comment = 'Index re-created'
			FROM util_index.indexes i
			WHERE i.id = @id
		END

        FETCH NEXT FROM cursor_index_mgnt INTO @id,@is_drop,@is_disable, @is_create,@drop_statement,@disblae_statement,@create_statement, @database_name,@index_name, @schema_name

    END;

CLOSE cursor_index_mgnt
DEALLOCATE cursor_index_mgnt 


CLOSE cursor_index_mgnt
DEALLOCATE cursor_index_mgnt 

