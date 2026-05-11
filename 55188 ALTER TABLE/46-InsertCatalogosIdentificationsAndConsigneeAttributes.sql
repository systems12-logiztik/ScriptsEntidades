/*
VERSION    MODIFIEDBY        MODIFIEDDATE    HU      MODIFICATION
1          JOSE GUERRA       2025-01-28      55188   LAG-CT-003 Bill-to Catalog: General Tab and Hide/Delete Buttons
2          JOSE GUERRA       2025-04-23      46759   LAG-CT-004 Bill-to Catalog: Users Tab
*/
DECLARE @IdNew INT;

IF NOT EXISTS (
    SELECT 1 
    FROM [dbo].[Catalogos]
    WHERE [codigo] = 'Identifications' 
    AND [identificador] IN (
        'IDENTIFICATIONCARD',
        'PASSPORT',
        'FISCALIDENTIFICATIONNUMBER',
        'EORI',
        'IMPORTEROFRECORD'
    )
)
BEGIN
    SELECT @IdNew = MAX([IdNew]) + 1
    FROM [dbo].[Catalogos];

    INSERT INTO [dbo].[Catalogos]
    (
        [idEmpresa],
        [nombre],
        [nombreIngles],
        [codigo],
        [tipo],
        [descripcion],
        [status],
        [nota],
        [fechaCambio],
        [identificador],
        [clase],
        [codigoRelacion],
        [orden],
        [oculto],
        [idCatalgoPadre],
        [idRegistroVinculado],
        [IdNew]
    )
    VALUES
    (
        NULL,
        'CÉDULA DE CIUDADANIA',
        'IDENTIFICATION CARD',
        'Identifications',
        'ENUMERACION',
        'Identification type for listing',
        'ACTIVO',
        NULL,
        GETDATE(),
        'IDENTIFICATIONCARD',
        NULL,
        NULL,
        1,
        0,
        NULL,
        NULL,
        @IdNew
    );

    SELECT @IdNew = MAX([IdNew]) + 1
    FROM [dbo].[Catalogos];

    INSERT INTO [dbo].[Catalogos]
    (
        [idEmpresa],
        [nombre],
        [nombreIngles],
        [codigo],
        [tipo],
        [descripcion],
        [status],
        [nota],
        [fechaCambio],
        [identificador],
        [clase],
        [codigoRelacion],
        [orden],
        [oculto],
        [idCatalgoPadre],
        [idRegistroVinculado],
        [IdNew]
    )
    VALUES
    (
        NULL,
        'PASAPORTE',
        'PASSPORT',
        'Identifications',
        'ENUMERACION',
        'Identification type for listing',
        'ACTIVO',
        NULL,
        GETDATE(),
        'PASSPORT',
        NULL,
        NULL,
        2,
        0,
        NULL,
        NULL,
        @IdNew
    );

    SELECT @IdNew = MAX([IdNew]) + 1
    FROM [dbo].[Catalogos];

    INSERT INTO [dbo].[Catalogos]
    (
        [idEmpresa],
        [nombre],
        [nombreIngles],
        [codigo],
        [tipo],
        [descripcion],
        [status],
        [nota],
        [fechaCambio],
        [identificador],
        [clase],
        [codigoRelacion],
        [orden],
        [oculto],
        [idCatalgoPadre],
        [idRegistroVinculado],
        [IdNew]
    )
    VALUES
    (
        NULL,
        'NÚMERO DE IDENTIFICACIÓN FISCAL',
        'FISCAL IDENTIFICATION NUMBER',
        'Identifications',
        'ENUMERACION',
        'Identification type for listing',
        'ACTIVO',
        NULL,
        GETDATE(),
        'FISCALIDENTIFICATIONNUMBER',
        NULL,
        NULL,
        3,
        0,
        NULL,
        NULL,
        @IdNew
    );

    SELECT @IdNew = MAX([IdNew]) + 1
    FROM [dbo].[Catalogos];

    INSERT INTO [dbo].[Catalogos]
    (
        [idEmpresa],
        [nombre],
        [nombreIngles],
        [codigo],
        [tipo],
        [descripcion],
        [status],
        [nota],
        [fechaCambio],
        [identificador],
        [clase],
        [codigoRelacion],
        [orden],
        [oculto],
        [idCatalgoPadre],
        [idRegistroVinculado],
        [IdNew]
    )
    VALUES
    (
        NULL,
        'EORI',
        'EORI',
        'Identifications',
        'ENUMERACION',
        'Identification type for listing',
        'ACTIVO',
        NULL,
        GETDATE(),
        'EORI',
        NULL,
        NULL,
        4,
        0,
        NULL,
        NULL,
        @IdNew
    );

    SELECT @IdNew = MAX([IdNew]) + 1
    FROM [dbo].[Catalogos];

    INSERT INTO [dbo].[Catalogos]
    (
        [id],
        [idEmpresa],
        [nombre],
        [nombreIngles],
        [codigo],
        [tipo],
        [descripcion],
        [status],
        [nota],
        [fechaCambio],
        [identificador],
        [clase],
        [codigoRelacion],
        [orden],
        [oculto],
        [idCatalgoPadre],
        [idRegistroVinculado],
        [IdNew]
    )
    VALUES
    (
        NEWID(),
        NULL,
        'IMPORTADOR REGISTRADO',
        'IMPORTER OF RECORD',
        'Identifications',
        'ENUMERACION',
        'Identification type for listing',
        'ACTIVO',
        NULL,
        GETDATE(),
        'IMPORTEROFRECORD',
        NULL,
        NULL,
        5,
        0,
        NULL,
        NULL,
        @IdNew
    );
    
