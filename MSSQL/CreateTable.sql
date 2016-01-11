
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LearningPlanRecurrenceJobProfileCompletion]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[LearningPlanRecurrenceJobProfileCompletion](
        [LearningPlanRecurrenceJobProfileCompletionId]  INT IDENTITY(1, 1) NOT NULL,
        [LearningPlanRecurrenceUserCompletionId]        INT NOT NULL CONSTRAINT [FK_LearningPlanRecurrenceJobProfileCompletion_LearningPlanRecurrenceUserCompletion] REFERENCES [dbo].[LearningPlanRecurrenceUserCompletion]([LearningPlanRecurrenceUserCompletionId]),
        [JobProfileId]                                  UNIQUEIDENTIFIER NOT NULL CONSTRAINT [FK_LearningPlanRecurrenceJobProfileCompletion_JobProfile] REFERENCES [dbo].[SC_JobProfile]([JobProfileID]),
        [CreateUserId]                                  NUMERIC(18, 0) NOT NULL CONSTRAINT [FK_LearningPlanRecurrenceJobProfileCompletion_Users] REFERENCES [dbo].[Users]([User_ID]),
        [CreateDateUtc]                                 DATETIME NOT NULL CONSTRAINT [DF_LearningPlanRecurrenceJobProfileCompletion_CreateDateUtc] DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_LearningPlanRecurrenceJobProfileCompletion] PRIMARY KEY ([LearningPlanRecurrenceJobProfileCompletionId])
    )

    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The unique identifier of recurring Learning Plan Job Profile completion.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LearningPlanRecurrenceJobProfileCompletion', @level2type=N'COLUMN',@level2name=N'LearningPlanRecurrenceJobProfileCompletionId'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The unique identifier of recurring Learning Plan user completion.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LearningPlanRecurrenceJobProfileCompletion', @level2type=N'COLUMN',@level2name=N'LearningPlanRecurrenceUserCompletionId'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The unique identifier of Job Profile.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LearningPlanRecurrenceJobProfileCompletion', @level2type=N'COLUMN',@level2name=N'JobProfileId'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The unique identifier of user who has created this completion record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LearningPlanRecurrenceJobProfileCompletion', @level2type=N'COLUMN',@level2name=N'CreateUserId'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date of creation of this completion record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LearningPlanRecurrenceJobProfileCompletion', @level2type=N'COLUMN',@level2name=N'CreateDateUtc'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[LearningPlanRecurrenceJobProfileCompletion]') AND name = N'IX_LearningPlanRecurrenceJobProfileCompletion_LearningPlanRecurrenceUserCompletionId')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_LearningPlanRecurrenceJobProfileCompletion_LearningPlanRecurrenceUserCompletionId] ON [dbo].[LearningPlanRecurrenceJobProfileCompletion] ([LearningPlanRecurrenceUserCompletionId])
END
GO

GRANT SELECT ON [dbo].[LearningPlanRecurrenceJobProfileCompletion] TO WebApp
GRANT INSERT ON [dbo].[LearningPlanRecurrenceJobProfileCompletion] TO WebApp
GO
