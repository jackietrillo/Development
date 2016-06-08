IF NOT EXISTS(SELECT name FROM master.dbo.sysdatabases WHERE name = 'App')
BEGIN
	CREATE DATABASE App ON  PRIMARY 
	( NAME = N'App_data', FILENAME = N'D:\Data\App_data.mdf', SIZE = 12544KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
	 LOG ON 
	( NAME = N'App_log', FILENAME = N'D:\Data\App_log.ldf', SIZE = 8512KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)	
END;
GO