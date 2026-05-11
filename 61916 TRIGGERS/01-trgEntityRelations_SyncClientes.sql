/*
VERSION		MODIFIEDBY		MODIFIEDDATE	HU			MODIFICATION
1			Luis Campos		2026-05-06		AC 55188	Initial - Sync EntityRelations to Clientes with three subtypes
2			Luis Campos		2026-05-06		AC 55188	Fix errors, add validations, proper error handling with THROW
*/

CREATE OR ALTER TRIGGER [dbo].[trg_EntityRelations_SyncClientes]
ON [dbo].[EntityRelations]
AFTER INSERT
NOT FOR REPLICATION
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validar que sea un solo registro
        IF (SELECT COUNT(*) FROM inserted) > 1
            RETURN;

        -- DECLARACIÓN DE VARIABLES - INICIALIZADAS
        DECLARE @RelationId VARCHAR(32),
                @ReferenceId VARCHAR(16),
                @EntityTypeId VARCHAR(32),
                @ChildEntityTypeId VARCHAR(32),
                @SubType INT,
                @Alias VARCHAR(512),
                @Status INT,
                @CreatedBy VARCHAR(128),
                @BillToName VARCHAR(512),
                @PropriaConsigneeEmail VARCHAR(128) = NULL,
                @PropriaConsigneePhone VARCHAR(128) = NULL,
                @BillToReferenceId VARCHAR(16) = NULL,
                @ConsigneeEmail VARCHAR(128) = NULL,
                @ConsigneePhone VARCHAR(128) = NULL,
                @ConsigneeIdent VARCHAR(128) = NULL,
                @ConsigneeIdentType VARCHAR(32) = NULL,
                @ConsigneeCountryId VARCHAR(32),
                @ConsigneeSubdivisionId VARCHAR(32),
                @ConsigneeCityId VARCHAR(32),
                @ConsigneeName VARCHAR(512),
                @ConsigneeAddress VARCHAR(512),
                @ConsigneePostalCode VARCHAR(32),
                @ConsigneeCreatedBy VARCHAR(128) = NULL,
                @ConsigneeClienteId VARCHAR(16) = NULL,
                @BillToEmail VARCHAR(128) = NULL,
                @BillToPhone VARCHAR(128) = NULL,
                @BillToIdent VARCHAR(128) = NULL,
                @BillToIdentType VARCHAR(32) = NULL,
                @BillToCountryId VARCHAR(32),
                @BillToSubdivisionId VARCHAR(32),
                @BillToCityId VARCHAR(32),
                @BillToAddress VARCHAR(512),
                @BillToPostalCode VARCHAR(32),
                @BillToCreatedBy VARCHAR(128) = NULL,
                @idCatalogo UNIQUEIDENTIFIER = NULL;

        -- OBTENER DATOS DEL REGISTRO INSERTADO
        SELECT TOP 1
            @RelationId = Id, 
            @ReferenceId = ReferenceId, 
            @EntityTypeId = EntityTypeId,
            @ChildEntityTypeId = ChildEntityTypeId, 
            @SubType = SubType, 
            @Alias = Alias,
            @Status = [Status], 
            @CreatedBy = CreatedBy
        FROM inserted
        WHERE [Status] = 1;

        -- Si no hay relación activa, retornar
        IF @RelationId IS NULL 
            RETURN;

        -- OBTENER ID DEL CATÁLOGO
        SELECT @idCatalogo = id
        FROM [dbo].[Catalogos] WITH (NOLOCK)
        WHERE codigo = 'TipoEntidadA'
            AND nombre = 'CLIENTES';

        -- GENERAR ReferenceId si no existe
        IF @ReferenceId IS NULL
        BEGIN
            EXEC [dbo].[PRO_General_GenerarIdUnico] @tabla = 'Clientes', @IdUnico = @ReferenceId OUTPUT;
            
            IF @ReferenceId IS NULL
            BEGIN
                THROW 50001, 'No se pudo generar ReferenceId único', 1;
            END
            
            UPDATE [dbo].[EntityRelations] 
            SET ReferenceId = @ReferenceId 
            WHERE Id = @RelationId;
        END

        -- OBTENER NOMBRE DEL BILLTO
        SELECT @BillToName = e.[Name]
        FROM [dbo].[EntityTypes] et WITH (NOLOCK)
        INNER JOIN [dbo].[Entities] e WITH (NOLOCK) ON et.EntityId = e.Id
        WHERE et.Id = @EntityTypeId;

        -- OBTENER DATOS DE CONTACTO DEL CONSIGNEE PROPIO (para SubType 2)
        SELECT
            @PropriaConsigneeEmail = MAX(CASE WHEN md.identifier = 'EMAIL' THEN md.[value] END),
            @PropriaConsigneePhone = MAX(CASE WHEN md.identifier = 'PHONE' THEN md.[value] END)
        FROM [dbo].[EntityTypes] cet WITH (NOLOCK)
        OUTER APPLY OPENJSON(cet.Metadata) WITH (identifier VARCHAR(32), [value] VARCHAR(128)) AS md
        WHERE cet.Id = @ChildEntityTypeId;

        -- OBTENER BILLTO REFERENCE ANTERIOR
        SELECT TOP 1 
            @BillToReferenceId = er.ReferenceId
        FROM [dbo].[EntityRelations] er WITH (NOLOCK)
        WHERE er.EntityTypeId = @EntityTypeId 
            AND er.[Status] = 1 
            AND er.Id <> @RelationId
        ORDER BY er.CreatedDate DESC;

        -- ============================================================
        -- SUBTYPE 1 Y 3: RELACIÓN PROPIA Y SHIP-TO
        -- ============================================================
        IF @SubType IN (1, 3)
        BEGIN
            -- OBTENER DATOS DEL CONSIGNEE
            SELECT
                @ConsigneeEmail = MAX(CASE WHEN md.identifier = 'EMAIL' THEN md.[value] END),
                @ConsigneePhone = MAX(CASE WHEN md.identifier = 'PHONE' THEN md.[value] END),
                @ConsigneeIdent = ISNULL(
                    MAX(CASE WHEN md.identifier = 'EORI' THEN md.[value] END),
                    ISNULL(MAX(CASE WHEN md.identifier = 'IDENTIFICATIONCARD' THEN md.[value] END),
                    ISNULL(MAX(CASE WHEN md.identifier = 'PASSPORT' THEN md.[value] END),
                    ISNULL(MAX(CASE WHEN md.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN md.[value] END),
                    MAX(CASE WHEN md.identifier = 'IMPORTEROFRECORD' THEN md.[value] END))))),  
                @ConsigneeIdentType = CASE
                    WHEN MAX(CASE WHEN md.identifier = 'EORI' THEN 1 END) = 1 THEN 'EORI'
                    WHEN MAX(CASE WHEN md.identifier = 'IDENTIFICATIONCARD' THEN 1 END) = 1 THEN 'IDENTIFICATIONCARD'
                    WHEN MAX(CASE WHEN md.identifier = 'PASSPORT' THEN 1 END) = 1 THEN 'PASSPORT'
                    WHEN MAX(CASE WHEN md.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN 1 END) = 1 THEN 'FISCALIDENTIFICATIONNUMBER'
                    WHEN MAX(CASE WHEN md.identifier = 'IMPORTEROFRECORD' THEN 1 END) = 1 THEN 'IMPORTEROFRECORD' END,
                @ConsigneeCountryId = e.CountryId,
                @ConsigneeSubdivisionId = e.SubdivisionId,
                @ConsigneeCityId = e.CityId,
                @ConsigneeName = e.[Name],
                @ConsigneeAddress = e.Address1,
                @ConsigneePostalCode = e.PostalCode,
                @ConsigneeCreatedBy = e.CreatedBy
            FROM [dbo].[EntityTypes] cet WITH (NOLOCK)
            INNER JOIN [dbo].[Entities] e WITH (NOLOCK) ON cet.EntityId = e.Id
            OUTER APPLY OPENJSON(cet.Metadata) WITH (identifier VARCHAR(32), [value] VARCHAR(128)) AS md
            WHERE cet.Id = @ChildEntityTypeId
            GROUP BY e.CountryId, e.SubdivisionId, e.CityId, e.[Name], e.Address1, e.PostalCode, e.CreatedBy;

            -- Validar que se obtuvieron datos
            IF @ConsigneeName IS NULL
            BEGIN
                THROW 50002, 'No se pudieron obtener datos del Consignee', 1;
            END

            -- INSERTAR EN CLIENTES
            INSERT INTO [dbo].[Clientes] 
                (id, idPais, idEstado, idCiudad, idEmpresa, nombre, alias, 
                 tipoCliente, direccion, codigozip, fechaCambio, idUsuarioLog, nota, [Status], 
                 email, telefono, identificacion, tipoIdentificacion)
            VALUES (
                @ReferenceId,
                @ConsigneeCountryId,
                @ConsigneeSubdivisionId,
                @ConsigneeCityId,
                NULL,
                CASE WHEN @SubType = 3 THEN @BillToName + ' - ' + @ConsigneeName ELSE @ConsigneeName END,
                CASE WHEN @SubType = 3 THEN @BillToName + ' - ' + @ConsigneeName ELSE @ConsigneeName END,
                'CLIENTE',
                @ConsigneeAddress,
                @ConsigneePostalCode,
                GETDATE(),
                @ConsigneeCreatedBy,
                CASE WHEN @SubType = 1 THEN 'Relación Propia' ELSE 'Relación Ship-To' END,
                CASE WHEN @Status = 1 THEN 'ACTIVO' ELSE 'INACTIVO' END,
                @ConsigneeEmail,
                @ConsigneePhone,
                @ConsigneeIdent,
                @ConsigneeIdentType
            );

            IF @@ROWCOUNT = 0
            BEGIN
                THROW 50003, 'Error al insertar Cliente para SubType', 1;
            END

            -- INSERTAR EN DETALLEENTIDADES
            INSERT INTO [dbo].[DetalleEntidades]
                (id, idEntidad, idCatalogo, idUsuarioLog, [status], nota, fechaCambio)
            VALUES
                (NEWID(), @ReferenceId, @idCatalogo, @ConsigneeCreatedBy, 'ACTIVO',
                 CASE WHEN @SubType = 1 THEN 'Detalle de Relación Propia' ELSE 'Detalle de Relación Ship-To' END,
                 GETDATE());

            IF @@ROWCOUNT = 0
            BEGIN
                RAISERROR('Error al insertar DetalleEntidades para SubType %d', 10, 1, @SubType) WITH NOWAIT;
            END

            -- SUBTYPE 3: MANEJAR RELACIÓN CON CLIENTE FINAL
            IF @SubType = 3
            BEGIN
                SELECT TOP 1 
                    @ConsigneeClienteId = er.ReferenceId
                FROM [dbo].[EntityRelations] er WITH (NOLOCK)
                WHERE er.EntityTypeId = @EntityTypeId 
                    AND er.ChildEntityTypeId = @ChildEntityTypeId
                    AND er.SubType = 1 
                    AND er.[Status] = 1
                ORDER BY er.CreatedDate DESC;

                IF @ConsigneeClienteId IS NOT NULL
                BEGIN
                    -- Validar que no exista registro duplicado
                    IF NOT EXISTS (
                        SELECT 1 FROM [dbo].[ConsignatarioClientesFinal] WITH (NOLOCK)
                        WHERE idClienteFinal = @ReferenceId 
                            AND idConsignatario = @ConsigneeClienteId
                    )
                    BEGIN
                        INSERT INTO [dbo].[ConsignatarioClientesFinal]
                            (id, idClienteFinal, idConsignatario, [status], nota, idUsuarioLog, fechaCambio)
                        VALUES
                            (NEWID(), @ReferenceId, @ConsigneeClienteId, 'ACTIVO',
                             'Consignee de relacion Ship-To', @CreatedBy, GETDATE());
                        
                        IF @@ROWCOUNT = 0
                        BEGIN
                            RAISERROR('Error al insertar ConsignatarioClientesFinal', 11, 1);
                        END
                    END
                END
                ELSE
                BEGIN
                    RAISERROR('No se encontró Consignee Cliente Final (SubType 1) para ShipTo', 10, 1) WITH NOWAIT;
                END
            END
        END
        
        -- ============================================================
        -- SUBTYPE 2: RELACIÓN ALIAS
        -- ============================================================
        ELSE IF @SubType = 2
        BEGIN
            -- OBTENER DATOS DEL BILLTO (ALIAS)
            SELECT
                @BillToEmail = MAX(CASE WHEN md.identifier = 'EMAIL' THEN md.[value] END),
                @BillToPhone = MAX(CASE WHEN md.identifier = 'PHONE' THEN md.[value] END),
                @BillToIdent = ISNULL(
                    MAX(CASE WHEN md.identifier = 'EORI' THEN md.[value] END),
                    ISNULL(MAX(CASE WHEN md.identifier = 'IDENTIFICATIONCARD' THEN md.[value] END),
                    ISNULL(MAX(CASE WHEN md.identifier = 'PASSPORT' THEN md.[value] END),
                    ISNULL(MAX(CASE WHEN md.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN md.[value] END),
                    MAX(CASE WHEN md.identifier = 'IMPORTEROFRECORD' THEN md.[value] END))))),  
                @BillToIdentType = CASE
                    WHEN MAX(CASE WHEN md.identifier = 'EORI' THEN 1 END) = 1 THEN 'EORI'
                    WHEN MAX(CASE WHEN md.identifier = 'IDENTIFICATIONCARD' THEN 1 END) = 1 THEN 'IDENTIFICATIONCARD'
                    WHEN MAX(CASE WHEN md.identifier = 'PASSPORT' THEN 1 END) = 1 THEN 'PASSPORT'
                    WHEN MAX(CASE WHEN md.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN 1 END) = 1 THEN 'FISCALIDENTIFICATIONNUMBER'
                    WHEN MAX(CASE WHEN md.identifier = 'IMPORTEROFRECORD' THEN 1 END) = 1 THEN 'IMPORTEROFRECORD' END,
                @BillToCountryId = e.CountryId,
                @BillToSubdivisionId = e.SubdivisionId,
                @BillToCityId = e.CityId,
                @BillToAddress = e.Address1,
                @BillToPostalCode = e.PostalCode,
                @BillToCreatedBy = e.CreatedBy
            FROM [dbo].[EntityTypes] bet WITH (NOLOCK)
            INNER JOIN [dbo].[Entities] e WITH (NOLOCK) ON bet.EntityId = e.Id
            OUTER APPLY OPENJSON(bet.Metadata) WITH (identifier VARCHAR(32), [value] VARCHAR(128)) AS md
            WHERE bet.Id = @EntityTypeId
            GROUP BY e.CountryId, e.SubdivisionId, e.CityId, e.Address1, e.PostalCode, e.CreatedBy;

            -- Validar que se obtuvieron datos
            IF @BillToCountryId IS NULL
            BEGIN
                THROW 50004, 'No se pudieron obtener datos del BillTo', 1;
            END

            -- INSERTAR EN CLIENTES
            INSERT INTO [dbo].[Clientes] 
                (id, idPais, idEstado, idCiudad, idEmpresa, nombre, alias, 
                 tipoCliente, direccion, codigozip, fechaCambio, idUsuarioLog, nota, [Status], 
                 email, telefono, identificacion, tipoIdentificacion)
            VALUES (
                @ReferenceId,
                @BillToCountryId,
                @BillToSubdivisionId,
                @BillToCityId,
                NULL,
                @Alias,
                @Alias,
                'CLIENTE',
                @BillToAddress,
                @BillToPostalCode,
                GETDATE(),
                @BillToCreatedBy,
                'Relación Alias',
                CASE WHEN @Status = 1 THEN 'ACTIVO' ELSE 'INACTIVO' END,
                ISNULL(@PropriaConsigneeEmail, @BillToEmail),
                ISNULL(@PropriaConsigneePhone, @BillToPhone),
                @BillToIdent,
                @BillToIdentType
            );

            IF @@ROWCOUNT = 0
            BEGIN
                THROW 50005, 'Error al insertar Cliente Alias (SubType 2)', 1;
            END

            -- INSERTAR EN DETALLEENTIDADES
            INSERT INTO [dbo].[DetalleEntidades]
                (id, idEntidad, idCatalogo, idUsuarioLog, [status], nota, fechaCambio)
            VALUES
                (NEWID(), @ReferenceId, @idCatalogo, @BillToCreatedBy, 'ACTIVO',
                 'Detalle de Relación Alias', GETDATE());

            IF @@ROWCOUNT = 0
            BEGIN
                RAISERROR('Error al insertar DetalleEntidades para SubType 2', 10, 1) WITH NOWAIT;
            END

            -- VALIDACIÓN: ADVERTENCIA SI NO HAY EMAIL Y TELÉFONO
            IF ISNULL(@PropriaConsigneeEmail, @BillToEmail) IS NULL
               AND ISNULL(@PropriaConsigneePhone, @BillToPhone) IS NULL
            BEGIN
                RAISERROR('ADVERTENCIA: No se sincronizaron email y teléfono para Cliente %s. Agregue estos datos manualmente en el catálogo de clientes.', 
                         10, 1, @ReferenceId) WITH NOWAIT;
            END
        END

        -- ============================================================
        -- COPIAR AGENTES DESDE BILLTO ANTERIOR
        -- ============================================================
        IF @BillToReferenceId IS NOT NULL
           AND EXISTS (SELECT 1 FROM [dbo].[Clientes] WITH (NOLOCK) WHERE id = @ReferenceId)
        BEGIN
            DECLARE @AgentesTemp TABLE (RowNum INT IDENTITY(1,1), idTipoAgente VARCHAR(32));

            -- Agregar agentes que existen en BillTo anterior pero no en el nuevo
            INSERT INTO @AgentesTemp (idTipoAgente)
            SELECT DISTINCT ac.idTipoAgente
            FROM [dbo].[AgentesCliente] ac WITH (NOLOCK)
            WHERE ac.idCliente = @BillToReferenceId
                AND NOT EXISTS (
                    SELECT 1 FROM [dbo].[AgentesCliente] ac2 WITH (NOLOCK)
                    WHERE ac2.idCliente = @ReferenceId
                        AND ac2.idTipoAgente = ac.idTipoAgente
                );

            DECLARE @IdAgente VARCHAR(16),
                    @IdTipoAgente VARCHAR(32),
                    @Counter INT = 1,
                    @MaxRows INT = (SELECT COUNT(*) FROM @AgentesTemp);

            -- Copiar agentes
            WHILE @Counter <= @MaxRows
            BEGIN
                SELECT @IdTipoAgente = idTipoAgente FROM @AgentesTemp WHERE RowNum = @Counter;
                
                EXEC [dbo].[PRO_General_GenerarIdUnico] @tabla = 'AgentesCliente', @IdUnico = @IdAgente OUTPUT;

                IF @IdAgente IS NOT NULL
                BEGIN
                    INSERT INTO [dbo].[AgentesCliente] (id, idCliente, idTipoAgente)
                    VALUES (@IdAgente, @ReferenceId, @IdTipoAgente);

                    IF @@ROWCOUNT = 0
                    BEGIN
                        RAISERROR('Error al insertar AgentesCliente id: %s', 10, 1, @IdAgente) WITH NOWAIT;
                    END
                END

                SET @Counter = @Counter + 1;
            END
        END

    END TRY
    BEGIN CATCH
        EXEC [dbo].[pro_LogError]
    END CATCH
END
GO
