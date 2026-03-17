SET ANSI_PADDING ON
GO

/****** Object:  Index [idx_GuiasHouseDetalles_idGuiaHouseIdCliente]    Script Date: 2/5/2026 5:35:33 PM ******/
CREATE NONCLUSTERED INDEX [idx_GuiasHouseDetalles_idGuiaHouseShipToId] ON [dbo].[GuiasHouseDetalles]
(
	[idGuiaHouse] ASC,
	[shipToId] ASC
)
INCLUDE([id],[codigoBarra],[fechaRecepcion],[estadoPieza],[station]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


