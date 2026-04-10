/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU				MODIFICATION
1			JOSE GUERRA			2025-05-01		CT 49428		Initial Code - Add Permissions to Menu
*/

-- Obtener el id del menu `Bill-to`
DECLARE @IdRegistro VARCHAR(32);
    
SELECT TOP 1 @IdRegistro = id
    FROM [Menu]
    WHERE [nombre] = 'Bill-to'
    AND [esMenu] = 1

-- Agregar opci�n de listar para `Financiero Bill-to`
DECLARE @IdRegistroListar VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Financiero/Listar'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroListar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroListar, @IdRegistro, 'odqokg7C', 'Bill-to/Financiero', '/Catalogos/BillTo/Financiero/Listar', 'GET', 3, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'LISTAR', 'Bill-to/Finantial');
END;


-- Agregar opci�n de editar deshabilitar para `Financiero Bill-to`
DECLARE @IdRegistroDeshabilitar VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Financiero/Deshabilitar'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroDeshabilitar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroDeshabilitar, @IdRegistro, 'odqokg7C', 'Bill-to/Financiero/Deshabilitar', '/Catalogos/BillTo/Financiero/Deshabilitar', 'POST', 1, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'EDITAR', 'Bill-to/Finantial/Disable');
END;

-- Agregar opci�n de editar para `Financiero Bill-to`
DECLARE @IdRegistroEditar VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [url] = '/Catalogos/BillTo/Financiero/CodigoContable'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroEditar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroEditar, @IdRegistro, 'odqokg7C', 'Bill-to/Financiero/CodigoContable', '/Catalogos/BillTo/Financiero/CodigoContable', 'POST', 2, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'EDITAR', 'Bill-to/Finantial/AccountingCode');
END;