/*
VERSION     MODIFIEDBY              MODIFIEDDATE    HU          MODIFICATION
1           Marlon Pizarro          2025-08-28      67468       LAG-CT-001â€‹ Entities catalog menu
*/
DECLARE @IdRegistro VARCHAR(32);
IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [nombre] = 'Entidades'
    AND [esMenu] = 1
)
BEGIN

    EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistro OUTPUT;

    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistro, 'MNU011', '613pMX0S', 'Entidades', '/Catalogos/Entities', 'MENU', 0, 1, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'MENU', 'Entities');
END;

-- Agregar opciÃ³n secundario menu `BillTos`
DECLARE @IdBillTos VARCHAR(32);
IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [nombre] = 'Bill-to'
    AND [esMenu] = 1
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdBillTos OUTPUT;

    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdBillTos, @IdRegistro, '613pMX0S', 'Bill-to', '/Catalogos/Entities?typeEntity=1', 'MENU', 0, 1, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'MENU', 'Bill-to');
END;

-- Agregar opciÃ³n secundario menu `Consignees`
DECLARE @IdConsignees VARCHAR(32);
IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [nombre] = 'Consignatario'
    AND [esMenu] = 1
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdConsignees OUTPUT;

    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdConsignees, @IdRegistro, '613pMX0S', 'Consignatario', '/Catalogos/Entities?typeEntity=2', 'MENU', 0, 1, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'MENU', 'Consignee');
END;

-- Agregar opciÃ³n de listar `
DECLARE @IdRegistroListar VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [nombre] = 'Entidades'
    AND [url] = '/Catalogos/Entities/Listar'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroListar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroListar, @IdRegistro, '613pMX0S', 'Entidades', '/Catalogos/Entities/Listar', 'GET', 0, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'LISTAR', 'Entities');
END;

 DECLARE @IdRegistroInsertar VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [nombre] = 'Entidades'
    AND [url] = '/Catalogos/Entities/Insertar'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroInsertar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroInsertar, @IdRegistro, '613pMX0S', 'Entidades', '/Catalogos/Entities/Insertar', 'POST', 1, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'INSERT', 'Entities');
END;


DECLARE @IdRegistroEditar VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [nombre] = 'Entidades'
    AND [url] = '/Catalogos/Entities/Editar'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroEditar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroEditar, @IdRegistro, '613pMX0S', 'Entidades', '/Catalogos/Entities/Editar', 'POST', 2, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'EDITAR', 'Entities');
END;

DECLARE @IdRegistroEliminar VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [nombre] = 'Entidades'
    AND [url] = '/Catalogos/Entities/Eliminar'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroEliminar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroEliminar, @IdRegistro, '613pMX0S', 'Entidades', '/Catalogos/Entities/Eliminar', 'POST', 3, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'ELIMINAR', 'Entities');
END;


DECLARE @IdRegistroListarTodos VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [nombre] = 'Entidades' 
    AND [url] = '/Catalogos/Entities/ListarTodos'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroListarTodos OUTPUT;

    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroListarTodos, @IdRegistro, '613pMX0S', 'Entidades', '/Catalogos/Entities/ListarTodos', 'GET', 4, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'LISTARTODOS', 'Entidades');
END;


