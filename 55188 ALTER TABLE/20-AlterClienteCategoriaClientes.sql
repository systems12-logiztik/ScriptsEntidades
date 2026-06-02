/*    
VERSION     MODIFIEDBY          MODIFIEDDATE    HU      MODIFICATION
1           Jordan Chango       2026-03-23      55188   Initial Code - Add EntityTypeId column to ClienteCategoriaClientes
*/
 
IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ClienteCategoriaClientes'
    AND TABLE_SCHEMA = 'dbo'
    AND COLUMN_NAME = 'EntityTypeId'
)
BEGIN
    ALTER TABLE [dbo].ClienteCategoriaClientes
    ADD [EntityTypeId] VARCHAR(16) NULL;
 
    PRINT 'Column EntityTypeId added to ClienteCategoriaClientes table successfully.'
END
ELSE
BEGIN
    PRINT 'Column EntityTypeId already exists in ClienteCategoriaClientes table.'
END