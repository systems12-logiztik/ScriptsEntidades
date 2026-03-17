/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU					MODIFICATION
1			Jorge Ortiz			22-04-2025		CT 46760			Initial Code - Add new Menus for Billto-ParametersDocs
*/
DECLARE @IdRegistro VARCHAR(16),
		@newId VARCHAR(32)

SELECT TOP 1 @IdRegistro = id
    FROM [Menu]
    WHERE [nombre] = 'Bill-to'
    AND [esMenu] = 1
 
IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Parametros/Global'
)
BEGIN
 
	EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @newId OUTPUT;
    INSERT INTO [Menu] 
    (
		[id], 
		[idPadre], 
		[idUsuarioLog], 
		[nombre], 
		[url], 
		[accion], 
		[orden], 
		[esMenu], 
		[nota], 
		[fechaCambio], 
		[status], 
		[versionFila], 
		[esNewTab], 
		[instruccion], 
		[nombreIngles])
    VALUES 
    (
		@newId,
		@IdRegistro,
		'vkypnnc1',
		'Bill-to/Parametros/Global',
		'/Catalogos/BillTo/Parametros/Global',
		'POST',
		1,
		0,
		NULL,
		GETDATE(),
		'ACTIVO',
		NULL,
		0,
		'EDITAR', 
		'Bill-to/Parametros/Global'
	);
END;
 
IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Parametros/PorEstacion'
)
BEGIN
 
	EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @newId OUTPUT;
    INSERT INTO [Menu] 
    (
		[id], 
		[idPadre], 
		[idUsuarioLog], 
		[nombre], 
		[url], 
		[accion], 
		[orden], 
		[esMenu], 
		[nota], 
		[fechaCambio], 
		[status], 
		[versionFila], 
		[esNewTab], 
		[instruccion], 
		[nombreIngles]
	)
    VALUES 
    (
		@newId,
		@IdRegistro,
		'vkypnnc1',
		'Bill-to/Parametros/ByStation',
		'/Catalogos/BillTo/Parametros/PorEstacion',
		'POST',
		2,
		0,
		NULL,
		GETDATE(),
		'ACTIVO',
		NULL,
		0,
		'EDITAR',
		'Bill-to/Parametros/ByStation'
	);
END;

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Parametros/Listar'
)
BEGIN
	EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @newId OUTPUT;
    INSERT INTO [Menu] 
    (
		[id], 
		[idPadre], 
		[idUsuarioLog], 
		[nombre], 
		[url], 
		[accion], 
		[orden], 
		[esMenu], 
		[nota], 
		[fechaCambio], 
		[status], 
		[versionFila], 
		[esNewTab], 
		[instruccion], 
		[nombreIngles]
	)
    VALUES 
    (
		@newId,
		@IdRegistro,
		'vkypnnc1',
		'Bill-to/Parametros/Listar',
		'/Catalogos/BillTo/Parametros/Listar',
		'GET',
		3,
		0,
		NULL,
		GETDATE(),
		'ACTIVO',
		NULL,
		0,
		'LISTAR',
		'Bill-to/Parametros/Listar'
	);
END;