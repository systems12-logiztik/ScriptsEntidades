/*     
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		 MODIFICATION
1		    Marlon Pizarro	    2026-05-16	    55188    Update language names
*/

UPDATE IDI
SET IDI.Nombre = 'INGLES'
FROM dbo.Idiomas IDI
WHERE IDI.Nombre = 'ENGLISH'

UPDATE IDI
SET IDI.Nombre = 'CHINO'
FROM dbo.Idiomas IDI
WHERE IDI.Nombre = 'CHINA'

UPDATE IDI
SET IDI.Nombre = 'RUSO'
FROM dbo.Idiomas IDI
WHERE IDI.Nombre = 'RUSIA'

UPDATE IDI
SET IDI.NombreIngles = 'CHINESE'
FROM dbo.Idiomas IDI
WHERE IDI.NombreIngles = 'CHINA'

