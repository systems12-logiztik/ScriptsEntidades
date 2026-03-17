/*
VERSION     MODIFIEDBY					MODIFIEDDATE    HU          MODIFICATION
1           Cristhian Cuichan           2025-12-10      53095       Initial Code - Add Column ShipToId into PoDetalles 
*/

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('PoDetalles') AND name = 'ShipToId')
BEGIN
    ALTER TABLE PoDetalles ADD ShipToId VARCHAR(16) NULL;
    PRINT 'Columna ShipToId agregada a PoDetalles';
END
ELSE
BEGIN
    PRINT 'Columna ShipToId ya existe en PoDetalles';
END