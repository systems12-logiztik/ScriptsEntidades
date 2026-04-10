/*    
VERSION     MODIFIEDBY          MODIFIEDDATE    HU      MODIFICATION
1           Jordan Chango       2026-02-13      57733   Initial Code - Add EntityReferenceId column to DocumentosDespachoErrores
*/
 
IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'DocumentosDespachoErrores'
    AND TABLE_SCHEMA = 'dbo'
    AND COLUMN_NAME = 'EntityReferenceId'
)
BEGIN
    ALTER TABLE [dbo].[DocumentosDespachoErrores]
    ADD [EntityReferenceId] VARCHAR(16) NULL;
 
    PRINT 'Column EntityReferenceId added to DocumentosDespachoErrores table successfully.'
END
ELSE
BEGIN
    PRINT 'Column EntityReferenceId already exists in DocumentosDespachoErrores table.'
END
