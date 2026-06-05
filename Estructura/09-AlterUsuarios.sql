/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION
1		    Cristian Ponce		2025-12-08	    67468	Initial Code - Add EntityTypeId column to Usuarios
*/

IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Usuarios' 
    AND TABLE_SCHEMA = 'dbo' 
    AND COLUMN_NAME = 'EntityTypeId'
)
BEGIN
    ALTER TABLE [dbo].[Usuarios]
    ADD [EntityTypeId] VARCHAR(16) NULL,
        [EntityType] INT NULL;

    PRINT 'Columns EntityTypeId and EntityType added to Usuarios table successfully.'
END
ELSE
BEGIN
    PRINT 'Columns EntityTypeId and EntityType already exist in Usuarios table.'
END

