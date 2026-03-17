/*
VERSION     MODIFIEDBY      	MODIFIEDDATE    HU      MODIFICATION
1           Fernando Ordoñez     2026-02-27     57725   Optimized indexes for GuiasHouseDetalles
*/

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_GuiasHouseDetalles_shipToId')
	BEGIN
		CREATE NONCLUSTERED INDEX [idx_GuiasHouseDetalles_shipToId] ON [dbo].[GuiasHouseDetalles]
		(
			[shipToId] ASC,
			[estadoPieza] ASC
		)
		INCLUDE([id],[idGuiaHouse],[codigoBarra],[fechaCambio],[scanDespacho]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	END
GO

