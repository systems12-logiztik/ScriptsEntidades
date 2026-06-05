/*
VERSION     MODIFIEDBY      	  MODIFIEDDATE    HU      MODIFICATION
1           Cristhian Cuichan     2026-03-25     67468   Create indexes for OrdenesLocales to optimize queries by BillToConsigneeId and ConsigneeId
*/

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_OrdenesLocales_ConsigneeId')
	BEGIN
		CREATE INDEX idx_OrdenesLocales_ConsigneeId ON dbo.OrdenesLocales 
		(
			ConsigneeId
		)
	END
GO



