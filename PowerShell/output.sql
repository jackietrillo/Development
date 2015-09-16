/*
	Author: Jackie Trillo
	Date: 03/04/2014
	Purpose:  LEARN-12016 custom fields refactoring via new proc Service_sp_CustomFields

*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Service_sp_CustomFields]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Service_sp_CustomFields]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Service_sp_CustomFields]
@LearnCenterId INT,
@UserId INT,
@ItemTypeId INT
AS
/*****************************************************************************
  SP Description: For the given user, learning plan, and group (id),
				  returns a group

  Revision History:
  Revision		Date		Developer	Change Description
  2014.12.0.1	03/04/2014	JT			Implementation
******************************************************************************/

SET NOCOUNT ON

CREATE TABLE #CustomFields (LC_ID INT,Field_Name nvarchar(255),ItemTypeId INT, ItemId VARCHAR(36),Data nvarchar(max))

INSERT INTO #CustomFields 
SELECT CF.LC_ID, CF.Field_Name, CF.ItemTypeID, CFD.ItemID, (CASE WHEN CF.Type = 'select' AND CFD.Data = '<select one>' THEN '' ELSE CFD.Data END) AS Data
FROM Custom_Fields CF   
  LEFT OUTER JOIN Custom_Fields_Data CFD ON CF.Unique_Field_ID = CFD.Field_ID AND CF.ItemTypeID = CFD.ItemTypeID
WHERE CF.ItemTypeID = @ItemTypeId AND CF.LC_ID = @LearnCenterId
AND CFD.Data IS NOT NULL

DECLARE @cols NVARCHAR(MAX)
DECLARE @colsDdl NVARCHAR(MAX)
DECLARE @query  NVARCHAR(MAX)

