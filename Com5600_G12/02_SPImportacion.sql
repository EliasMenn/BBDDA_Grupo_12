------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico 43316258
--Medina, Juan 46682620
--Mennella, Elias Damian 46357008
----------------------------------------------------------------

-- Creación de Stored Procedures para la importación de datos --

USE master

USE Com5600_G12
GO


-- Desactivamos adHoc para poder importar las tablas de excel --

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

GO

CREATE OR ALTER PROCEDURE Person.Importar_Responsables_Pago
    @NomArch NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Tabla temporal para bajar los datos del archivo
        CREATE TABLE #TempResponsables (
            [Nro de Socio] NVARCHAR(50),
            [Nombre] NVARCHAR(50),
            [ apellido] NVARCHAR(50),
            [ DNI] NVARCHAR(15),
            [ email personal] NVARCHAR(100),
            [ fecha de nacimiento] NVARCHAR(50),
            [ teléfono de contacto] NVARCHAR(25),
            [ teléfono de contacto emergencia ] NVARCHAR(25),
            [Nombre de la obra social o prepaga] NVARCHAR(150),
            [nro. de socio obra social/prepaga ] NVARCHAR(50),
            [teléfono de contacto de emergencia ] NVARCHAR(50)
        );

        -- SQL dinámico para trabajar con ruta como parámetro
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = '
            INSERT INTO #TempResponsables
            SELECT * FROM OPENROWSET(
                ''Microsoft.ACE.OLEDB.16.0'',
                ''Excel 12.0;Database=' + @NomArch + ';HDR=YES;IMEX=1'',
                ''SELECT * FROM [Responsables de Pago$]''
            );
        ';
        EXEC(@sql);

        -- Insertar en Persona si no existe el DNI
        INSERT INTO Person.Persona (Nombre, Apellido, DNI, Email, Fecha_Nacimiento, Telefono_Contacto)
        SELECT DISTINCT
            TRIM(CONVERT(NVARCHAR(50), [Nombre])),
            TRIM(CONVERT(NVARCHAR(50), [ apellido])),
            TRIM(CONVERT(NVARCHAR(15), [ DNI])),
            TRIM(CONVERT(NVARCHAR(100), [ email personal])),
            TRY_CONVERT(DATE, [ fecha de nacimiento], 103),
            TRIM(CONVERT(NVARCHAR(25), [ teléfono de contacto]))
        FROM #TempResponsables
        WHERE NOT EXISTS (
            SELECT 1 
            FROM Person.Persona P 
            WHERE P.DNI COLLATE Latin1_General_CI_AS = TRIM(CONVERT(NVARCHAR(15), [ DNI])) COLLATE Latin1_General_CI_AS
        );
    ';
    EXEC sp_executesql @Importacion;
END;



        -- Insertar en Socio si no existe el Id_Persona ni el Id_Socio
	INSERT INTO Person.Socio (
		Id_Socio, Id_Persona, Id_Categoria, Id_Tutor, 
		Telefono_Emergencia, Obra_Social, Nro_Obra_Social
	)
	SELECT
		CAST(SUBSTRING(TRIM([Nro de Socio]), 4, LEN(TRIM([Nro de Socio]))) AS INT) AS Id_Socio,
		P.Id_Persona,
		100, -- Categorías
		NULL,
		TRIM(CONVERT(NVARCHAR(25), [ teléfono de contacto emergencia])),
		TRIM(CONVERT(NVARCHAR(100), [Nombre de la obra social o prepaga])),
		TRIM(CONVERT(NVARCHAR(50), [nro. de socio obra social/prepaga ]))
	FROM #TempResponsables T
	JOIN Person.Persona P
		ON P.DNI COLLATE Latin1_General_CI_AS = TRIM(CONVERT(NVARCHAR(15), T.[ DNI])) COLLATE Latin1_General_CI_AS
	WHERE NOT EXISTS (
		SELECT 1
		FROM Person.Socio S
		WHERE 
			S.Id_Persona = P.Id_Persona
			OR S.Id_Socio = CAST(SUBSTRING(TRIM(T.[Nro de Socio]), 4, LEN(TRIM(T.[Nro de Socio]))) AS INT)
	);

        PRINT 'Importación exitosa.';
    END TRY
    BEGIN CATCH
        PRINT 'Error durante la importación: ' + ERROR_MESSAGE();
    END CATCH
END;

-- Categorias para probar
INSERT INTO Groups.Categoria (Nombre_Cat, EdadMin, EdadMax, Descr, Costo)
VALUES 
    ('Infantil', 0, 12, 'Niños hasta 12 años', 500.00),
    ('Juvenil', 13, 17, 'Adolescentes hasta 17 años', 700.00),
    ('Adulto', 18, 64, 'Mayores de edad hasta 64', 1000.00);

EXEC Person.Importar_Responsables_Pago
    @NomArch = N'C:\Users\Pedro Melissari\Desktop\Archivos BDD\Datos socios.xlsx'; -- Acá va la ruta

SELECT * FROM Person.Persona
SELECT * FROM Person.Socio





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
            [ tel�fono de contacto],
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

    IF NOT EXISTS (SELECT 1 FROM Groups.Grupo_Familiar WHERE Nombre_Familia = 'FAMILIA GEN�RICA')
    BEGIN
        INSERT INTO Groups.Grupo_Familiar (Nombre_Familia, Activo)
        VALUES ('FAMILIA GEN�RICA', 1);
    END

    INSERT INTO Groups.Miembro_Familia (Id_Socio, Id_Familia)
    SELECT
        s.Id_Socio,
        f.Id_Grupo_Familiar
    FROM #TempGrupoFamiliar t
    JOIN Person.Persona p ON p.DNI COLLATE Latin1_General_CI_AS = t.[DNI]
    JOIN Person.Socio s ON s.Id_Persona = p.Id_Persona
    JOIN Groups.Grupo_Familiar f ON f.Nombre_Familia = 'FAMILIA GEN�RICA'
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
    [ tel�fono de contacto],
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
