/*
VERSION		MODIFIEDBY		MODIFIEDDATE	HU			MODIFICATION
1			Luis Campos		2025-10-31		AC 55188	Initial Code
*/
CREATE OR ALTER TRIGGER trg_UpdateEntityTypes
ON dbo.EntityTypes
AFTER UPDATE 
NOT FOR REPLICATION
AS
BEGIN
    -- Si es una actualización masiva (más de un registro), salir del trigger
    IF EXISTS (SELECT 1 FROM inserted HAVING COUNT(*) > 1)
    BEGIN
        RETURN;
    END
    
    -- Ejecutar solo si el Status es 0 o 1 y EntityType = 2 (Consignee)
    -- Y solo si la columna Metadata o Status fue actualizada
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON i.Id = d.Id
        WHERE i.EntityType = 2
        AND i.[Status] IN (0,1)
        AND 
        (
            i.Metadata <> d.Metadata
            OR i.[Status] <> d.[Status]
        )
    )
    BEGIN
        DECLARE @ReferenceId VARCHAR(16);

        SELECT @ReferenceId = et.ReferenceId
        FROM EntityTypes et
        INNER JOIN inserted i ON et.Id = i.Id;

        IF @ReferenceId IS NULL
        BEGIN
            DECLARE @IdRegistro VARCHAR(32);

            EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Clientes', @IdUnico = @IdRegistro OUTPUT;

            UPDATE et
            SET et.ReferenceId = @IdRegistro,
				et.ModifiedDate = GETDATE()
            FROM dbo.EntityTypes et
            INNER JOIN inserted i ON et.Id = i.Id
            WHERE et.ReferenceId IS NULL;

            INSERT INTO dbo.Clientes (
                id, idPais, idEstado, idCiudad, idEmpresa, nombre, alias, tipoCliente, direccion, codigozip, fechaCambio, idUsuarioLog, nota, [Status], email, telefono, identificacion, tipoIdentificacion
            )
            SELECT 
                @IdRegistro AS id,
                e.CountryId AS idPais,
                e.SubdivisionId AS idEstado,
                e.CityId AS idCiudad,
                NULL AS idEmpresa,
                e.[Name] AS nombre,
				e.[Name] AS alias,
                'CLIENTE' AS tipoCliente,
                e.Address1 AS direccion,
                e.PostalCode AS codigozip,
                GETDATE() AS fechaCambio,
                e.CreatedBy AS idUsuarioLog,
                'Registro creado desde v2' AS nota,
                CASE WHEN i.[Status] = 1 THEN 'ACTIVO' ELSE 'INACTIVO' END AS [Status],
                MAX(CASE WHEN md.identifier = 'EMAIL' THEN md.[value] END) AS email,
                MAX(CASE WHEN md.identifier = 'PHONE' THEN md.[value] END) AS telefono,
                COALESCE(
                    MAX(CASE WHEN md.identifier = 'EORI' THEN md.[value] END),
                    MAX(CASE WHEN md.identifier = 'IDENTIFICATIONCARD' THEN md.[value] END),
                    MAX(CASE WHEN md.identifier = 'PASSPORT' THEN md.[value] END),
                    MAX(CASE WHEN md.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN md.[value] END),
                    MAX(CASE WHEN md.identifier = 'IMPORTEROFRECORD' THEN md.[value] END)
                ) AS identificacion,
                COALESCE(
                    MAX(CASE WHEN md.identifier = 'EORI' THEN md.identifier END),
                    MAX(CASE WHEN md.identifier = 'IDENTIFICATIONCARD' THEN md.identifier END),
                    MAX(CASE WHEN md.identifier = 'PASSPORT' THEN md.identifier END),
                    MAX(CASE WHEN md.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN md.identifier END),
                    MAX(CASE WHEN md.identifier = 'IMPORTEROFRECORD' THEN md.identifier END)
                ) AS tipoIdentificacion
            FROM dbo.Entities e
            INNER JOIN inserted i ON e.Id = i.EntityId
            INNER JOIN dbo.EntityTypes et ON et.Id = i.Id
            OUTER APPLY OPENJSON(et.Metadata)
                WITH (
                    identifier VARCHAR(32),
                    [value] VARCHAR(128)
                ) md
            GROUP BY e.CountryId, e.SubdivisionId, e.CityId, e.[Name], e.Address1, e.PostalCode, e.CreatedDate, e.CreatedBy, i.[Status];
        END
        ELSE
        BEGIN            

            UPDATE c
            SET 
                c.email = d.email,
                c.telefono = d.telefono,
                c.identificacion = d.identificacion,
                c.tipoIdentificacion = d.tipoIdentificacion,
                c.[Status] = CASE WHEN d.[Status] = 1 THEN 'ACTIVO' ELSE 'INACTIVO' END,
                c.fechaCambio = GETDATE(),
                c.idUsuarioLog = d.ModifiedBy
            FROM dbo.Clientes c
            INNER JOIN (
                SELECT 
                    @ReferenceId AS id,
                    MAX(CASE WHEN md.identifier = 'EMAIL' THEN md.[value] END) AS email,
                    MAX(CASE WHEN md.identifier = 'PHONE' THEN md.[value] END) AS telefono,
                    COALESCE(
                        MAX(CASE WHEN md.identifier = 'EORI' THEN md.[value] END),
                        MAX(CASE WHEN md.identifier = 'IDENTIFICATIONCARD' THEN md.[value] END),
                        MAX(CASE WHEN md.identifier = 'PASSPORT' THEN md.[value] END),
                        MAX(CASE WHEN md.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN md.[value] END),
                        MAX(CASE WHEN md.identifier = 'IMPORTEROFRECORD' THEN md.[value] END)
                    ) AS identificacion,
                    COALESCE(
                        MAX(CASE WHEN md.identifier = 'EORI' THEN md.identifier END),
                        MAX(CASE WHEN md.identifier = 'IDENTIFICATIONCARD' THEN md.identifier END),
                        MAX(CASE WHEN md.identifier = 'PASSPORT' THEN md.identifier END),
                        MAX(CASE WHEN md.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN md.identifier END),
                        MAX(CASE WHEN md.identifier = 'IMPORTEROFRECORD' THEN md.identifier END)
                    ) AS tipoIdentificacion,
                    MAX(i.[Status]) AS [Status],
                    MAX(i.ModifiedBy) AS ModifiedBy
                FROM inserted i
                INNER JOIN dbo.EntityTypes et ON et.Id = i.Id
                OUTER APPLY OPENJSON(et.Metadata)
                    WITH (
                        identifier VARCHAR(32),
                        [value] VARCHAR(128)
                    ) AS md
                WHERE et.ReferenceId = @ReferenceId
            ) d ON c.id = d.id;
        END
    END
END
GO
