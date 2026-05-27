/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			Edwin Casa			2026-04-14		58802		Get entities of a specific hawb without homologate
*/
CREATE OR ALTER FUNCTION [dbo].[f_GetHawbEntitiesNotHomologated] 
(
	@idGuia VARCHAR(16)
)
RETURNS  TABLE
AS
RETURN
(
	SELECT 
		ER.Id,
		ER.ReferenceId
	FROM Guias G
		INNER JOIN EntityRelations ER ON ER.ReferenceId = G.idCliente
	WHERE ISNULL(G.idGuiaConsolidada, G.id) = @idGuia
		AND CASE 
			WHEN G.BillToConsigneeId IS NOT NULL AND  G.BillToConsigneeId = ER.Id
			THEN  0
			ELSE 1  END  = 1
)
/*
	SELECT * FROM dbo.f_GetHawbEntitiesNotHomologated('GUI012167106')

	SELECT * FROM dbo.f_GetHawbEntitiesNotHomologated('GUI012182424')

	SELECT * FROM dbo.f_GetHawbEntitiesNotHomologated('GUI012181802')

	SELECT * FROM dbo.f_GetHawbEntitiesNotHomologated('GUI012190699')

	SELECT * FROM dbo.f_GetHawbEntitiesNotHomologated('GUI072191020')

	SELECT * FROM dbo.f_GetHawbEntitiesNotHomologated('GUI012190731')

	SELECT * FROM dbo.f_GetHawbEntitiesNotHomologated('GUI012127329')

	
*/