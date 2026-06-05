/*
VERSION     MODIFIEDBY              MODIFIEDDATE    HU          MODIFICATION
1			Mateo Velasco			2025-06-19      67468       Initial Code: Insert Menu and permissions
*/
-- Agregar opcion de EDITAR para `Consignatarios`
DECLARE @IdRegistro VARCHAR(32);
DECLARE @IdRegistroEditar VARCHAR(32);
 
SELECT TOP 1 @IdRegistro = id
FROM dbo.Menu
WHERE [nombre] = 'Consignatario'
AND [esMenu] = 1
 
IF NOT EXISTS (
    SELECT TOP 1 1
    FROM [Menu]
    WHERE [nombre] = 'Consignatarios/General'
    AND [url] = '/Catalogos/Consignatarios/General/Editar'
)
BEGIN
 
EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu', @IdUnico = @IdRegistroEditar OUTPUT;
    INSERT INTO [Menu]
    ([id], [idPadre], [idUsuarioLog], [nombre], [url], [accion], [orden], [esMenu], [nota], [fechaCambio], [status], [versionFila], [esNewTab], [instruccion], [nombreIngles])
    VALUES
    (@IdRegistroEditar, @IdRegistro, 'ixdSuFOv', 'Consignatarios/General', '/Catalogos/Consignatarios/General/Editar', 'POST', 3, 0, NULL, GETDATE(), 'ACTIVO', NULL, 0, 'EDITAR', 'Consignees/General');
END;

