/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION
1		    Jorge Ortiz			2026-01-07	    67468	Initial Code - Add EntityTypeId column to AgentesCliente table with FK to EntityTypes
*/
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'AgentesCliente' 
    AND TABLE_SCHEMA = 'dbo' 
    AND COLUMN_NAME = 'EntityTypeId'
)
BEGIN
    ALTER TABLE [dbo].[AgentesCliente]
    ADD [EntityTypeId] VARCHAR(16) NULL
		CONSTRAINT [FK_CustomerAgents_EntityTypes] 
        FOREIGN KEY ([EntityTypeId]) 
        REFERENCES [dbo].[EntityTypes]([Id])
        NOT FOR REPLICATION
    
    PRINT 'Column EntityTypeId added to AgentesCliente table successfully.'
END
ELSE
BEGIN
    PRINT 'Column EntityTypeId already exists in AgentesCliente table.'
END


