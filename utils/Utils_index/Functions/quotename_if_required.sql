
CREATE FUNCTION util.quotename_if_required(@input_name NVARCHAR(500))
RETURNS NVARCHAR(500)
AS
BEGIN

	IF @input_name LIKE '% %' AND (LEFT(@input_name, 1) <> '[' OR RIGHT(@input_name,1) <> ']')
		SET @input_name = QUOTENAME(@input_name)

	RETURN @input_name
END
