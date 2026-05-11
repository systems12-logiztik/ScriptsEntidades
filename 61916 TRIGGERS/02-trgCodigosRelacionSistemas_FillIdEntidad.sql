/*
VERSION		MODIFIEDBY		MODIFIEDDATE	HU			MODIFICATION
1			Luis Campos		2026-05-06		AC 55188	Fill IdEntidad from EntityRelations ReferenceId
*/

CREATE OR ALTER TRIGGER [dbo].[trg_CodigosRelacionSistemas_FillIdEntidad]
ON [dbo].[CodigosRelacionSistemas]
AFTER INSERT
NOT FOR REPLICATION
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Actualizar IdEntidad con el ReferenceId de la relación correspondiente
        UPDATE crs
        SET crs.IdEntidad = er.ReferenceId
        FROM [dbo].[CodigosRelacionSistemas] crs WITH (NOLOCK)
        INNER JOIN inserted i ON crs.Id = i.Id
        INNER JOIN [dbo].[EntityRelations] er WITH (NOLOCK) ON er.Id = i.EntityRelationId
        WHERE crs.IdEntidad IS NULL
            AND er.ReferenceId IS NOT NULL
            AND crs.tipoEntidad = 'BILLTOCONSIGNEE';
    END TRY
    BEGIN CATCH
        EXEC [dbo].[pro_LogError]
    END CATCH
END
GO