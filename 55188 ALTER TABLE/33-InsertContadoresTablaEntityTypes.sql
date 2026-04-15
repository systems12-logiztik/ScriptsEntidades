/*
VERSION     MODIFIEDBY              MODIFIEDDATE    HU          MODIFICATION
1           Marlon Pizarro          2025-09-16      55188       Initial Code - New secuencial for table EntityTypes
*/
IF NOT EXISTS (
    SELECT 1 
    FROM Contadores 
    WHERE tabla = 'EntityTypes'
)
BEGIN
    DECLARE @newId INT;

	SELECT @newId = MAX(c.id) + 1
	FROM dbo.Contadores c

    INSERT INTO Contadores (id, tabla, contador, idEmpresa, prefijo, posfijo, maximoContador, cantidadCerosIzquierda, CreatedBy, CreatedDate)
    VALUES (@newId, 'EntityTypes', 0, NULL, 'ETY', NULL, NULL, NULL, '613pMX0S', GETDATE());
END;
