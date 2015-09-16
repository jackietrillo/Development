--PLEASE NOTE THAT GRANTING ACCESS TO PUBLIC IS A BAD PRACTICE; A SEPARATE ROLE SHOULD BE CREATED INSTEAD, AND USERS GRANTED TO THAT ROLE.
--THIS SCRIPT IS PROVIDED TO HELP USERS WHO ARE CURRENTLY GRANTING TO PUBLIC TO BE ABLE TO ACCESS NEWLY CREATED OBJECTS
DECLARE @OBJECTNAME VARCHAR(128),
        @XTYPE      VARCHAR(2)
--USER TABLES
DECLARE TCURSOR CURSOR FOR 
        SELECT sysobjects.name,sysobjects.xtype  
        FROM   sysobjects, sysusers
        WHERE  (sysobjects.xtype in('U','V','P'))  
               and (sysobjects.name NOT LIKE 'dt_%')
               and (sysobjects.uid = sysusers.uid)
               and (sysusers.name <> 'INFORMATION_SCHEMA')
 OPEN TCURSOR
    FETCH NEXT FROM TCURSOR INTO @OBJECTNAME,@XTYPE
    WHILE @@fetch_status >= 0
        BEGIN
          IF @XTYPE IN('U')
                BEGIN            
                  PRINT 'GRANT SELECT,INSERT, UPDATE, DELETE ON ' + @OBJECTNAME + ' TO public '
                  exec( 'GRANT SELECT,INSERT, UPDATE, DELETE ON ' + @OBJECTNAME + ' TO public ')
                END
          IF @XTYPE IN('V')
                BEGIN            
                  PRINT 'GRANT SELECT ON ' + @OBJECTNAME + ' TO public '
                  exec('GRANT SELECT ON ' + @OBJECTNAME + ' TO public ')
                END
          IF @XTYPE IN('P')   
                BEGIN            
                  PRINT 'GRANT EXECUTE ON ' + @OBJECTNAME + ' TO public '
                  exec ('GRANT EXECUTE ON ' + @OBJECTNAME + ' TO public ')
                END
        FETCH NEXT FROM TCURSOR INTO @OBJECTNAME,@XTYPE
        END
    CLOSE TCURSOR
    DEALLOCATE TCURSOR
GO    
