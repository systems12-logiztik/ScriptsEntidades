/*
VERSION     MODIFIEDBY      	MODIFIEDDATE    HU      MODIFICATION
1           Fernando OrdoÃ±ez     2026-02-27     67468   Optimized indexes for GuiasHouseDetalles
*/

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_GuiasHouseDetalles_ShipToId_EstadoPieza')
	BEGIN
		CREATE NONCLUSTERED INDEX [idx_GuiasHouseDetalles_ShipToId_EstadoPieza] ON [dbo].[GuiasHouseDetalles]
		(
			[shipToId] ASC,
			[estadoPieza] ASC
		)
	END
GO


