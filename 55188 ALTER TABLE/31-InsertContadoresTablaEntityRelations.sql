/*
VERSION     MODIFIEDBY              MODIFIEDDATE    HU          MODIFICATION
1           Jorge Ortiz             2025-11-06      55188       Initial Code - New secuencial for table EntityRelations
*/
IF NOT EXISTS (
    SELECT 1 
    FROM Contadores 
    WHERE tabla = 'EntityRelations'
)
BEGIN
    
    DECLARE @newId INT;

	SELECT @newId = MAX(c.id) + 1
	FROM dbo.Contadores c

    INSERT INTO Contadores (id, tabla, contador, idEmpresa, prefijo, posfijo, maximoContador, cantidadCerosIzquierda, CreatedBy, CreatedDate)
    VALUES (@newId, 'EntityRelations', 0, NULL, 'REL', NULL, NULL, NULL, 'vkypnnc1', GETDATE()); --en desarrollo inicia desde 300
END;
