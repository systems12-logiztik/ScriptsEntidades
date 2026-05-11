/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION
1		    Jorge Ortiz			2026-01-07	    55188	Initial Code - Add EntityTypeId column to ClientesFacturacion table with FK to EntityTypes
*/
IF NOT EXISTS ( 
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ClientesCarrierCuentas' 
    AND TABLE_SCHEMA = 'dbo' 
    AND COLUMN_NAME = 'EntityTypeId'
)
BEGIN
    ALTER TABLE [dbo].[ClientesCarrierCuentas]
    ADD [EntityTypeId] VARCHAR(16) NULL

    PRINT 'Column EntityTypeId added to ClientesCarrierCuentas table successfully.'
END
ELSE
BEGIN
    PRINT 'Column EntityTypeId already exists in ClientesCarrierCuentas table.'
END