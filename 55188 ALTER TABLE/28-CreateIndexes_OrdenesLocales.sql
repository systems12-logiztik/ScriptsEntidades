/*
VERSION     MODIFIEDBY      	  MODIFIEDDATE    HU      MODIFICATION
1           Cristhian Cuichan     2026-03-25     55188   Create indexes for OrdenesLocales to optimize queries by BillToConsigneeId and ConsigneeId
*/


IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_OrdenesLocales_BillToConsigneeId')
	BEGIN
		CREATE INDEX idx_OrdenesLocales_BillToConsigneeId ON dbo.OrdenesLocales 
		(
			BillToConsigneeId
		)
		INCLUDE (id, nroOrden, fechaEntrega, idEmpresa, idCatalogoStatus)
		WHERE BillToConsigneeId IS NOT NULL;
	END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_OrdenesLocales_ConsigneeId')
	BEGIN
		CREATE INDEX idx_OrdenesLocales_ConsigneeId ON dbo.OrdenesLocales 
		(
			ConsigneeId
		)
		INCLUDE (id, nroOrden, fechaEntrega, idEmpresa, idCatalogoStatus)
		WHERE ConsigneeId IS NOT NULL;
	END
GO

