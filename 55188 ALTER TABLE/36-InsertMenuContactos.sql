/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			Jorge Ortiz			2025-05-20		55188		Initial Code - Add new Menus for Billto-Contacts
*/
DECLARE @IdRegistro VARCHAR(32),
		@newId VARCHAR(32)

SELECT TOP 1 @IdRegistro = id
FROM dbo.Menu
WHERE [nombre] = 'Bill-to'
AND [esMenu] = 1
 
IF NOT EXISTS (
    SELECT TOP 1 1
    FROM dbo.Menu
    WHERE [url] = '/Catalogos/BillTo/Contactos/Insertar'
)
BEGIN
 
	EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @newId OUTPUT;
    INSERT INTO dbo.Menu 
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
		'Bill-to/Contactos',
		'/Catalogos/BillTo/Contactos/Insertar',
		'POST',
		1,
		0,
		NULL,
		GETDATE(),
		'ACTIVO',
		NULL,
		0,
		'INSERTAR', 
		'Bill-to/Contacts'
	);
END

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM dbo.Menu
    WHERE [url] = '/Catalogos/BillTo/Contactos/Editar'
)
BEGIN
	EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @newId OUTPUT;
    INSERT INTO dbo.Menu 
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
		'Bill-to/Contactos',
		'/Catalogos/BillTo/Contactos/Editar',
		'POST',
		2,
		0,
		NULL,
		GETDATE(),
		'ACTIVO',
		NULL,
		0,
		'EDITAR', 
		'Bill-to/Contacts'
	);
END

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM dbo.Menu
    WHERE [url] = '/Catalogos/BillTo/Contactos/Eliminar'
)
BEGIN
 
	EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @newId OUTPUT;
    INSERT INTO dbo.Menu 
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
		'Bill-to/Contactos',
		'/Catalogos/BillTo/Contactos/Eliminar',
		'POST',
		3,
		0,
		NULL,
		GETDATE(),
		'ACTIVO',
		NULL,
		0,
		'ELIMINAR', 
		'Bill-to/Contacts'
	);
END

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM dbo.Menu
    WHERE [url] = '/Catalogos/BillTo/Contactos/Listar'
)
BEGIN
 
	EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @newId OUTPUT;
    INSERT INTO dbo.Menu 
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
		'Bill-to/Contactos',
		'/Catalogos/BillTo/Contactos/Listar',
		'GET',
		4,
		0,
		NULL,
		GETDATE(),
		'ACTIVO',
		NULL,
		0,
		'LISTAR', 
		'Bill-to/Contacts'
	);
END