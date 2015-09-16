IF NOT EXISTS(SELECT name FROM master.dbo.sysdatabases WHERE ('[' + name + ']' = 'Test'))
BEGIN
	CREATE DATABASE Test ON  PRIMARY 
	( NAME = N'Test', FILENAME = N'D:\data\test.mdf' , SIZE = 12544KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
	 LOG ON 
	( NAME = N'Test_Log', FILENAME = N'D:\data\data_Log.ldf' , SIZE = 8512KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
END
GO