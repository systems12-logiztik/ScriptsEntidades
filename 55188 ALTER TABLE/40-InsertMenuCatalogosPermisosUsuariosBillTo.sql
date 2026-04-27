/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			JOSE GUERRA			2025-04-23		46759		LAG-CT-004 Catálogo de Bill-to: pestaña Usuarios
*/

-- Obtener el id del menu `Bill-to`
DECLARE @IdRegistro VARCHAR(32);
    
SELECT TOP 1 @IdRegistro = id
    FROM [Menu]
    WHERE [nombre] = 'Bill-to'
    AND [esMenu] = 1


-- Agregar opción de insertar para ` Usuarios Bill-to`
DECLARE @IdRegistroInsertar VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Usuarios/Insertar'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroInsertar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroInsertar, @IdRegistro, 'odqokg7C', 'Bill-to/Usuarios', '/Catalogos/BillTo/Usuarios/Insertar', 'POST', 1, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'INSERTAR', 'Bill-to/Users');
END;

-- Agregar opción de editar para `Usuarios Bill-to`
DECLARE @IdRegistroEditar VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Usuarios/Editar'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroEditar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroEditar, @IdRegistro, 'odqokg7C', 'Bill-to/Usuarios', '/Catalogos/BillTo/Usuarios/Editar', 'POST', 2, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'EDITAR', 'Bill-to/Users');
END;



-- Agregar opción de listar para `Usuarios Bill-to`
DECLARE @IdRegistroListar VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Usuarios/Listar'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroListar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroListar, @IdRegistro, 'odqokg7C', 'Bill-to/Usuarios', '/Catalogos/BillTo/Usuarios/Listar', 'GET', 3, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'LISTAR', 'Bill-to/User');
END;

-- Agregar opción de editar para `General Ejecutivo Comercial Bill-to`
DECLARE @IdRegistroEditarEjeCcial VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/General/EjecutivoComercial/Editar'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroEditarEjeCcial OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroEditarEjeCcial, @IdRegistro, 'odqokg7C', 'Bill-to/General/Ejecutivo Comercial', '/Catalogos/BillTo/General/EjecutivoComercial/Editar', 'POST', 1, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'EDITAR', 'Bill-to/General/Commercial Executive');
END;


-- Agregar opción de editar para `General Ejecutivo Comercial Bill-to`
DECLARE @IdRegistroEditarServicioCliente VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/General/ServicioCliente/Editar'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroEditarServicioCliente OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroEditarServicioCliente, @IdRegistro, 'odqokg7C', 'Bill-to/General/Servicio Cliente', '/Catalogos/BillTo/General/ServicioCliente/Editar', 'POST', 2, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'EDITAR', 'Bill-to/General/Customer Service');
END;
