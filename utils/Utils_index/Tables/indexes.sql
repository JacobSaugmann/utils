CREATE TABLE util_index.indexes(
	id INT IDENTITY(1,1) PRIMARY KEY,
	database_name SYSNAME,
	schema_name SYSNAME,
	index_name SYSNAME,
	table_name SYSNAME,
	create_stmt NVARCHAR(4000),
	drop_statement NVARCHAR(4000),
	is_system BIT DEfAULT(0),
	is_custom BIT DEFAULT(0),
	[drop] BIT DEFAULT(0),
	[disable] BIT DEFAULT(0),
	[create] BIT DEFAULT(0),
	[ignore] BIT DEFAULT(0),
	row_loaded DATETIME2 DEFAULT(GETDATE()),
	row_modified DATETIME2 DEFAULT(GETDATE()),
	comment nvarchar(2000)

) ON [Data] WITH (DATA_COMPRESSION = PAGE)