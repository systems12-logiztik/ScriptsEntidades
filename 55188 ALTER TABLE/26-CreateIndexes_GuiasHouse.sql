/*
VERSION     MODIFIEDBY      	MODIFIEDDATE    HU      MODIFICATION
1           Fernando Ordoñez     2026-02-27     55188   Optimized indexes for GuiasHouse
*/

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_GuiasHouse_BilltoConsigneeId_ConsigneeId')
	BEGIN
		CREATE NONCLUSTERED INDEX [idx_GuiasHouse_BilltoConsigneeId_ConsigneeId] ON [dbo].[GuiasHouse]
		(
			[BilltoConsigneeId] ASC,
			[ConsigneeId] ASC
		)
		INCLUDE([id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 50, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	END
GO