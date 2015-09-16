BACKUP DATABASE Test TO DISK='D:\data\Test.BAK'

RESTORE FILELISTONLY
FROM DISK = 'D:\data\Test.bak'

RESTORE DATABASE Test
   FROM DISK = 'D:\data\Test.BAK'
   WITH MOVE 'Test_Data' TO 'D:\Data\Test_Data.mdf',
        MOVE 'Test_Log' TO 'D:\Data\Test_log.LDF',
   REPLACE

