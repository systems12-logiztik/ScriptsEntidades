/*
VERSION     MODIFIEDBY      MODIFIEDDATE    HU      MODIFICATION
5           Luis Campos     2026-03-25      55188   Apply optimizations: remove DISTINCT, use NOT EXISTS, add OPTION RECOMPILE
*/


CREATE OR ALTER FUNCTION dbo.f_SearchEntities
(
    @SearchTerm VARCHAR(256),
    @SearchType VARCHAR(16)
)
RETURNS @Results TABLE (
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
    -- Validar parámetros de entrada
    IF @SearchType IS NULL OR @SearchType = ''
        RETURN;

    -- Si no hay término de búsqueda, retornar todos los registros según el tipo
    IF @SearchTerm IS NULL OR @SearchTerm = ''
    BEGIN
        IF @SearchType IN ('IdBillTo', 'BillTo')
        BEGIN
            INSERT INTO @Results
            SELECT 
                ER.Id,
                ER.ReferenceId AS IdCliente,
                ER.Id AS BillToConsigneeId,
                ER.EntityTypeId AS BillToId,
                ER.ChildEntityTypeId AS ConsigneeId,
                EN.[Name] AS BillToName,
                ER.Alias AS [Name]
            FROM EntityRelations ER WITH (NOLOCK)
            INNER JOIN EntityTypes ET WITH (NOLOCK) ON ET.Id = ER.EntityTypeId
            INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
            WHERE ET.[Status] IN (1, 3)
            AND ET.EntityType = 1
            AND ER.[Status] = 1;
            RETURN;
        END

        IF @SearchType IN ('Consignee', 'ShipTo')
        BEGIN
            INSERT INTO @Results
            SELECT 
                ET.Id,
                ET.ReferenceId AS IdCliente,
                NULL AS BillToConsignee,
                NULL AS BillToId,
                ET.Id AS ConsigneeId,
                NULL AS BillToName,
                EN.[Name] AS [Name]
            FROM EntityTypes ET WITH (NOLOCK)
            INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
            WHERE ET.[Status] IN (1, 3)
            AND ET.EntityType = 2;
            RETURN;
        END
    END

    DECLARE @SearchPattern VARCHAR(258) = '%' + @SearchTerm + '%';

    IF @SearchType = 'IdBillTo'
    BEGIN
        INSERT INTO @Results
        SELECT 
            ER.Id,
            ER.ReferenceId AS IdCliente,
            ER.Id AS BillToConsigneeId,
            ER.EntityTypeId AS BillToId,
            ER.ChildEntityTypeId AS ConsigneeId,
            EN.[Name] AS BillToName,
            ER.Alias AS [Name]
        FROM EntityRelations ER WITH (NOLOCK)
        INNER JOIN EntityTypes ET WITH (NOLOCK) ON ET.Id = ER.EntityTypeId
        INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
        WHERE ET.[Status] IN (1, 3)
        AND ET.EntityType = 1
        AND ER.[Status] = 1
        AND ER.EntityTypeId IN (SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@SearchTerm, ','));
        RETURN;
    END

    IF @SearchType = 'IdConsignee'
    BEGIN
        INSERT INTO @Results
        SELECT 
            ET.Id,
            ET.ReferenceId AS IdCliente,
            NULL AS BillToConsignee,
            NULL AS BillToId,
            ET.Id AS ConsigneeId,
            NULL AS BillToName,
            EN.[Name] AS [Name]
        FROM EntityTypes ET WITH (NOLOCK)
        INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
        WHERE ET.[Status] IN (1, 3)
        AND ET.EntityType = 2
        AND ET.Id IN (SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@SearchTerm, ','));
        RETURN;
    END

    IF @SearchType = 'BillTo'
    BEGIN
        INSERT INTO @Results
        SELECT 
            ER.Id,
            ER.ReferenceId AS IdCliente,
            ER.Id AS BillToConsigneeId,
            ER.EntityTypeId AS BillToId,
            ER.ChildEntityTypeId AS ConsigneeId,
            EN.[Name] AS BillToName,
            ER.Alias AS [Name]
        FROM EntityRelations ER WITH (NOLOCK)
        INNER JOIN EntityTypes ET WITH (NOLOCK) ON ET.Id = ER.EntityTypeId
        INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
        WHERE ET.[Status] IN (1, 3)
        AND ET.EntityType = 1
        AND ER.[Status] = 1
        AND EN.[Name] LIKE @SearchPattern
        OPTION (RECOMPILE);
        RETURN;
    END

    IF @SearchType = 'Consignee'
    BEGIN
        -- Buscar en EntityRelations.Alias solo para Consignee
        INSERT INTO @Results
        SELECT 
            ER.ChildEntityTypeId,
            ER.ReferenceId AS IdCliente,
            ER.Id AS BillToConsigneeId,
            ER.EntityTypeId AS BillToId,
            ER.ChildEntityTypeId AS ConsigneeId,
            EN.[Name] AS BillToName,
            ER.Alias AS [Name]
        FROM EntityRelations ER WITH (NOLOCK)
        INNER JOIN EntityTypes ET WITH (NOLOCK) ON ET.Id = ER.EntityTypeId
        INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
        WHERE ER.[Status] = 1
        AND ER.Alias LIKE @SearchPattern
        OPTION (RECOMPILE);
    END

    IF @SearchType IN ('Consignee', 'ShipTo')
    BEGIN
        -- Buscar en EntityTypes.Name para ambos (usar NOT EXISTS para mejor performance)
        INSERT INTO @Results
        SELECT 
            ET.Id,
            ET.ReferenceId AS IdCliente,
            NULL AS BillToConsignee,
            NULL AS BillToId,
            ET.Id AS ConsigneeId,
            NULL AS BillToName,
            EN.[Name] AS [Name]
        FROM EntityTypes ET WITH (NOLOCK)
        INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
        WHERE ET.[Status] IN (1, 3)
        AND ET.EntityType = 2
        AND EN.[Name] LIKE @SearchPattern
        AND NOT EXISTS (SELECT 1 FROM @Results r WHERE r.Id = ET.Id)
        OPTION (RECOMPILE);
        RETURN;
    END

    RETURN;
END
GO
