/*    
VERSION		MODIFIEDBY				MODIFIEDDATE	HU		MODIFICATION
1		    Cristian Cuichan		2025-12-08	    55188	Initial Code - Add EntityReferenceId column to DetalleEntidades
*/

IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'DetalleEntidades' 
    AND TABLE_SCHEMA = 'dbo' 
    AND COLUMN_NAME = 'EntityReferenceId'
)
BEGIN
    ALTER TABLE [dbo].[DetalleEntidades]
    ADD [EntityReferenceId] VARCHAR(16) NULL;

    PRINT 'Column EntityReferenceId added to DetalleEntidades table successfully.'
END
ELSE
BEGIN
    PRINT 'Column EntityReferenceId already exists in DetalleEntidades table.'
END

