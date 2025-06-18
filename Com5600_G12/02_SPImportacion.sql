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
    @RutaArchivo NVARCHAR(256),
    @NombreHoja NVARCHAR(256)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Tabla temporal
        CREATE TABLE #TempResponsables (
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

        -- Variable @SQL (solo una vez)
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = '
            INSERT INTO #TempResponsables
            SELECT 
                [Nro de Socio],
                [Nombre],
                [ apellido],
                RIGHT(''0000000000'' + CAST(CAST([ DNI] AS BIGINT) AS VARCHAR(20)), 8),
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

        -- Insertar en Persona
        INSERT INTO Person.Persona (Nombre, Apellido, DNI, Email, Fecha_Nacimiento, Telefono_Contacto)
        SELECT DISTINCT
            Nombre, Apellido, DNI, Email, FechaNacimiento, TelefonoContacto
        FROM #TempResponsables t
        WHERE NOT EXISTS (
            SELECT 1 FROM Person.Persona p 
            WHERE p.DNI COLLATE Latin1_General_CI_AS = t.DNI COLLATE Latin1_General_CI_AS
        );

        -- Insertar en Socio
        INSERT INTO Person.Socio (
    Id_Socio, Id_Persona, Id_Categoria, Id_Tutor, 
    Telefono_Emergencia, Obra_Social, Nro_Obra_Social
)
SELECT
    t.NroSocioRP,
    p.Id_Persona,
    100,
    NULL,
    NULL,
    t.ObraSocial,
    t.NroObraSocial
FROM #TempResponsables t
JOIN Person.Persona p 
    ON p.DNI COLLATE Latin1_General_CI_AS = t.DNI COLLATE Latin1_General_CI_AS
WHERE NOT EXISTS (
    SELECT 1
    FROM Person.Socio s
    WHERE 
        s.Id_Persona = p.Id_Persona
        OR s.Id_Socio COLLATE Latin1_General_CI_AS = t.NroSocioRP COLLATE Latin1_General_CI_AS
);

        -- Insertar en Tutor
        INSERT INTO Person.Tutor (Id_Persona, Parentesco)
        SELECT DISTINCT
            P.Id_Persona,
            'Responsable'
        FROM #TempResponsables T
        JOIN Person.Persona P 
            ON P.DNI COLLATE Latin1_General_CI_AS = T.DNI COLLATE Latin1_General_CI_AS
        WHERE NOT EXISTS (
            SELECT 1 FROM Person.Tutor TU WHERE TU.Id_Persona = P.Id_Persona
        );

        DROP TABLE #TempResponsables;
        PRINT 'Importación de responsables exitosa.';
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
    @RutaArchivo = 'C:\Users\Administrador\Documents\Facultad\BDDA\TP_BDDA\BBDDA_Grupo_12\Datos socios.xlsx',
    @NombreHoja = 'Responsables de Pago$';

SELECT * FROM Person.Persona
SELECT * FROM Person.Socio

GO



--Importacion de la hoja 'Grupo Familiar'

CREATE OR ALTER PROCEDURE ImportarGrupoFamiliar
    @RutaArchivo NVARCHAR(256),
    @NombreHoja NVARCHAR(256)  -- Ejemplo: 'Grupo Familiar$'
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #TempGrupoFamiliar (
        Id_Socio VARCHAR(20),
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
            RIGHT(''0000000000'' + CAST(CAST([ DNI] AS BIGINT) AS VARCHAR(20)), 8),
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

    -- Insertar en Persona
    INSERT INTO Person.Persona (Nombre, Apellido, DNI, Email, Fecha_Nacimiento, Telefono_Contacto)
    SELECT DISTINCT
        Nombre, Apellido, DNI, Email, FechaNacimiento, TelefonoContacto
    FROM #TempGrupoFamiliar t
    WHERE NOT EXISTS (
        SELECT 1 FROM Person.Persona p 
        WHERE p.DNI COLLATE Latin1_General_CI_AS = t.DNI COLLATE Latin1_General_CI_AS
    );

    -- Insertar en Socio
    INSERT INTO Person.Socio (Id_Socio, Id_Persona, Id_Categoria, Telefono_Emergencia, Obra_Social, Nro_Obra_Social)
    SELECT
        t.Id_Socio,
        p.Id_Persona,
        100,
        NULL,
        t.ObraSocial,
        t.NroObraSocial
    FROM #TempGrupoFamiliar t
    JOIN Person.Persona p ON p.DNI = t.DNI COLLATE Latin1_General_CI_AS
    WHERE NOT EXISTS (
        SELECT 1 FROM Person.Socio s 
        WHERE s.Id_Socio COLLATE Latin1_General_CI_AS = t.Id_Socio COLLATE Latin1_General_CI_AS
    );

    -- Asignar Id_Tutor a los socios del grupo familiar
    UPDATE S
    SET S.Id_Tutor = T.Id_Tutor
    FROM Person.Socio S
    JOIN #TempGrupoFamiliar TG
        ON S.Id_Socio COLLATE Latin1_General_CI_AS = TG.Id_Socio COLLATE Latin1_General_CI_AS
    JOIN Person.Socio STutor
        ON STutor.Id_Socio COLLATE Latin1_General_CI_AS = TG.NroSocioRP COLLATE Latin1_General_CI_AS
    JOIN Person.Tutor T
        ON T.Id_Persona = STutor.Id_Persona
    WHERE S.Id_Tutor IS NULL;

	/*
    -- Lógica para Grupo_Familiar (opcional)
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
    JOIN Person.Persona p ON p.DNI COLLATE Latin1_General_CI_AS = t.DNI COLLATE Latin1_General_CI_AS
    JOIN Person.Socio s ON s.Id_Persona = p.Id_Persona
    JOIN Groups.Grupo_Familiar f ON f.Nombre_Familia = 'FAMILIA GENÉRICA'
    WHERE NOT EXISTS (
        SELECT 1 FROM Groups.Miembro_Familia 
        WHERE Id_Socio COLLATE Latin1_General_CI_AS = s.Id_Socio COLLATE Latin1_General_CI_AS
    );
	*/
    

    DROP TABLE #TempGrupoFamiliar;
    PRINT 'Importación de grupo familiar exitosa.';
END;





DELETE FROM Groups.Miembro_Familia WHERE Id_Socio = 'SN-4121';
DELETE FROM Person.Socio WHERE Id_Socio = 'SN-4121';



DELETE FROM Groups.Miembro_Familia;
DELETE FROM Person.Socio;
DELETE FROM Person.Persona;
DELETE FROM Person.Tutor;
select * from Person.Persona
select * from Person.Socio 
select * from Person.Tutor
select * from Groups.Miembro_Familia

SELECT * FROM Person.Socio WHERE Id_Socio = 'SN-4121';



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
	[Nro de Socio],
	[Nombre],
	[ DNI],
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

