/*
VERSION     MODIFIEDBY              MODIFIEDDATE    HU          MODIFICATION
1           Pierre Quitiaquez       2024-11-21      55188       LAG-CT-001​ Nuevo menu catálogo de Bill-to (back-end)
*/
DECLARE @IdRegistro VARCHAR(32);
DECLARE @IdRegistroListar VARCHAR(32);

SELECT TOP 1 @IdRegistro = id
FROM dbo.Menu
WHERE [nombre] = 'Bill-to'
AND [esMenu] = 1

-- Agregar opción de editar para `Bill-to`
DECLARE @IdRegistroEditar VARCHAR(32);

IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [nombre] = 'Bill-to'
    AND [url] = '/Catalogos/BillTo/Editar'
)
BEGIN

EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroEditar OUTPUT;
    INSERT INTO [Menu] 
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES 
    (@IdRegistroEditar, @IdRegistro, 'PDAi4bEO', 'Bill-to', '/Catalogos/BillTo/Editar', 'POST', 2, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'EDITAR', 'Bill-to');
END;

