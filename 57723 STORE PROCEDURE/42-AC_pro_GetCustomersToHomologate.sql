/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			Edwin Casa			2026-04-14		58802		Initial Code - Get Guias - GuiasHouse - GuiasHouseDetalles of homologate process

*/
CREATE OR ALTER PROCEDURE [dbo].[AC_pro_GetCustomersToHomologate] 
(
	@idGuia VARCHAR(16)
)
AS
BEGIN
	SELECT 
		@idGuia AS Id,
		G.idcliente AS OriginConsigneeId,
		(COALESCE(CL.NombreClienteFinal, CL.Nombre) + ' - ' + G.IdCliente) AS OriginConsigneeName,
		G.BillToConsigneeId AS BillToId,
		VC.BillToName,
		VC.ConsigneeId AS ConsigneeId,
		VC.Nombre AS ConsigneeName
	FROM Guias G
	INNER JOIN Clientes CL ON G.IdCliente = CL.Id
	LEFT JOIN v_ClientsEntities VC ON G.BillToConsigneeId =  VC.Id
	WHERE ISNULL(G.idGuiaConsolidada, G.id) = @idGuia
		AND G.BillToConsigneeId IS NULL
	UNION
	SELECT 
		@idGuia AS Id,
		GH.idcliente AS OriginConsigneeId,
		(COALESCE(CL.NombreClienteFinal, CL.Nombre) + ' - ' + GH.IdCliente) AS OriginConsigneeName,
		GH.BillToConsigneeId AS BillToId,
		VC.BillToName,
		GH.ConsigneeId AS ConsigneeId,
		VC.Nombre AS ConsigneeName
	FROM GuiasHouse GH
	INNER JOIN Clientes CL  ON GH.IdCliente = CL.Id
	LEFT JOIN v_ClientsEntities VC ON ISNULL(GH.BilltoConsigneeId, GH.ConsigneeId) = VC.Id
	WHERE 
		GH.IdGuia = @idGuia
		AND GH.house IS NULL
		AND GH.ConsigneeId IS NULL
	UNION
	SELECT 
		@idGuia AS Id,
		GH.idcliente AS OriginConsigneeId,
		(COALESCE(CL.NombreClienteFinal, CL.Nombre) + ' - ' + GH.IdCliente) AS OriginConsigneeName,
		GH.BillToConsigneeId AS BillToId,
		VC.BillToName,
		GH.ConsigneeId AS ConsigneeId,
		VC.Nombre AS ConsigneeName
	FROM GuiasHouse GH
	INNER JOIN Clientes CL  ON GH.IdCliente = CL.Id
	LEFT JOIN v_ClientsEntities VC ON ISNULL(GH.BilltoConsigneeId, GH.ConsigneeId) = VC.Id
	WHERE 
		GH.IdGuia = @idGuia
		AND GH.house IS NOT NULL
		AND GH.BilltoConsigneeId IS NULL
	UNION
	SELECT 
		@idGuia AS Id,
		GHD.idClienteFinal AS OriginConsigneeId,
		(COALESCE(CL.NombreClienteFinal, CL.Nombre) + ' - ' + GHD.idClienteFinal) AS OriginConsigneeName,
		GHD.BillToConsigneeId AS BillToId,
		VC.BillToName,
		VC.ConsigneeId AS ConsigneeId,
		VC.Nombre AS ConsigneeName
	FROM GuiasHouse GH
	INNER JOIN GuiasHouseDetalles GHD on GHD.idGuiaHouse =GH.id
	INNER JOIN Clientes CL  ON GHD.idClienteFinal = CL.Id
	LEFT JOIN v_ClientsEntities VC ON GHD.BilltoConsigneeId = VC.Id
	WHERE 
		GH.IdGuia = @idGuia
		AND CASE 
			WHEN GHD.BilltoConsigneeId IS NOT NULL 
				AND GHD.ShipToId IS NOT NULL 
			THEN 0
			ELSE 1
		END = 1
END

/*

exec [dbo].[AC_pro_GetCustomersToHomologate]  'GUI072159699'

exec [dbo].[AC_pro_GetCustomersToHomologate]  'GUI072159668'

exec [dbo].[AC_pro_GetCustomersToHomologate]  'GUI012154230'

exec [dbo].[AC_pro_GetCustomersToHomologate]  'GUI072159683'

exec [dbo].[AC_pro_GetCustomersToHomologate]  'GUI072159673'

exec [dbo].[AC_pro_GetCustomersToHomologate]  'GUI012182424'

exec [dbo].[AC_pro_GetCustomersToHomologate]  'GUI012181802'


exec [dbo].[AC_pro_GetCustomersToHomologate]  'GUI072191020'


exec [dbo].[AC_pro_GetCustomersToHomologate]  'GUI012190731'


exec [dbo].[AC_pro_GetCustomersToHomologate]  'GUI012190699'

*/