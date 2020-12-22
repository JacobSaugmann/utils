/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [Primary],
		FILENAME = '$(DefaultDataPath)$(DefaultFilePrefix)_Primary.ndf',
		SIZE = 64MB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 128MB
	)TO FILEGROUP [Primary];
	
