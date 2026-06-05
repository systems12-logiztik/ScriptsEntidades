/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION
1		    Cristian Ponce		2025-12-08	    67468	Initial Code - Add EntityReferenceId column to CodigosRelacionSistemas
*/

IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'CodigosRelacionSistemas' 
    AND TABLE_SCHEMA = 'dbo' 
    AND COLUMN_NAME = 'EntityRelationId'
)
BEGIN
    ALTER TABLE [dbo].[CodigosRelacionSistemas]
    ADD [EntityRelationId] VARCHAR(16) NULL;

    PRINT 'Column EntityRelationId added to CodigosRelacionSistemas table successfully.'
END
ELSE
BEGIN
    PRINT 'Column EntityRelationId already exists in CodigosRelacionSistemas table.'
END



