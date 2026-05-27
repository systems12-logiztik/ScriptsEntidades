/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			Edwin Casa			2026-03-17		58802		Script to insert general parameters to add range of update  ConsigneeId and BillToConsigneeId on homologate customers process
*/
DECLARE @idParametroGeneral INT 

IF NOT EXISTS(SELECT 1 
			FROM ParametrosGenerales 
			WHERE codigo = 'DateFromHomologateClients' AND idEmpresa = 'EMP014')
BEGIN
	SELECT 
	  @idParametroGeneral = MAX(id)+1 
	FROM ParametrosGenerales
	INSERT INTO ParametrosGenerales 
		(
			id, 
			codigo, 
			valor, 
			nota, 
			fechaCambio,
			idEmpresa
		)
	VALUES(
		@idParametroGeneral, 
		'DateFromHomologateClients', 
		'7', 
		'Initial day range for consulting House guides for homologation', 
		GETDATE(),
		'EMP014'
		)
END 

IF NOT EXISTS(SELECT 1 
			FROM ParametrosGenerales 
			WHERE codigo = 'DateToHomologateClients'AND idEmpresa = 'EMP014')
BEGIN
	SELECT 
	  @idParametroGeneral = MAX(id)+1 
	FROM ParametrosGenerales
	INSERT INTO ParametrosGenerales 
		(
			id, 
			codigo, 
			valor, 
			nota, 
			fechaCambio,
			idEmpresa
		)
	VALUES(
		@idParametroGeneral, 
		'DateToHomologateClients', 
		'7', 
		'Final date range for consulting GuiasHouse for homologation', 
		GETDATE(),
		'EMP014'
		)
END

IF NOT EXISTS(SELECT 1 
			FROM ParametrosGenerales 
			WHERE codigo = 'DateFromHomologateClients'AND idEmpresa = 'EMP015')
BEGIN
	SELECT 
	  @idParametroGeneral = MAX(id)+1 
	FROM ParametrosGenerales
	INSERT INTO ParametrosGenerales 
		(
			id, 
			codigo, 
			valor, 
			nota, 
			fechaCambio,
			idEmpresa
		)
	VALUES(
		@idParametroGeneral, 
		'DateFromHomologateClients', 
		'7', 
		'Initial day range for consulting GuiasHouse for homologation', 
		GETDATE(),
		'EMP015'
		)
END 

IF NOT EXISTS(SELECT 1 
			FROM ParametrosGenerales 
			WHERE codigo = 'DateToHomologateClients' AND idEmpresa = 'EMP015')
BEGIN
	SELECT 
	  @idParametroGeneral = MAX(id)+1 
	FROM ParametrosGenerales
	INSERT INTO ParametrosGenerales 
		(
			id, 
			codigo, 
			valor, 
			nota, 
			fechaCambio,
			idEmpresa
		)
	VALUES(
		@idParametroGeneral, 
		'DateToHomologateClients', 
		'7', 
		'Final date range for consulting GuiasHouse for homologation', 
		GETDATE(),
		'EMP015'
		)
END