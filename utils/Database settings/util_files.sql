/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [data01],
		FILENAME = '$(DefaultDataPath)$(DefaultFilePrefix)_Data01.mdf',
		SIZE = 128MB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 128MB
	) TO FILEGROUP [DATA];
GO

ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [data02],
		FILENAME = '$(DefaultDataPath)$(DefaultFilePrefix)_Data02.ndf',
		SIZE = 128MB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 128MB
	)TO FILEGROUP [DATA];
GO	

ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [data03],
		FILENAME = '$(DefaultDataPath)$(DefaultFilePrefix)_Data03.ndf',
		SIZE = 128MB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 128MB
	)	TO FILEGROUP [DATA];
GO	

ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [data04],
		FILENAME = '$(DefaultDataPath)$(DefaultFilePrefix)_Data04.ndf',
		SIZE = 128MB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 128MB
	)
	TO FILEGROUP [DATA];
GO