SET @cols = STUFF((SELECT DISTINCT ',' + QUOTENAME(CF.Field_Name)
        FROM #CustomFields CF
        FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(MAX)') ,1,1,'')
    
SET @colsDdl = STUFF((SELECT DISTINCT ',' + QUOTENAME('CustomField_' + CF.Field_Name) + ' nvarchar(max)'
        FROM #CustomFields CF
        FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(MAX)') ,1,1,'')
    
SET @query = 'ALTER TABLE #CustomFieldsData ADD ' + @colsDdl
EXEC(@query)

SET @query = 'SELECT ItemId, ' + @cols + ' FROM 
	(
		SELECT Field_Name, Data, ItemId
		FROM #CustomFields
	) X
	PIVOT 
	(
		MIN(Data) FOR Field_Name in (' + @cols + ')
	) Y '
INSERT #CustomFieldsData

EXEC(@query)


SET NOCOUNT OFF

GO

GRANT EXECUTE ON [dbo].[Service_sp_CustomFields] TO WebApp

GO




IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Service_sp_GetUserLearningPlanEnrollment]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Service_sp_GetUserLearningPlanEnrollment]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Service_sp_GetUserLearningPlanEnrollment]
(
	@AuthenticatedUserId INT,
	@LearnCenterId INT,
	@UserId INT,
	@LearningPlanId UNIQUEIDENTIFIER,
	@EnrollmentId INT
)
AS
/*****************************************************************************
  SP Description: For the given user, learning plan, and enrollment (id),
				  returns an enrollment.

  Revision History:
  Revision		Date		Developer	Change Description
  2014.12.0.1	02/07/2014	ENT			Stub
  2014.12.0.2	02/12/2014	ENT			Mock
  2014.12.0.3	02/16/2014	JT			Implementation
  2014.12.0.4	02/17/2014	JT			Added UTC Date Conversion
  2014.12.0.5	02/18/2014	JT			Added Custom Field Support
******************************************************************************/

SET NOCOUNT ON

DECLARE @ItemTypeId INT 
DECLARE @ItemTypeName VARCHAR(36)
SET @ItemTypeId = 8
SET @ItemTypeName = 'Enrollment'

/*********************************UTC DateTime Support************************/

-- Get Server Time Zone info
DECLARE @ServerTZUTCOffset SMALLINT
DECLARE @ServerTZDSTOffset SMALLINT
DECLARE @ServerTZUsesDaylightSavings BIT
DECLARE @ServerTZDaylightSavingsStart DATETIME
DECLARE @ServerTZDaylightSavingsEnd DATETIME

SELECT TOP 1
	@ServerTZUTCOffset = ServerTZUTCOffset,
	@ServerTZDSTOffset = ServerTZDSTOffset,
	@ServerTZUsesDaylightSavings = ServerTZUsesDaylightSavings,
	@ServerTZDaylightSavingsStart = ServerTZDaylightSavingsStart,
	@ServerTZDaylightSavingsEnd = ServerTZDaylightSavingsEnd
FROM dbo.lc_fn_TZ_GetServerTimeZoneInfo()
	
-- Base Time Zone from LearnCenter or Server
DECLARE @TimeZoneBase TABLE(UTCOffset INT, DSTOffset INT, UsesDaylightSavings BIT, DayLightStart DATETIME, DayLightEnd DATETIME)

INSERT INTO @TimeZoneBase
SELECT UTCOffset, DSTOffset, UsesDaylightSavings,  
	dbo.lc_fn_TZ_CalculateDateFromMonthDayInterval(DSTStartMonth, DSTStartDay, DSTStartDayInterval, DSTStartTime) AS DayLightStart,    
	dbo.lc_fn_TZ_CalculateDateFromMonthDayInterval(DSTEndMonth, DSTEndDay, DSTEndDayInterval, DSTEndTime) AS DayLightEnd
FROM lc_fn_TZ_ReadItemTimeZone(CONVERT(VARCHAR(36), @LearnCenterId), 0, @LearnCenterId)

-- Enrollment Info with Base Time Zone information
DECLARE @TimezoneInfo TABLE(ItemId INT, EventTypeId INT, EventId NVARCHAR(36), UTCOffset INT, DSTOffset INT, UsesDaylightSavings BIT, DayLightStart DATETIME, DayLightEnd DATETIME,EnrollmentUTCOffset INT, EnrollmentDSTOffset INT, EnrollmentUsesDaylightSavings BIT, EnrollmentDayLightStart DATETIME, EnrollmentDayLightEnd DATETIME)

INSERT INTO @TimezoneInfo
SELECT CONVERT(VARCHAR(36), LPM.Enrollment_ID) AS ItemId, EN.Event_Type, EN.Event_ID, TZB.UTCOffset, TZB.DSTOffset, TZB.UsesDaylightSavings, TZB.DayLightStart, TZB.DayLightEnd,
TZB.UTCOffset, TZB.DSTOffset, TZB.UsesDaylightSavings, TZB.DayLightStart, TZB.DayLightEnd
FROM SC_LearningPlan_Enrollments_Map (NOLOCK) LPM 
INNER JOIN Enrollments EN (NOLOCK) ON LPM.Enrollment_ID = EN.Enrollment_ID
CROSS JOIN @TimeZoneBase TZB  
WHERE LearningPlanID = @LearningPlanId

--  Event Start/Stop dates use associated event Time Zone information 
UPDATE @TimezoneInfo
SET UTCOffset = TZ.UTCOffset,
    DSTOffset = TZ.DSTOffset,
    UsesDaylightSavings = TZ.ParticipatesInDaylight,                                                                                                                     
	DayLightStart = dbo.lc_fn_TZ_CalculateDateFromMonthDayInterval(TZ.DSTStartMonth, TZ.DSTStartDay, TZ.DSTStartDayInterval, TZ.DSTStartTime),    
    DayLightEnd =  dbo.lc_fn_TZ_CalculateDateFromMonthDayInterval(TZ.DSTEndMonth, TZ.DSTEndDay, TZ.DSTEndDayInterval, TZ.DSTEndTime)
FROM Time_Zones (NOLOCK) TZ INNER JOIN
@TimezoneInfo ETZ ON TZ.ItemID = ETZ.EventId AND TZ.ItemTypeID = ETZ.EventTypeId

-- Registration Start/Stop dates use enrollment Time Zone information 
UPDATE @TimezoneInfo
SET EnrollmentUTCOffset = TZ.UTCOffset,
    EnrollmentDSTOffset = TZ.DSTOffset,
    EnrollmentUsesDaylightSavings = TZ.ParticipatesInDaylight,                                                                                                                     
	EnrollmentDayLightStart = dbo.lc_fn_TZ_CalculateDateFromMonthDayInterval(TZ.DSTStartMonth, TZ.DSTStartDay, TZ.DSTStartDayInterval, TZ.DSTStartTime),    
    EnrollmentDayLightEnd =  dbo.lc_fn_TZ_CalculateDateFromMonthDayInterval(TZ.DSTEndMonth, TZ.DSTEndDay, TZ.DSTEndDayInterval, TZ.DSTEndTime)
FROM Time_Zones TZ (NOLOCK) INNER JOIN
@TimezoneInfo ETZ ON TZ.ItemID = ETZ.ItemID AND TZ.ItemTypeID = 8


/******************************Custom Fields**********************************/

CREATE TABLE #CustomFieldsData (IgnoreItemId VARCHAR(36)) 
exec Service_sp_CustomFields @LearnCenterId, @UserId, @ItemTypeId

/*****************************************************************************/

DECLARE @LearningPlanMappedItems AS LearningPlanMappedItemType   

-- Get learning plan items		
DECLARE @CompleteDate DATETIME 
DECLARE  @CompletionStatus VARCHAR(100) 

INSERT INTO @LearningPlanMappedItems
	EXEC dbo.lc_sp_SC_UserLearningPlanItems @LearningPlanId, @UserId, 0, 0, 'service_storedprocedures',1, 1, 1, @CompletionStatus OUTPUT, @CompleteDate OUTPUT, 0

-- Return user learning plan enrollment
SELECT  MappedItemId As EnrolmentId, 
		MappedItemName AS EnrollmentName,		
		MappedItemOptional As Optional,
		MappedItemStatus AS CompletionStatus, 
		dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(MappedItemStartedDate, TZ.UTCOffset, TZ.DSTOffset, TZ.UsesDaylightSavings, TZ.DayLightStart, TZ.DayLightEnd) 
		AS EventStartDate, 
		dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(MappedItemCompletedDate, TZ.UTCOffset, TZ.DSTOffset, TZ.UsesDaylightSavings, TZ.DayLightStart, TZ.DayLightEnd) 
		AS EventStopDate, 				
		dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(MappedItemDueDate, @ServerTZUTCOffset, @ServerTZDSTOffset, @ServerTZUsesDaylightSavings, @ServerTZDaylightSavingsStart, @ServerTZDaylightSavingsEnd) 
	    AS DueDate, 	   		
		dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(MappedItemRegistrationOpenDate, TZ.EnrollmentUTCOffset, TZ.EnrollmentDSTOffset, TZ.EnrollmentUsesDaylightSavings, TZ.EnrollmentDayLightStart, TZ.EnrollmentDayLightEnd) 
		AS RegistrationOpenDate, 
		dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(MappedItemRegistrationCloseDate, TZ.EnrollmentUTCOffset, TZ.EnrollmentDSTOffset, TZ.EnrollmentUsesDaylightSavings, TZ.EnrollmentDayLightStart, TZ.EnrollmentDayLightEnd) 
		AS RegistrationCloseDate,
		dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(MappedItemEnrolledDate, @ServerTZUTCOffset, @ServerTZDSTOffset, @ServerTZUsesDaylightSavings, @ServerTZDaylightSavingsStart, @ServerTZDaylightSavingsEnd) 
	    AS EnrolledDate, 		
		MappedItemPreStatus AS PreStatus, 
		MappedItemPostStatus AS PostStatus, 
		CP.CourseNumber, 
	    CP.CourseLevel, 
	    CP.Author,
	    CP.Credits,
	    CP.Publisher, 
	    CP.SeriesName, 
	    CP.SeriesNumber, 
	    CP.CostPerUser, 
	    CP.Duration,  
	    C.* -- Custom fields
FROM @LearningPlanMappedItems LP
LEFT OUTER JOIN @TimezoneInfo TZ ON LP.MappedItemId = TZ.ItemID 
LEFT OUTER JOIN CourseProperty CP (NOLOCK) ON CP.ItemID = LP.MappedItemId AND CP.ItemTypeID = @ItemTypeId
LEFT OUTER JOIN #CustomFieldsData C ON LP.MappedItemID = C.IgnoreItemId
WHERE LP.MappedItemType = @ItemTypeName 
AND LP.MappedItemId = ISNULL(CONVERT(VARCHAR(36), @EnrollmentId), LP.MappedItemID) 


SET NOCOUNT OFF

GO

GRANT EXECUTE ON [dbo].[Service_sp_GetUserLearningPlanEnrollment] TO WebApp

GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Service_sp_GetUserLearningPlanGoal]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Service_sp_GetUserLearningPlanGoal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Service_sp_GetUserLearningPlanGoal]
(
	@AuthenticatedUserId INT,
	@LearnCenterId INT,
	@UserId INT,
	@LearningPlanId UNIQUEIDENTIFIER,
	@GoalId INT
)
AS
/*****************************************************************************
  SP Description: For the given user, learning plan, and group (id),
				  returns a group

  Revision History:
  Revision		Date		Developer	Change Description
  2014.12.0.1	02/07/2014	ENT			Stub
  2014.12.0.2	02/12/2014	ENT			Mock
  2014.12.0.3	02/28/2014	JT			Implementation
******************************************************************************/