END;

IF NOT EXISTS (
    SELECT 1 
    FROM [dbo].[Catalogos]
    WHERE [codigo] = 'ConsigneeAttributes' 
    AND [identificador] IN (
        'EMAIL',
        'PHONE'
    )
)
BEGIN 
    SELECT @IdNew = ISNULL(MAX([IdNew]), 0) + 1
    FROM [dbo].[Catalogos];

    INSERT INTO [dbo].[Catalogos]
    (
        [idEmpresa],
        [nombre],
        [nombreIngles],
        [codigo],
        [tipo],
        [descripcion],
        [status],
        [nota],
        [fechaCambio],
        [identificador],
        [clase],
        [codigoRelacion],
        [orden],
        [oculto],
        [idCatalgoPadre],
        [idRegistroVinculado],
        [IdNew]
    )
    VALUES 
    (
        NULL,
        'Correo electrónico*',
        'Email*',
        'ConsigneeAttributes',
        'ENUMERACION',
        'Email principal del Consignee.',
        'ACTIVO',
        NULL,
        GETDATE(),
        'EMAIL',
        NULL,
        NULL,
        10,
        0,
        NULL,
        NULL,
        @IdNew
    );

    SELECT @IdNew = ISNULL(MAX([IdNew]), 0) + 1
    FROM [dbo].[Catalogos];

    INSERT INTO [dbo].[Catalogos]
    (
        [idEmpresa],
        [nombre],
        [nombreIngles],
        [codigo],
        [tipo],
        [descripcion],
        [status],
        [nota],
        [fechaCambio],
        [identificador],
        [clase],
        [codigoRelacion],
        [orden],
        [oculto],
        [idCatalgoPadre],
        [idRegistroVinculado],
        [IdNew]
    )
    VALUES 
    (
        NULL,
        'Teléfono*',
        'Phone*',
        'ConsigneeAttributes',
        'ENUMERACION',
        'Teléfono principal del Consignee.',
        'ACTIVO',
        NULL,
        GETDATE(),
        'PHONE',
        NULL,
        NULL,
        20,
        0,
        NULL,
        NULL,
        @IdNew
    );
END

