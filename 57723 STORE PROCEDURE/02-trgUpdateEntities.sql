
/*
VERSION		MODIFIEDBY		MODIFIEDDATE	HU			MODIFICATION
1			Luis Campos		2025-10-31		AC 55188	Initial Code: Actualizar datos en Clientes cuando se actualiza Entities
*/
CREATE OR ALTER TRIGGER trg_UpdateEntities
ON dbo.Entities
AFTER UPDATE
NOT FOR REPLICATION
AS
BEGIN
    -- Si es una actualización masiva (más de un registro), salir del trigger
    IF EXISTS (SELECT 1 FROM inserted HAVING COUNT(*) > 1)
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

    -- Obtener ReferenceId relacionado a la entidad actualizada (si existe)
    DECLARE @ReferenceId VARCHAR(16);

    SELECT TOP 1 @ReferenceId = et.ReferenceId
    FROM dbo.EntityTypes et
    INNER JOIN inserted i ON et.EntityId = i.Id
    WHERE et.EntityType = 2
    AND et.Status IN (0,1);

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
        FROM dbo.Clientes c
        INNER JOIN inserted i ON c.Id = @ReferenceId;
    END
END
GO