SET NOCOUNT ON

DECLARE @ItemTypeId INT 
DECLARE @ItemTypeName VARCHAR(36)
SET @ItemTypeId = 35
SET @ItemTypeName = 'Goal'	

/************************************************************************************/

-- START special Server to UTC date time supporting copy-n-paste block
-- Use this with lc_fn_ToUTCDateTimeUsingDefinedParameters

DECLARE @ServerTZUTCOffset smallint
DECLARE @ServerTZDSTOffset smallint
DECLARE @ServerTZUsesDaylightSavings bit
DECLARE @ServerTZDaylightSavingsStart datetime
DECLARE @ServerTZDaylightSavingsEnd datetime

SELECT TOP 1
	@ServerTZUTCOffset = ServerTZUTCOffset,
	@ServerTZDSTOffset = ServerTZDSTOffset,
	@ServerTZUsesDaylightSavings = ServerTZUsesDaylightSavings,
	@ServerTZDaylightSavingsStart = ServerTZDaylightSavingsStart,
	@ServerTZDaylightSavingsEnd = ServerTZDaylightSavingsEnd
FROM dbo.lc_fn_TZ_GetServerTimeZoneInfo()

/******************************Custom Fields*****************************************/

CREATE TABLE #CustomFieldsData (IgnoreItemId VARCHAR(36)) 
exec Service_sp_CustomFields @LearnCenterId, @UserId, @ItemTypeId

