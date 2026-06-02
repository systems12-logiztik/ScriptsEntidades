/*
VERSION     MODIFIEDBY					MODIFIEDDATE    HU          MODIFICATION
1           Cristhian Cuichan           2025-12-10      55188       Initial Code - Add Columns ConsigneeId and BillToConsigneeId into PoEncabezado 
*/


IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('PoEncabezado') AND name = 'ConsigneeId')
BEGIN
    ALTER TABLE PoEncabezado ADD ConsigneeId VARCHAR(16) NULL;
    PRINT 'Columna ConsigneeId agregada a PoEncabezado';
END
ELSE
BEGIN
    PRINT 'Columna ConsigneeId ya existe en PoEncabezado';
END
