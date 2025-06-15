------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico 43316258
--Medina, Juan 46682620
--Mennella, Elias Damian 46357008
----------------------------------------------------------------

--Creacion de stored Procedures para la importacion de datos--

USE master

USE Com5600_G12
GO


-- Desactivamos adHoc para poder importar las tablas de excel --

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries';

GO
-- Importacion de la hoja de responsables de pago --

CREATE OR ALTER PROCEDURE ImportarExcelSocios
    @ExcelSocios NVARCHAR(256),
	@Hoja NVARCHAR(256)
AS
BEGIN
	CREATE TABLE #ExcelImport (
    NroSocio VARCHAR(25),
    Nombre VARCHAR(25),
    Apellido VARCHAR(25),
	DNI INT,
	Email VARCHAR(25),

    )
    DECLARE @Importacion NVARCHAR(MAX);
    SET @Importacion = '
        SELECT * FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;Database=' + @ExcelSocios + ';HDR=YES'',
            ''SELECT * FROM '''+ @Hoja + '''
        );
    ';
    EXEC sp_executesql @Importacion;
END;




