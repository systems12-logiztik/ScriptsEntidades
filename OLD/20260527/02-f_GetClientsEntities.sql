/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION
1		    Luis Campos			2026-03-02	    55390	Initial Code - Reusable entity resolver (V1/V2)
*/

CREATE OR ALTER FUNCTION dbo.f_GetClientsEntities
(
    @UserType VARCHAR(32),
    @EntityId VARCHAR(16)
)
RETURNS @Result TABLE
(
    Id VARCHAR(16),
    IdCliente VARCHAR(16),
    BillToConsigneeId VARCHAR(16),
    BillToId VARCHAR(16),
    ConsigneeId VARCHAR(16),
    BillToName VARCHAR(256),
    [Name] VARCHAR(256)
)
AS
BEGIN

    IF (@EntityId IS NULL OR @EntityId = '')
       OR (@UserType NOT IN ('CONSIGNEE','BILLTO','CLIENTE','GRUPOCLIENTE'))
    BEGIN
        INSERT INTO @Result
        VALUES (NULL,NULL,NULL,NULL,NULL,NULL,NULL)

        RETURN
    END

    IF @UserType = 'CONSIGNEE'
    BEGIN

        INSERT INTO @Result
        SELECT
            ER.ChildEntityTypeId,
            ER.ReferenceId,
            ER.Id,
            ER.EntityTypeId,
            ER.ChildEntityTypeId,
            EN.[Name],
            ER.Alias
        FROM EntityRelations ER WITH (NOLOCK)
        INNER JOIN EntityTypes ET WITH (NOLOCK) ON ET.Id = ER.EntityTypeId
        INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
        WHERE ET.[Status] IN (1,3)
            AND ER.[Status] = 1
            AND ER.SubType = 1
            AND ER.ChildEntityTypeId = @EntityId

        IF NOT EXISTS (SELECT 1 FROM @Result)
        BEGIN
            INSERT INTO @Result
            SELECT
                ET.Id,
                NULL,
                NULL,
                NULL,
                ET.Id,
                EN.[Name],
                EN.[Name]
            FROM EntityTypes ET WITH (NOLOCK)
            INNER JOIN Entities EN WITH (NOLOCK)
                ON EN.Id = ET.EntityId
            WHERE ET.Id = @EntityId
                AND ET.EntityType = 2
                AND ET.[Status] IN (1,3)
                AND NOT EXISTS
                (
                    SELECT 1
                    FROM EntityRelations ER WITH (NOLOCK)
                    WHERE ER.ChildEntityTypeId = ET.Id
                        AND ER.[Status] = 1
                        AND ER.SubType = 1
                )
        END
    END

    ELSE IF @UserType = 'BILLTO'
    BEGIN
        INSERT INTO @Result
        SELECT 
			Id, 
			IdCliente,
			BillToConsigneeId,
			BillToId, 
			ConsigneeId, 
			BillToName, 
			[Name] 
        FROM dbo.f_SearchEntities(@EntityId, 'IdBillTo')
    END

    ELSE IF @UserType = 'CLIENTE'
    BEGIN
        INSERT INTO @Result
        SELECT
            C.id,
            C.id,
            FSE.BillToConsigneeId,
            FSE.BillToId,
            FSE.ConsigneeId,
            FSE.BillToName,
            FSE.[Name]
        FROM Clientes C WITH (NOLOCK)
        LEFT JOIN dbo.f_SearchEntities('', 'BillTo') FSE ON C.id = FSE.IdCliente
        WHERE C.id = @EntityId
    END

    ELSE IF @UserType = 'GRUPOCLIENTE'
    BEGIN
        INSERT INTO @Result
        SELECT
            GC.IdCliente,
            GC.IdCliente,
            FSE.BillToConsigneeId,
            FSE.BillToId,
            FSE.ConsigneeId,
            FSE.BillToName,
            FSE.[Name]
        FROM GrupoClientes GC WITH (NOLOCK)
        LEFT JOIN dbo.f_SearchEntities('', 'BillTo') FSE ON GC.IdCliente = FSE.IdCliente
        WHERE GC.IdGrupoCliente = @EntityId
		AND 1=1
    END

    RETURN
END
/*
-- Example 1: CLIENTE
SELECT * FROM dbo.f_GetClientsEntities('CLIENTE', 'CLI0122266')

-- Example 2: GRUPOCLIENTE
SELECT  * FROM dbo.f_GetClientsEntities('GRUPOCLIENTE', 'CLI013680')

-- Example 3: CONSIGNEE
SELECT * FROM dbo.f_GetClientsEntities('CONSIGNEE', 'ETY01556')

-- Example 4: BILLTO
SELECT  * FROM dbo.f_GetClientsEntities('BILLTO', 'ETY01272')

-- Example 5: With additional filters
SELECT GH.*
FROM dbo.f_GetClientsEntities('CLIENTE', 'CLI0122266') GH

-- Example 1: Single Client lookup
SELECT * FROM dbo.f_GetClientsEntities('CLIENTE', 'CLI012985')

-- Example 2: Group Client lookup
SELECT * FROM dbo.f_GetClientsEntities('GRUPOCLIENTE', 'CLI013680')

-- Example 3: CONSIGNEE lookup
SELECT * FROM dbo.f_GetClientsEntities('CONSIGNEE', 'ETY011990')

-- Example 4: BILLTO lookup
SELECT * FROM dbo.f_GetClientsEntities('BILLTO', 'ETY011')
SELECT * FROM dbo.f_GetClientsEntities('BILLTO', 'ETY01')
*/
