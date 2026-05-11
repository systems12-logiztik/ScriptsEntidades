/*
VERSION     MODIFIEDBY					MODIFIEDDATE    HU          MODIFICATION
1           Cristhian Cuichan           2026-02-13      55188       Initial Code - Add Columns ConsigneeId and BillToConsigneeId into Guias 
*/

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Guias') AND name = 'ConsigneeId')
BEGIN
    ALTER TABLE Guias ADD ConsigneeId VARCHAR(16) NULL,
						BillToConsigneeId VARCHAR(16) NULL;
    PRINT 'Columna ConsigneeId y BillToConsigneeId agregada a Guias';
END
ELSE
BEGIN
    PRINT 'Columna ConsigneeId y BillToConsigneeId ya existe en Guias';
END