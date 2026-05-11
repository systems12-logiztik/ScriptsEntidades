/*
VERSION     MODIFIEDBY					MODIFIEDDATE    HU          MODIFICATION
1           Cristhian Cuichan           2025-12-10      55188       Initial Code - Add Columns ConsigneeId and BillToConsigneeId into OrdenesLocales 
*/

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('OrdenesLocales') AND name = 'ConsigneeId')
BEGIN
    ALTER TABLE OrdenesLocales ADD ConsigneeId VARCHAR(16) NULL,
									BillToConsigneeId VARCHAR(16) NULL;
    PRINT 'Columna ConsigneeId y BillToConsigneeId agregada a OrdenesLocales';
END
ELSE
BEGIN
    PRINT 'Columna ConsigneeId y BillToConsigneeId ya existe en OrdenesLocales';
END


