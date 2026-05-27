/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			Edwin Casa			2026-03-17		58802		Initial Code - Update tables GuiasHouse of transmission process
*/
DECLARE @IdRegistro VARCHAR(16),
@idUser VARCHAR(16) = 'PImHbTZw',
@IdMenu VARCHAR(16),
@menuRecepcion VARCHAR(64) = 'Recepción',
@menu VARCHAR(64) = 'Asignación de código de Relación Entidad',
@menuEng VARCHAR(64) = 'Assign Entity Relation Code'

IF NOT EXISTS(SELECT 1 FROM Menu WHERE nombre = @menu AND accion = 'INSERTAR')
BEGIN 
	SELECT  @IdMenu = id FROM Menu WHERE nombre = 'Recepción' AND idPadre = '0'
	EXEC dbo.PRO_General_GenerarIdUnico @tabla = 'Menu',  @IdUnico = @IdRegistro OUTPUT
	INSERT INTO Menu (
		id, 
		idPadre, 
		idUsuarioLog, 
		nombre, 
		nombreIngles,
		[url],
		accion, 
		orden, 
		esMenu, 
		fechaCambio, 
		[status], 
		instruccion,
		esNewTab, 
		nota
		)
	VALUES
	(
		@IdRegistro, 
		@IdMenu, 
		@idUser, 
		@menu, 
		@menuEng, 
		'setEntitiesToHomologate',
		'INSERTAR', 
		1, 
		0,  
		GETDATE(), 
		'ACTIVO', 
		'INSERTAR',
		0,
		'Permiso para homologar entidades'
	)
END

/*
select * from Menu order by fechaCambio desc

//delete from Menu where id = 'MNU07665'
*/
