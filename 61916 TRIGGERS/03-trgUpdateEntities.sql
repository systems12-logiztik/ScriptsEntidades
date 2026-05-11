
/*
VERSION		MODIFIEDBY		MODIFIEDDATE	HU			MODIFICATION
1			Luis Campos		2025-10-31		AC 55188	Initial Code: Actualizar datos en Clientes cuando se actualiza Entities
2			Luis Campos		2026-03-20		AC 55188	Merged trg_EntityTypes_UpdateEntityRelationsAlias logic - sync Entities changes to both Clientes and EntityRelations.Alias
3			Luis Campos		2026-03-24		AC 55188	Unified with 03-trg_Entities_SyncEntityRelationsAlias - applied standards, error handling, SELECT assignments
*/
CREATE OR ALTER TRIGGER [dbo].[trg_UpdateEntities]
ON [dbo].[Entities]
AFTER UPDATE
NOT FOR REPLICATION
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Si es una actualización masiva (más de un registro), salir del trigger
        IF (SELECT COUNT(*) FROM inserted) > 1
        BEGIN
            RETURN;
        END

        -- Solo ejecutar si se actualizaron las columnas relevantes
        IF NOT UPDATE([Name]) 
           AND NOT UPDATE(CountryId) 
           AND NOT UPDATE(SubdivisionId) 
           AND NOT UPDATE(CityId) 
           AND NOT UPDATE(Address1) 
           AND NOT UPDATE(PostalCode)
        BEGIN
            RETURN;
        END

        DECLARE @EntityId VARCHAR(32);
        
        -- Obtener EntityId desde la tabla inserted
        SELECT TOP 1 @EntityId = i.Id
        FROM inserted i;

        -- Actualizar el Alias en EntityRelations cuando cambia el nombre del Consignee
        UPDATE er
        SET 
            er.Alias = i.[Name],
            er.ModifiedDate = GETDATE()
        FROM [dbo].[EntityRelations] er WITH (NOLOCK)
        INNER JOIN [dbo].[EntityTypes] et WITH (NOLOCK) ON er.ChildEntityTypeId = et.Id
        INNER JOIN inserted i ON et.EntityId = i.Id
        INNER JOIN deleted d ON i.Id = d.Id
        WHERE i.[Name] <> d.[Name]
        AND er.SubType IN (1, 3)
        AND er.[Status] = 1;
    END TRY
    BEGIN CATCH
        EXEC [dbo].[pro_LogError]
    END CATCH
END
GO
