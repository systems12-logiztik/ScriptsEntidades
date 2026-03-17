/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU					MODIFICATION
1			MATEO VELASCO		26-05-2025		46761				LAG-CT-004 Bill-to Catalog: Consignee function
*/
 
-- Obtain id from Bill-To menu
DECLARE @IdRegistro VARCHAR(32);
SELECT TOP 1 @IdRegistro = id
    FROM [Menu]
    WHERE [nombre] = 'Bill-to'
    AND [esMenu] = 1
 
-- Add update option to 'BillTo Consignees'
DECLARE @IdRegistroEditar VARCHAR(32);
 
IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Consignatarios/Editar'
)
BEGIN
 
EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroEditar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroEditar, @IdRegistro, 'ixdSuFOv', 'Bill-to/Consignatarios', '/Catalogos/BillTo/Consignatarios/Editar', 'POST', 2, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'EDITAR', 'Bill-to/Consignees');
END;
 
-- Add list option to 'BillTo Consignees'
DECLARE @IdRegistroListar VARCHAR(32);
 
IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Consignatarios/Listar'
)
BEGIN
 
EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroListar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroListar, @IdRegistro, 'ixdSuFOv', 'Bill-to/Consignatarios', '/Catalogos/BillTo/Consignatarios/Listar', 'GET', 4, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'LISTAR', 'Bill-to/Consignees');
END;

-- Add insert option to 'BillTo Consignees'
DECLARE @IdRegistroInsertar VARCHAR(32);
 
IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Consignatarios/Insertar'
)
BEGIN
 
EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroInsertar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroInsertar, @IdRegistro, 'ixdSuFOv', 'Bill-to/Consignatarios', '/Catalogos/BillTo/Consignatarios/Insertar', 'POST', 1, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'INSERTAR', 'Bill-to/Consignees');
END;
 
-- Add delete option to 'BillTo Consignees'
DECLARE @IdRegistroEliminar VARCHAR(32);
 
IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Consignatarios/Eliminar'
)
BEGIN
 
EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroEditar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroEditar, @IdRegistro, 'ixdSuFOv', 'Bill-to/Consignatarios', '/Catalogos/BillTo/Consignatarios/Eliminar', 'POST', 3, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'ELIMINAR', 'Bill-to/Consignees');
END;