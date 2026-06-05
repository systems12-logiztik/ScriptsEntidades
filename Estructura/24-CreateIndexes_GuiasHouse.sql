/*
VERSION     MODIFIEDBY      	MODIFIEDDATE    HU      MODIFICATION
1           Fernando OrdoÃ±ez     2026-02-27     67468   Optimized indexes for GuiasHouse
*/

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_GuiasHouse_BilltoConsigneeId_ConsigneeId')
	BEGIN
		CREATE NONCLUSTERED INDEX [idx_GuiasHouse_BilltoConsigneeId_ConsigneeId] ON [dbo].[GuiasHouse]
		(
			[BilltoConsigneeId] ASC,
			[ConsigneeId] ASC
		)
	END
GO