/************************************************************************************/

SELECT G.GoalId, 
	   G.GoalName, 
	   G.GoalDesc, 	   
	   dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(G.GoalStartDate, @ServerTZUTCOffset, @ServerTZDSTOffset, @ServerTZUsesDaylightSavings, @ServerTZDaylightSavingsStart, @ServerTZDaylightSavingsEnd) As StartDate,
	   dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(G.GoalEndDate, @ServerTZUTCOffset, @ServerTZDSTOffset, @ServerTZUsesDaylightSavings, @ServerTZDaylightSavingsStart, @ServerTZDaylightSavingsEnd) As EndDate,	   	   
	   G.Recurring, 
	   C.*
FROM PM_GoalItemMap GIM (NOLOCK)  
	INNER JOIN SC_Users_LearningPlan_Map LPUM (NOLOCK) ON GIM.ItemID = CONVERT(VARCHAR(36), LPUM.LearningPlanID) 
	INNER JOIN PM_Goal G (NOLOCK) ON G.GoalID = GIM.GoalID    	
	LEFT OUTER JOIN #CustomFieldsData C ON C.IgnoreItemId = CONVERT(VARCHAR(36), G.GoalID)
WHERE GIM.ItemTypeID = 31 
	AND GIM.ItemID = CONVERT(VARCHAR(36), @LearningPlanId)    
	AND GIM.GoalID = ISNULL(@GoalId, GIM.GoalID)
	AND LPUM.User_ID = @UserId
	AND GIM.StatusFlag = 1    
	AND G.StatusFlag = 1    


