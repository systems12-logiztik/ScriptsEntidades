SELECT TOP 100 'OPCIÓN 1: COALESCE directo' AS Method, GH.*, VCE.nombre
FROM GuiasHouse GH WITH(NOLOCK)
INNER JOIN dbo.v_ClientsEntitiesUnified VCE ON 
	COALESCE(GH.BillToConsigneeId, GH.ConsigneeId, GH.IDCliente) = 
	VCE.Id
GO

SELECT TOP 100 'OPCIÓN 2: CASE en ON' AS Method, GH.*, VCE.nombre
FROM GuiasHouse GH WITH(NOLOCK)
INNER JOIN dbo.v_ClientsEntitiesUnified VCE 
	ON CASE
		WHEN GH.BillToConsigneeId IS NOT NULL THEN GH.BillToConsigneeId
		WHEN GH.ConsigneeId IS NOT NULL THEN GH.ConsigneeId
		ELSE GH.IDCliente
	END = VCE.Id
GO

SELECT TOP 100 'OPCIÓN 3: CROSS APPLY' AS Method, GH.*, VCE.nombre
FROM GuiasHouse GH WITH(NOLOCK)
OUTER APPLY (
	SELECT COALESCE(GH.BillToConsigneeId, GH.ConsigneeId, GH.IDCliente) AS JoinId
) GHX
INNER JOIN dbo.v_ClientsEntitiesUnified VCE ON 
	GHX.JoinId = VCE.Id
GO

SELECT TOP 100 'OPCIÓN 4: UNION ALL por prioridad' AS Method, R.*, R.nombre
FROM (
	SELECT GH.*, VCE.nombre
	FROM GuiasHouse GH WITH(NOLOCK)
	INNER JOIN dbo.v_ClientsEntitiesUnified VCE ON GH.BillToConsigneeId = VCE.Id
	WHERE GH.BillToConsigneeId IS NOT NULL

	UNION ALL

	SELECT GH.*, VCE.nombre
	FROM GuiasHouse GH WITH(NOLOCK)
	INNER JOIN dbo.v_ClientsEntitiesUnified VCE ON GH.ConsigneeId = VCE.Id
	WHERE GH.BillToConsigneeId IS NULL
	AND GH.ConsigneeId IS NOT NULL

	UNION ALL

	SELECT GH.*, VCE.nombre
	FROM GuiasHouse GH WITH(NOLOCK)
	INNER JOIN dbo.v_ClientsEntitiesUnified VCE ON GH.IDCliente = VCE.Id
	WHERE GH.BillToConsigneeId IS NULL
	AND GH.ConsigneeId IS NULL
) R
GO
