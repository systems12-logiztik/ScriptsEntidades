/*     
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1		    Marlon Pizarro	    2026-05-16	    55188		Update language names
*/

IF EXISTS (
	SELECT TOP 1 1
	FROM dbo.Idiomas
	WHERE Nombre = 'ENGLISH'
)
BEGIN
	UPDATE dbo.Idiomas
	SET Nombre = 'INGLES',
		idUsuarioLog = '613pMX0S',
		fechaCambio = GETDATE()
	WHERE Nombre = 'ENGLISH'

	PRINT 'Updated Nombre: ENGLISH -> INGLES'
END
ELSE
BEGIN
	PRINT 'No records found for Nombre: ENGLISH'
END;

IF EXISTS (
	SELECT TOP 1 1
	FROM dbo.Idiomas
	WHERE Nombre = 'CHINA'
)
BEGIN
	UPDATE dbo.Idiomas
	SET Nombre = 'CHINO',
		idUsuarioLog = '613pMX0S',
		fechaCambio = GETDATE(),
		NombreIngles = 'CHINESE'
	WHERE Nombre = 'CHINA'

	PRINT 'Updated Nombre: CHINA -> CHINO'
END
ELSE
BEGIN
	PRINT 'No records found for Nombre: CHINA'
END;

IF EXISTS (
	SELECT TOP 1 1
	FROM dbo.Idiomas
	WHERE Nombre = 'RUSIA'
)
BEGIN
	UPDATE dbo.Idiomas
	SET Nombre = 'RUSO',
		idUsuarioLog = '613pMX0S',
		fechaCambio = GETDATE()
	WHERE Nombre = 'RUSIA'

	PRINT 'Updated Nombre: RUSIA -> RUSO'
END
ELSE
BEGIN
	PRINT 'No records found for Nombre: RUSIA'
END;