SET NOCOUNT OFF

GO

GRANT EXECUTE ON [dbo].[Service_sp_GetUserLearningPlanGoal] TO WebApp

GO




IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Service_sp_GetUserLearningPlanTrainingOffering]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Service_sp_GetUserLearningPlanTrainingOffering]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Service_sp_GetUserLearningPlanTrainingOffering]
@AuthenticatedUserId INT,
@LearnCenterId INT,
@UserId INT,
@LearningPlanId UNIQUEIDENTIFIER,
@TrainingOfferingId INT
AS
/*****************************************************************************
  SP Description: Returns a Training Offering for a given Learning Plan

  Revision History:
  Revision		Date		Developer	Change Description
  2014.12.0.1	02/07/2014	ENT			Stub
  2014.12.0.2	02/11/2014	JT			Mock
  2014.12.0.3	02/28/2014	JT			Implementation
******************************************************************************/

SET NOCOUNT ON

DECLARE @ItemTypeId INT 
DECLARE @ItemTypeName VARCHAR(36)
SET @ItemTypeId = 71
SET @ItemTypeName = 'Training Offering'	

/******************************UTC Date Time Support**************************/

-- START special Server to UTC date time supporting copy-n-paste block
-- Use this with lc_fn_ToUTCDateTimeUsingDefinedParameters
	
DECLARE @ServerTZUTCOffset SMALLINT
DECLARE @ServerTZDSTOffset SMALLINT
DECLARE @ServerTZUsesDaylightSavings BIT
DECLARE @ServerTZDaylightSavingsStart DATETIME
DECLARE @ServerTZDaylightSavingsEnd DATETIME

SELECT TOP 1
	@ServerTZUTCOffset = ServerTZUTCOffset,
	@ServerTZDSTOffset = ServerTZDSTOffset,
	@ServerTZUsesDaylightSavings = ServerTZUsesDaylightSavings,
	@ServerTZDaylightSavingsStart = ServerTZDaylightSavingsStart,
	@ServerTZDaylightSavingsEnd = ServerTZDaylightSavingsEnd
FROM dbo.lc_fn_TZ_GetServerTimeZoneInfo()


/*****************************Custom Fields Support*****************************/

CREATE TABLE #CustomFieldsData (IgnoreItemId VARCHAR(36)) 
exec Service_sp_CustomFields @LearnCenterId, @UserId, @ItemTypeId

/*******************************************************************************/

DECLARE @LearningPlanMappedItems AS LearningPlanMappedItemType   

-- Get learning plan items		
DECLARE @CompleteDate DATETIME 
DECLARE  @CompletionStatus VARCHAR(100) 

INSERT INTO @LearningPlanMappedItems
	EXEC dbo.lc_sp_SC_UserLearningPlanItems @LearningPlanId, @UserId, 0, 0, 'service_storedprocedures',1, 1, 1, @CompletionStatus OUTPUT, @CompleteDate OUTPUT, 0

-- Return user learning plan training offerings
SELECT  MappedItemId As TrainingOfferingId, 
	    MappedItemName AS TrainingOfferingName, 
	    MappedItemStatus AS CompletionStatus,
	    dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(MappedItemStartedDate, @ServerTZUTCOffset, @ServerTZDSTOffset, @ServerTZUsesDaylightSavings, @ServerTZDaylightSavingsStart, @ServerTZDaylightSavingsEnd) 
	    AS StartedDate,         
        dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(MappedItemCompletedDate, @ServerTZUTCOffset, @ServerTZDSTOffset, @ServerTZUsesDaylightSavings, @ServerTZDaylightSavingsStart, @ServerTZDaylightSavingsEnd) 
	    AS CompletedDate, 
        dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(MappedItemDueDate, @ServerTZUTCOffset, @ServerTZDSTOffset, @ServerTZUsesDaylightSavings, @ServerTZDaylightSavingsStart, @ServerTZDaylightSavingsEnd) 
	    AS DueDate, 
	    C.*
