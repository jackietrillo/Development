USE Test

ALTER DATABASE Test SET RECOVERY SIMPLE WITH NO_WAIT

DBCC SHRINKFILE(LDCDev_Log, 1)

ALTER DATABASE Test SET RECOVERY FULL WITH NO_WAIT
GO