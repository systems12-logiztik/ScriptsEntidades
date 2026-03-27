/*
VERSION		MODIFIEDBY		MODIFIEDDATE	HU			MODIFICATION
1			Luis Campos		2026-03-23		AC 55188	Sync EntityRelations to Clientes with three subtypes
*/
CREATE OR ALTER TRIGGER [dbo].[trg_EntityRelations_SyncClientes]
ON [dbo].[EntityRelations]
AFTER INSERT
NOT FOR REPLICATION
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF (SELECT COUNT(*) FROM inserted) > 1 RETURN;

        DECLARE @RelationId VARCHAR(32),
                @ReferenceId VARCHAR(16),
                @EntityTypeId VARCHAR(32),
                @ChildEntityTypeId VARCHAR(32),
                @SubType INT,
                @Alias VARCHAR(512),
                @Status INT,
                @BillToName VARCHAR(512),
                @PropriaConsigneeEmail VARCHAR(128) = NULL,
                @PropriaConsigneePhone VARCHAR(128) = NULL,
                @BillToReferenceId VARCHAR(16),
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
                @ConsigneeCreatedBy VARCHAR(128),
                @ConsigneeClienteId VARCHAR(16),
                @BillToEmail VARCHAR(128) = NULL,
                @BillToPhone VARCHAR(128) = NULL,
                @BillToIdent VARCHAR(128) = NULL,
                @BillToIdentType VARCHAR(32) = NULL,
                @BillToCountryId VARCHAR(32),
                @BillToSubdivisionId VARCHAR(32),
                @BillToCityId VARCHAR(32),
                @BillToAddress VARCHAR(512),
                @BillToPostalCode VARCHAR(32),
                @BillToCreatedBy VARCHAR(128),
                @ErrorMessage NVARCHAR(MAX),
                @ErrorSeverity INT;

        SELECT TOP 1 
            @RelationId = Id, @ReferenceId = ReferenceId, @EntityTypeId = EntityTypeId,
            @ChildEntityTypeId = ChildEntityTypeId, @SubType = SubType, @Alias = Alias, @Status = [Status]
        FROM inserted WITH (NOLOCK)
        WHERE [Status] = 1;

        IF @RelationId IS NULL RETURN;

        -- Generar ReferenceId si es nulo
        IF @ReferenceId IS NULL
        BEGIN
            EXEC [dbo].[PRO_General_GenerarIdUnico] @tabla = 'Clientes', @IdUnico = @ReferenceId OUTPUT;
            UPDATE [dbo].[EntityRelations] SET ReferenceId = @ReferenceId WHERE Id = @RelationId;
        END

        -- Obtener nombre del Bill-To
        SELECT 
            @BillToName = e.[Name]
        FROM [dbo].[EntityTypes] et WITH (NOLOCK)
        INNER JOIN [dbo].[Entities] e WITH (NOLOCK) ON et.EntityId = e.Id
        WHERE et.Id = @EntityTypeId;

        -- Obtener email/teléfono del Consignee actual (ChildEntityTypeId)
        SELECT 
            @PropriaConsigneeEmail = MAX(CASE WHEN md.identifier = 'EMAIL' THEN md.[value] END),
            @PropriaConsigneePhone = MAX(CASE WHEN md.identifier = 'PHONE' THEN md.[value] END)
        FROM [dbo].[EntityTypes] cet WITH (NOLOCK)
        OUTER APPLY OPENJSON(cet.Metadata) WITH (identifier VARCHAR(32), [value] VARCHAR(128)) AS md
        WHERE cet.Id = @ChildEntityTypeId;

        -- Obtener ReferenceId del Bill-To si existe en EntityRelaciones anterior
        SELECT TOP 1 @BillToReferenceId = er.ReferenceId
        FROM [dbo].[EntityRelations] er WITH (NOLOCK)
        WHERE er.EntityTypeId = @EntityTypeId 
        AND er.[Status] = 1
        AND er.Id <> @RelationId
        ORDER BY er.CreatedDate DESC;

        IF @SubType IN (1, 3)
        BEGIN

            SELECT 
                @ConsigneeEmail = MAX(CASE WHEN md.identifier = 'EMAIL' THEN md.[value] END),
                @ConsigneePhone = MAX(CASE WHEN md.identifier = 'PHONE' THEN md.[value] END),
                @ConsigneeIdent = COALESCE(MAX(CASE WHEN md.identifier = 'EORI' THEN md.[value] END),
                                          MAX(CASE WHEN md.identifier = 'IDENTIFICATIONCARD' THEN md.[value] END),
                                          MAX(CASE WHEN md.identifier = 'PASSPORT' THEN md.[value] END),
                                          MAX(CASE WHEN md.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN md.[value] END),
                                          MAX(CASE WHEN md.identifier = 'IMPORTEROFRECORD' THEN md.[value] END)),
                @ConsigneeIdentType = CASE WHEN MAX(CASE WHEN md.identifier = 'EORI' THEN 1 END) = 1 THEN 'EORI'
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

            INSERT INTO [dbo].[Clientes] (id, idPais, idEstado, idCiudad, idEmpresa, nombre, alias, 
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

            IF @SubType = 3
            BEGIN
                SELECT TOP 1 @ConsigneeClienteId = er.ReferenceId
                FROM [dbo].[EntityRelations] er WITH (NOLOCK)
                WHERE er.EntityTypeId = @EntityTypeId 
                AND er.ChildEntityTypeId = @ChildEntityTypeId
                AND er.SubType = 1 
                AND er.[Status] = 1
                ORDER BY er.CreatedDate DESC;
                
                IF @ConsigneeClienteId IS NOT NULL
                AND NOT EXISTS (SELECT 1 FROM [dbo].[ConsignatarioClientesFinal] WITH (NOLOCK) WHERE idClienteFinal = @ReferenceId AND idConsignatario = @ConsigneeClienteId)
                BEGIN
                    INSERT INTO [dbo].[ConsignatarioClientesFinal] 
                        (id, idClienteFinal, idConsignatario, [status], nota, idUsuarioLog, fechaCambio)
                    VALUES
                        (NEWID(), @ReferenceId, @ConsigneeClienteId, 'ACTIVO', 'Consignee de relación Ship-To', 'SYSTEM', GETDATE());
                END
            END
        END
        ELSE IF @SubType = 2
        BEGIN
            SELECT 
                @BillToEmail = MAX(CASE WHEN md.identifier = 'EMAIL' THEN md.[value] END),
                @BillToPhone = MAX(CASE WHEN md.identifier = 'PHONE' THEN md.[value] END),
                @BillToIdent = COALESCE(MAX(CASE WHEN md.identifier = 'EORI' THEN md.[value] END),
                                       MAX(CASE WHEN md.identifier = 'IDENTIFICATIONCARD' THEN md.[value] END),
                                       MAX(CASE WHEN md.identifier = 'PASSPORT' THEN md.[value] END),
                                       MAX(CASE WHEN md.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN md.[value] END),
                                       MAX(CASE WHEN md.identifier = 'IMPORTEROFRECORD' THEN md.[value] END)),
                @BillToIdentType = CASE WHEN MAX(CASE WHEN md.identifier = 'EORI' THEN 1 END) = 1 THEN 'EORI'
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

            INSERT INTO [dbo].[Clientes] (id, idPais, idEstado, idCiudad, idEmpresa, nombre, alias, 
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
                COALESCE(@PropriaConsigneeEmail, @BillToEmail),
                COALESCE(@PropriaConsigneePhone, @BillToPhone),
                @BillToIdent,
                @BillToIdentType
            );

            IF @PropriaConsigneeEmail IS NULL AND @PropriaConsigneePhone IS NULL AND @BillToEmail IS NULL AND @BillToPhone IS NULL
                RAISERROR('ADVERTENCIA: Sin datos de contacto en Consignee ni Bill-To. Agregue email/teléfono manualmente.', 10, 1) WITH NOWAIT;
        END
        
        -- Sincronizar AgentesCliente desde Bill-To al nuevo Cliente
        IF @BillToReferenceId IS NOT NULL AND EXISTS (SELECT 1 FROM [dbo].[Clientes] WITH (NOLOCK) WHERE id = @ReferenceId)
        BEGIN
            -- Tabla temporal para almacenar agentes a insertar con número secuencial
            DECLARE @AgentesTemp TABLE (
                RowNum INT IDENTITY(1,1),
                idTipoAgente VARCHAR(32)
            );
            
            -- Obtener agentes del Bill-To que no existan en el nuevo cliente
            INSERT INTO @AgentesTemp (idTipoAgente)
            SELECT DISTINCT idTipoAgente
            FROM [dbo].[AgentesCliente] WITH (NOLOCK)
            WHERE idCliente = @BillToReferenceId
            AND NOT EXISTS (
                SELECT 1 FROM [dbo].[AgentesCliente] ac2
                WHERE ac2.idCliente = @ReferenceId 
                AND ac2.idTipoAgente = [dbo].[AgentesCliente].idTipoAgente
            );
            
            -- Insertar cada agente con ID generado usando WHILE sin cursor
            DECLARE @IdAgente VARCHAR(16),
                    @IdTipoAgente VARCHAR(32),
                    @Counter INT = 1,
                    @MaxRows INT = (SELECT COUNT(*) FROM @AgentesTemp);
            
            WHILE @Counter <= @MaxRows
            BEGIN
                SELECT @IdTipoAgente = idTipoAgente
                FROM @AgentesTemp
                WHERE RowNum = @Counter;
                
                EXEC [dbo].[PRO_General_GenerarIdUnico] @tabla = 'AgentesCliente', @IdUnico = @IdAgente OUTPUT;
                
                INSERT INTO [dbo].[AgentesCliente] (
                    id,
                    idCliente,
                    idTipoAgente
                )
                VALUES (
                    @IdAgente,
                    @ReferenceId,
                    @IdTipoAgente
                );
                
                SELECT @Counter = @Counter + 1;
            END;
        END
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