FROM @LearningPlanMappedItems LP
LEFT OUTER JOIN #CustomFieldsData C ON LP.MappedItemID = C.IgnoreItemId
WHERE LP.MappedItemType = @ItemTypeName
AND LP.MappedItemId = ISNULL(CONVERT(VARCHAR(36), @TrainingOfferingId), LP.MappedItemId)


SET NOCOUNT OFF

GO

GRANT EXECUTE ON [dbo].[Service_sp_GetUserLearningPlanTrainingOffering] TO WebApp

GO




IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Service_sp_GetUserLearningPlanJobProfile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Service_sp_GetUserLearningPlanJobProfile]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Service_sp_GetUserLearningPlanJobProfile]
@AuthenticatedUserId INT,
@LearnCenterId INT,
@UserId INT,
@LearningPlanId UNIQUEIDENTIFIER,
@JobProfileId UNIQUEIDENTIFIER
AS
/*****************************************************************************
  SP Description: TODO

  Revision History:
  Revision		Date		Developer	Change Description
  2014.12.0.1	02/07/2014	ENT			Stub
  2014.12.0.2	02/11/2014	JT			Mock
  2014.12.0.3	02/28/2014	JT			Implementation
******************************************************************************/

SET NOCOUNT ON

DECLARE @ItemTypeId INT 
DECLARE @ItemTypeName VARCHAR(36)
SET @ItemTypeId = 32
SET @ItemTypeName = 'Job Profile'	

/******************************Custom Fields**********************************/

CREATE TABLE #CustomFieldsData (IgnoreItemId VARCHAR(36)) 
exec Service_sp_CustomFields @LearnCenterId, @UserId, @ItemTypeId

/*****************************************************************************/

SELECT JP.JobProfileID, 
	   JP.JobProfileName, 
	   JP.JobProfileDesc, 
	   JP.JobCode, 
	   JP.JobSalary, 
	   C.*
FROM SC_LearningPlan_JobProfile_Map LPJM (NOLOCK)  
	INNER JOIN SC_Users_LearningPlan_Map LPUM (NOLOCK) ON LPJM.LearningPlanID = LPUM.LearningPlanID 
	INNER JOIN SC_JobProfile JP (NOLOCK) ON JP.JobProfileID = LPJM.JobProfileID    	
	LEFT OUTER JOIN #CustomFieldsData C ON C.IgnoreItemId = CONVERT(VARCHAR(36), JP.JobProfileID)
WHERE LPJM.LearningPlanID = @LearningPlanId    
	AND LPUM.User_ID = @UserId
	AND LPJM.StatusFlag = 1    
	AND JP.StatusFlag = 1    


SET NOCOUNT OFF

GO

GRANT EXECUTE ON [dbo].[Service_sp_GetUserLearningPlanJobProfile] TO WebApp

GO




IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Service_sp_GetUserLearningPlanCourse]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Service_sp_GetUserLearningPlanCourse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Service_sp_GetUserLearningPlanCourse]
@AuthenticatedUserId INT,
@LearnCenterId INT,
@UserId INT,
@LearningPlanId UNIQUEIDENTIFIER,
@CourseId INT
AS
/*****************************************************************************
  SP Description: For the given user, learning plan and course (id), 
				  returns a single course.

  Revision History:
  Revision		Date		Developer	Change Description
  2014.12.0.1	02/07/2014	ENT			Stub
  2014.12.0.2	02/11/2014	ENT			Mock
  2014.12.0.3	02/16/2014	JT			Implementation
  2014.12.0.4	02/17/2014	JT			Added UTC conversion to datetimes
  2014.12.0.5	02/18/2014	JT			Added Custom Field Support
  2014.12.0.6	03/04/2014	ENT			Add 'Ignore' prefix to custom field
******************************************************************************/

SET NOCOUNT ON

DECLARE @ItemTypeId INT 
DECLARE @ItemTypeName VARCHAR(36)
SET @ItemTypeId = 4
SET @ItemTypeName = 'Course'	

/********************************UTC DateTime Support*************************/

