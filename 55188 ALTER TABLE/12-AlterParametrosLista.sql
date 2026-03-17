/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU				MODIFICATION
1			    Jorge Ortiz			2025-10-04		CT 46760		Initial Code - PrametrosLista: Add level, detailDescription
*/
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ParametrosLista' 
    AND COLUMN_NAME IN (
		'DetailDescription'
    )
)
BEGIN
	ALTER TABLE dbo.ParametrosLista
		ADD DetailDescription VARCHAR(8000) NULL;
		
	PRINT 'Columns "DetailDescription" added successfully to table "ParametrosLista".'
END
ELSE
BEGIN
    PRINT 'The column in "DetailDescription" exists in the table "ParametrosLista".'
END