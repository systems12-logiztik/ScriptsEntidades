/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION
1		    Jorge Ortiz			2025-01-07	    55188	Initial Code - Add EntityTypeId column to ClientesFacturacion table with FK to EntityTypes
*/
IF NOT EXISTS ( --no es necesario se puede usar idCliente mientras se tome una decision de crecimiento horizontal o vertical
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ClientesFacturacion' 
    AND TABLE_SCHEMA = 'dbo' 
    AND COLUMN_NAME = 'EntityTypeId'
)
BEGIN
    ALTER TABLE [dbo].[ClientesFacturacion]
    ADD [EntityTypeId] VARCHAR(16)

    PRINT 'Column EntityTypeId added to ClientesFacturacion table successfully.'
END
ELSE
BEGIN
    PRINT 'Column EntityTypeId already exists in ClientesFacturacion table.'
END