CREATE PROC util_index.index_exists( @database_name VARCHAR(500), @schema_name  VARCHAR(500) ,  @index_name VARCHAR(500), @exists BIT = 0 OUT)
AS
BEGIN
--DECLARE @database_name VARCHAR(500) = 'AdventureWorks2008R2', @schema_name  VARCHAR(500) = 'Person',  @exists BIT, @index_name VARCHAR(500) = 'idx_adress_city_postalcode'


DECLARE @sql    NVARCHAR(MAX)
,   @objid  INT

SET @sql = N'
    USE '+@database_name+' 

    SELECT  @id = COUNT(*)
	FROM sys.indexes i
		INNER jOIN sys.tables t
			ON i.object_id = t.object_id
		INNER JOIN sys.schemas s
			ON t.schema_id = s.schema_id
WHERE s.name = '''+@schema_name+''' AND i.name = '''+@index_name+'''
'

EXEC sp_executesql @sql
    ,   N'@id INT OUTPUT'
    ,   @id = @objid OUTPUT


SELECT @exists = CASE WHEN @objid > 0 THEN 1 ELSE 0 END 

DECLARE @msg NVARCHAR(2000) = ''

SET @msg = 'DEBUG:(index_utils.index_exists) -| index: ' +@index_name + ' exists: ' +IIF(@objid > 0, 'Yes', 'No')
RAISERROR(@msg,0,1) WITH NOWAIT

END