DECLARE @ServerTZUTCOffset SMALLINT
DECLARE @ServerTZDSTOffset SMALLINT
DECLARE @ServerTZUsesDaylightSavings BIT
DECLARE @ServerTZDaylightSavingsStart DATETIME
DECLARE @ServerTZDaylightSavingsEnd DATETIME

SELECT TOP 1
	@ServerTZUTCOffset = ServerTZUTCOffset,
	@ServerTZDSTOffset = ServerTZDSTOffset,
	@ServerTZUsesDaylightSavings = ServerTZUsesDaylightSavings,
	@ServerTZDaylightSavingsStart = ServerTZDaylightSavingsStart,
	@ServerTZDaylightSavingsEnd = ServerTZDaylightSavingsEnd
FROM dbo.lc_fn_TZ_GetServerTimeZoneInfo()


/******************************Custom Fields**********************************/

CREATE TABLE #CustomFieldsData (IgnoreItemId VARCHAR(36)) 
exec Service_sp_CustomFields @LearnCenterId, @UserId, @ItemTypeId

/*****************************************************************************/

-- Get all user learning plan data
DECLARE @LearningPlanMappedItems AS LearningPlanMappedItemType 
DECLARE @CompleteDate DATETIME 
DECLARE @CompletionStatus VARCHAR(100) 
INSERT INTO @LearningPlanMappedItems
	EXEC dbo.lc_sp_SC_UserLearningPlanItems @LearningPlanId, @UserId, 0, 0, 'service_storedprocedures',1, 1, 1, @CompletionStatus OUTPUT, @CompleteDate OUTPUT, 0

-- Return user learning plan mapped courses
SELECT MappedItemId As CourseId,
	   MappedItemName AS CourseName, 
	   MappedItemOptional As IsOptional,
	   MappedItemStatus AS CompletionStatus, 
	   dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(LP.MappedItemStartedDate, @ServerTZUTCOffset, @ServerTZDSTOffset, @ServerTZUsesDaylightSavings, @ServerTZDaylightSavingsStart, @ServerTZDaylightSavingsEnd) 
	   AS StartedDate, 
	   dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(LP.MappedItemCompletedDate, @ServerTZUTCOffset, @ServerTZDSTOffset, @ServerTZUsesDaylightSavings, @ServerTZDaylightSavingsStart, @ServerTZDaylightSavingsEnd) 
	   AS CompletedDate, 
	   dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(LP.MappedItemDueDate, @ServerTZUTCOffset, @ServerTZDSTOffset, @ServerTZUsesDaylightSavings, @ServerTZDaylightSavingsStart, @ServerTZDaylightSavingsEnd) 
	   AS DueDate, 
	   dbo.lc_fn_ToUTCDateTimeUsingDefinedParameters(LP.MappedItemExpirationDate, @ServerTZUTCOffset, @ServerTZDSTOffset, @ServerTZUsesDaylightSavings, @ServerTZDaylightSavingsStart, @ServerTZDaylightSavingsEnd) 
	   AS ExpirationDate, 
	   MappedItemPercentComplete AS PercentComplete, 
	   MappedItemScore AS Score,
	   CP.CourseNumber, 
	   CP.CourseLevel, 
	   CP.Author,
	   CP.Credits,
	   CP.Publisher, 
	   CP.SeriesName, 
	   CP.SeriesNumber, 
	   CP.CostPerUser, 
	   CP.Duration,  
	   C.* -- Custom Fields
FROM @LearningPlanMappedItems LP
LEFT OUTER JOIN CourseProperty CP (NOLOCK) ON CP.ItemID = LP.MappedItemId AND CP.ItemTypeID = @ItemTypeId
LEFT OUTER JOIN #CustomFieldsData C ON C.IgnoreItemId = LP.MappedItemId
WHERE LP.MappedItemType = @ItemTypeName 
AND LP.MappedItemID = ISNULL(CONVERT(VARCHAR(36), @CourseId), LP.MappedItemID)

SET NOCOUNT OFF

GO

GRANT EXECUTE ON [dbo].[Service_sp_GetUserLearningPlanCourse] TO WebApp

GO


