/*    
VERSION		MODIFIEDBY		MODIFIEDDATE	HU			MODIFICATION
1			Jorge Ortiz		2025-11-10		67468		Initial Code - New secuencial for table ExcludedContacts
*/
IF NOT EXISTS (
    SELECT TOP 1 1
    FROM dbo.Contadores c
    WHERE c.tabla = 'ExcludedContacts'
)
BEGIN
	DECLARE @newId INT;

	SELECT @newId = MAX(c.id) + 1
	FROM dbo.Contadores c

	INSERT INTO Contadores 
	(
		id,
		tabla,
		contador,
		idEmpresa,
		prefijo,
		posfijo,
		maximoContador,
		cantidadCerosIzquierda,
		CreatedDate,
		CreatedBy
	) VALUES
	(
		@newId,
		'ExcludedContacts',
		0,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		GETDATE(),
		'vkypnnc1'
	);

PRINT 'Record inserted successfully into Contadores table for ExcludedContacts.'
END
ELSE
BEGIN
	PRINT 'Record already exists in Contadores table for ExcludedContacts.'
END

