/*
VERSION     MODIFIEDBY      MODIFIEDDATE    HU      MODIFICATION
1           Luis Campos     2026-01-22      67468   Script idempotente para insertar cliente N/A
*/

DECLARE @IdRegistro VARCHAR(32) = 'CLI999999';
DECLARE @nombre NVARCHAR(512) = N'N/A';
DECLARE @idUsuarioLog VARCHAR(16) = 'PDAi4bEO';
DECLARE @tipoCliente VARCHAR(32) = 'CLIENTE';
DECLARE @status VARCHAR(32) = 'ACTIVO';

IF NOT EXISTS (SELECT 1 FROM Clientes WHERE nombre = @nombre)
BEGIN
    INSERT INTO Clientes (id, nombre, idUsuarioLog, tipoCliente, fechaCambio, [status])
    VALUES (@IdRegistro, @nombre, @idUsuarioLog, @tipoCliente, GETDATE(), @status);
    
    PRINT 'Cliente insertado exitosamente: ' + @IdRegistro;
    
    SELECT id, nombre, fechaCambio, [status]
    FROM Clientes
    WHERE id = @IdRegistro;
END
ELSE
BEGIN
    PRINT 'El cliente ya existe: ' + @nombre;
    
    SELECT id, nombre, fechaCambio, [status]
    FROM Clientes
    WHERE nombre = @nombre;
END

GO

