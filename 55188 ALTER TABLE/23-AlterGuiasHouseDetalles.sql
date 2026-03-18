/*
VERSION     MODIFIEDBY					MODIFIEDDATE    HU          MODIFICATION
1           Cristhian Cuichan           2025-12-10      53095       Initial Code - Add Columns ConsigneeId and ShipToId into GuiasHouseDetalles 
*/

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('GuiasHouseDetalles') AND name = 'ConsigneeId')
BEGIN
    ALTER TABLE GuiasHouseDetalles ADD ConsigneeId VARCHAR(16) NULL,
				ShipToId VARCHAR(16) NULL;
    PRINT 'Columna ConsigneeId y ShipToId agregada a GuiasHouseDetalles';
END
ELSE
BEGIN
    PRINT 'Columna ConsigneeId y ShipToId ya existe en GuiasHouseDetalles';
END

