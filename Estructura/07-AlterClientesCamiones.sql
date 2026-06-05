/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION
1		    Jorge Ortiz			2025-11-10	    67468	Initial Code - Change idCliente to null and add EntityTypeId column to ClientesCamiones table with FK to EntityTypes
*/
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ClientesCamiones' 
    AND TABLE_SCHEMA = 'dbo' 
    AND COLUMN_NAME = 'EntityTypeId'
)
BEGIN
    ALTER TABLE [dbo].[ClientesCamiones]
    ADD [EntityTypeId] VARCHAR(16) NULL
    
    PRINT 'Column EntityTypeId added to ClientesCamiones table successfully.'
END
ELSE
BEGIN
    PRINT 'Column EntityTypeId already exists in ClientesCamiones table.'
END



