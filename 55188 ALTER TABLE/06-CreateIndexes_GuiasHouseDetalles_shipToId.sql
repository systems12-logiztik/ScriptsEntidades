

SET ANSI_PADDING ON
GO

/****** Object:  Index [idx_GuiasHouseDetalles_idClienteFinal]    Script Date: 2/5/2026 4:28:22 PM ******/
CREATE NONCLUSTERED INDEX [idx_GuiasHouseDetalles_shipToId] ON [dbo].[GuiasHouseDetalles]
(
	[shipToId] ASC,
	[estadoPieza] ASC
)
INCLUDE([id],[idGuiaHouse],[codigoBarra],[fechaCambio],[scanDespacho]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


