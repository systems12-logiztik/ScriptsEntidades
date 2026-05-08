/*
VERSION     MODIFIEDBY     MODIFIEDDATE    HU          MODIFICATION
1           Cristhian Cuichan           2025-12-10      55188       Initial Code - Add Columns BilltoConsigneeId and ShipToId into GuiasHouseDetalles 
*/

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('GuiasHouseDetalles') AND name = 'BilltoConsigneeId')
BEGIN
    ALTER TABLE GuiasHouseDetalles ADD BilltoConsigneeId VARCHAR(16) NULL
    ,ShipToId VARCHAR(16) NULL;
    PRINT 'Columna BilltoConsigneeId y ShipToId agregada a GuiasHouseDetalles';
END
ELSE
BEGIN
    PRINT 'Columna BilltoConsigneeId y ShipToId ya existe en GuiasHouseDetalles';
END