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







--Importacion de la hoja 'Grupo Familiar'

CREATE OR ALTER PROCEDURE ImportarGrupoFamiliar
    @RutaArchivo NVARCHAR(256),
    @NombreHoja NVARCHAR(256)  -- Ejemplo: 'Grupo Familiar$'
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #TempGrupoFamiliar (
        NroSocio VARCHAR(20),
        NroSocioRP VARCHAR(20),
        Nombre VARCHAR(50),
        Apellido VARCHAR(50),
        DNI VARCHAR(15),
        Email VARCHAR(100),
        FechaNacimiento DATE,
        TelefonoContacto VARCHAR(20),
        ObraSocial VARCHAR(100),
        NroObraSocial VARCHAR(30)
    );

    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
        INSERT INTO #TempGrupoFamiliar
        SELECT 
            [Nro de Socio],
            [Nro de socio RP],
            [Nombre],
            [ apellido],
            [ DNI],
            [ email personal],
            [ fecha de nacimiento],
            [ teléfono de contacto],
            [ Nombre de la obra social o prepaga],
            [nro# de socio obra social/prepaga]
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.16.0'',
            ''Excel 12.0;Database=' + @RutaArchivo + ';HDR=YES;IMEX=1'',
            ''SELECT * FROM [' + @NombreHoja + ']''
        );
    ';
    EXEC sp_executesql @SQL;

    INSERT INTO Person.Persona (Nombre, Apellido, DNI, Email, Fecha_Nacimiento, Telefono_Contacto)
    SELECT DISTINCT
        Nombre, Apellido, DNI, Email, FechaNacimiento, TelefonoContacto
    FROM #TempGrupoFamiliar t
    WHERE NOT EXISTS (
        SELECT 1 FROM Person.Persona p 
        WHERE p.DNI COLLATE Latin1_General_CI_AS = t.DNI
    );

    INSERT INTO Person.Socio (Id_Socio, Id_Persona, Id_Categoria, Telefono_Emergencia, Obra_Social, Nro_Obra_Social)
    SELECT
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + ISNULL((SELECT MAX(Id_Socio) FROM Person.Socio), 0),
        p.Id_Persona,
        100,
        NULL,
        t.ObraSocial,
        t.NroObraSocial
    FROM #TempGrupoFamiliar t
    JOIN Person.Persona p ON p.DNI COLLATE Latin1_General_CI_AS = t.[DNI]
    WHERE NOT EXISTS (
        SELECT 1 FROM Person.Socio s WHERE s.Id_Persona = p.Id_Persona
    );

    IF NOT EXISTS (SELECT 1 FROM Groups.Grupo_Familiar WHERE Nombre_Familia = 'FAMILIA GENÉRICA')
    BEGIN
        INSERT INTO Groups.Grupo_Familiar (Nombre_Familia, Activo)
        VALUES ('FAMILIA GENÉRICA', 1);
    END

    INSERT INTO Groups.Miembro_Familia (Id_Socio, Id_Familia)
    SELECT
        s.Id_Socio,
        f.Id_Grupo_Familiar
    FROM #TempGrupoFamiliar t
    JOIN Person.Persona p ON p.DNI COLLATE Latin1_General_CI_AS = t.[DNI]
    JOIN Person.Socio s ON s.Id_Persona = p.Id_Persona
    JOIN Groups.Grupo_Familiar f ON f.Nombre_Familia = 'FAMILIA GENÉRICA'
    WHERE NOT EXISTS (
        SELECT 1 FROM Groups.Miembro_Familia mf WHERE mf.Id_Socio = s.Id_Socio
    );

    DROP TABLE #TempGrupoFamiliar;
END;


EXEC ImportarGrupoFamiliar
    @RutaArchivo = 'C:\Users\Administrador\Documents\Facultad\BDDA\TP_BDDA\BBDDA_Grupo_12\Datos socios.xlsx',
    @NombreHoja = 'Grupo Familiar$';



--Me permite ver los headers del excel
	SELECT TOP 1 * 
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;Database=C:\Importaciones\Datos_socios.xlsx;HDR=YES;IMEX=1',
    'SELECT * FROM [Grupo Familiar$]'
);



--Select para ver que me trae los datos
SELECT 
    [ email personal],
    [ fecha de nacimiento],
    [ teléfono de contacto],
    [ Nombre de la obra social o prepaga],
    [nro# de socio obra social/prepaga]
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;Database=C:\Importaciones\Datos_socios.xlsx;HDR=YES;IMEX=1',
    'SELECT * FROM [Grupo Familiar$]'
);







EXEC sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'AllowInProcess', 1;

EXEC sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'DynamicParameters', 1;




	sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'AllowInProcess', 1;
    
EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'DynamicParameters', 1;