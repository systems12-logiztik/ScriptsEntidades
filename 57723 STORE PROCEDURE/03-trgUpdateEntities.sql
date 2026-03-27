
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

        DECLARE @EntityId VARCHAR(32),
                @ReferenceId VARCHAR(16),
                @ErrorMessage NVARCHAR(MAX),
                @ErrorSeverity INT;
        
        -- Obtener EntityId desde la tabla inserted
        SELECT TOP 1 @EntityId = i.Id
        FROM inserted i;

        -- LÓGICA 1: Actualizar datos en Clientes cuando se actualiza Entities
        -- Obtener ReferenceId relacionado a la entidad actualizada (si existe)
        SELECT TOP 1 @ReferenceId = et.ReferenceId
        FROM [dbo].[EntityTypes] et WITH (NOLOCK)
        INNER JOIN inserted i ON et.EntityId = i.Id
        WHERE et.EntityType = 2
        AND et.[Status] IN (0, 1);

        -- Solo actualizar Clientes si ReferenceId no es NULL
        IF @ReferenceId IS NOT NULL
        BEGIN
            -- Actualizar los datos principales del cliente con los valores de la entidad actualizada
            UPDATE c
            SET
                c.nombre = i.[Name],
                c.alias = i.[Name],
                c.idPais = i.CountryId,
                c.idEstado = i.SubdivisionId,
                c.idCiudad = i.CityId,
                c.tipoCliente = 'CLIENTE',
                c.direccion = i.Address1,
                c.codigozip = i.PostalCode,
                c.fechaCambio = GETDATE(),
                c.idUsuarioLog = i.ModifiedBy
            FROM [dbo].[Clientes] c
            INNER JOIN inserted i ON c.id = @ReferenceId;
        END

        -- LÓGICA 2: Actualizar el Alias en EntityRelations cuando cambia el nombre del Consignee
        -- Esto mantiene la consistencia entre Entities/EntityTypes y EntityRelations
        -- Aplica solo a relaciones de tipo Propia (1) y Ship-To (3)
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
        -- Los triggers no pueden escribir en tablas dentro de transacciones
        -- Solo registrar via RAISERROR para que aparezca en el cliente
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY();
        RAISERROR(@ErrorMessage, @ErrorSeverity, 1) WITH NOWAIT;
    END CATCH
END
GO
