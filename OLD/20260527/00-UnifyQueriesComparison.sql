DECLARE @UserType VARCHAR(16) = 'GRUPOCLIENTE';
DECLARE @EntityId VARCHAR(16) = 'CLI013680';

SELECT TOP 100 'OPCIÓN 1: CASE en ON' AS Method, GH.*, EID.[Name]
FROM GuiasHouse GH WITH(NOLOCK)
INNER JOIN dbo.f_GetClientsEntities(@UserType, @EntityId) EID 
	ON CASE 
		WHEN @UserType = 'BILLTO' THEN GH.BillToConsigneeId
		WHEN @UserType = 'CONSIGNEE' THEN GH.ConsigneeId
		WHEN @UserType IN ('CLIENTE', 'GRUPOCLIENTE') THEN GH.IDCliente
	END = EID.Id
GO

DECLARE @UserType VARCHAR(16) = 'GRUPOCLIENTE';
DECLARE @EntityId VARCHAR(16) = 'CLI013680';

SELECT TOP 100 'OPCIÓN 2: OR en WHERE' AS Method, GH.*, EID.[Name]
FROM GuiasHouse GH WITH(NOLOCK)
INNER JOIN dbo.f_GetClientsEntities(@UserType, @EntityId) EID 
	ON (GH.BillToConsigneeId = EID.Id AND @UserType = 'BILLTO')
	OR (GH.ConsigneeId = EID.Id AND @UserType = 'CONSIGNEE')
	OR (GH.IDCliente = EID.Id AND @UserType IN ('CLIENTE', 'GRUPOCLIENTE'))
GO

DECLARE @UserType VARCHAR(16) = 'GRUPOCLIENTE';
DECLARE @EntityId VARCHAR(16) = 'CLI013680';

SELECT TOP 100 'OPCIÓN 3: CASE SELECT' AS Method, GH.*, EID.[Name]
FROM GuiasHouse GH WITH(NOLOCK)
INNER JOIN dbo.f_GetClientsEntities(@UserType, @EntityId) EID ON 1=1
WHERE (
	(GH.BillToConsigneeId = EID.Id AND @UserType = 'BILLTO')
	OR (GH.ConsigneeId = EID.Id AND @UserType = 'CONSIGNEE')
	OR (GH.IDCliente = EID.Id AND @UserType IN ('CLIENTE', 'GRUPOCLIENTE'))
)
GO

DECLARE @UserType VARCHAR(16) = 'GRUPOCLIENTE';
DECLARE @EntityId VARCHAR(16) = 'CLI013680';

SELECT TOP 100 'OPCIÓN 4: COALESCE' AS Method, GH.*, EID.[Name]
FROM GuiasHouse GH WITH(NOLOCK)
INNER JOIN dbo.f_GetClientsEntities(@UserType, @EntityId) EID 
	ON COALESCE(
		CASE WHEN @UserType = 'BILLTO' THEN GH.BillToConsigneeId END,
		CASE WHEN @UserType = 'CONSIGNEE' THEN GH.ConsigneeId END,
		CASE WHEN @UserType IN ('CLIENTE', 'GRUPOCLIENTE') THEN GH.IDCliente END
	) = EID.Id
GO


