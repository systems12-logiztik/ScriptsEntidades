/*    
VERSION     MODIFIEDBY          MODIFIEDDATE    HU      MODIFICATION
1           Jordan Chango       2026-03-23      67468   Initial Code - Add EntityTypeId column to ClienteTarifasLocales
*/
 
IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ClienteTarifasLocales'
    AND TABLE_SCHEMA = 'dbo'
    AND COLUMN_NAME = 'EntityTypeId'
)
BEGIN
    ALTER TABLE [dbo].ClienteTarifasLocales
    ADD [EntityTypeId] VARCHAR(16) NULL;
 
    PRINT 'Column EntityTypeId added to ClienteTarifasLocales table successfully.'
END
ELSE
BEGIN
    PRINT 'Column EntityTypeId already exists in ClienteTarifasLocales table.'
END

