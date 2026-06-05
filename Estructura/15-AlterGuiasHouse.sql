/*
VERSION     MODIFIEDBY					MODIFIEDDATE    HU          MODIFICATION
1           Cristhian Cuichan           2025-12-10      67468       Initial Code - Add Columns ConsigneeId and BillToConsigneeId into GuiasHouse 
*/

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('GuiasHouse') AND name = 'ConsigneeId')
BEGIN
    ALTER TABLE GuiasHouse ADD ConsigneeId VARCHAR(16) NULL,
				BillToConsigneeId VARCHAR(16) NULL;
    PRINT 'Columna ConsigneeId y BillToConsigneeId agregada a GuiasHouse';
END
ELSE
BEGIN
    PRINT 'Columna ConsigneeId y BillToConsigneeId ya existe en GuiasHouse';
END



