/*
VERSION     MODIFIEDBY					MODIFIEDDATE    HU          MODIFICATION
1           Cristhian Cuichan           2026-02-13      55188       Initial Code - Add Columns BillToConsigneeId into Guias 
*/

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Guias') AND name = 'BillToConsigneeId')
BEGIN
    ALTER TABLE Guias ADD BillToConsigneeId VARCHAR(16) NULL;
    PRINT 'Columna BillToConsigneeId agregada a Guias';
END
ELSE
BEGIN
    PRINT 'Columna BillToConsigneeId ya existe en Guias';
END