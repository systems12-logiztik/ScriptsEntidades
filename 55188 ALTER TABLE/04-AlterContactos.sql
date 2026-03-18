/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION
1		    Cristian Ponce		2025-12-08	    55188	Initial Code - Add EntityTypeId column to Contactos
*/
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Contactos' 
    AND TABLE_SCHEMA = 'dbo' 
    AND COLUMN_NAME = 'EntityTypeId'
)
BEGIN
    ALTER TABLE [dbo].[Contactos]
    ADD [EntityTypeId] VARCHAR(16) NULL;

    PRINT 'Column EntityTypeId added to Contactos table successfully.'
END
ELSE
BEGIN
    PRINT 'Column EntityTypeId already exists in Contactos table.'
END