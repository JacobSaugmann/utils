

CREATE TABLE config.settings(
	id INT IDENTITY(1,1) PRIMARY KEY,
	category VARCHAR(30) NOT NULL,
	[key] VARCHAR(250) NOT NULL,
	[value] VARCHAR(250) NOT NULL

) ON [DATA] WITH (DATA_COMPRESSION = PAGE)
GO

--INSERT INTO config.settings(category, [key], [value])
--VALUES ('index_mgnt', 'database_name', 'AdventureWorks'),('index_mgnt', 'database_name', 'AdventureWorks2008R2'),('index_mgnt', 'database_name', 'AdventureWorks2016')
