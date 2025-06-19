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
GO

CREATE OR ALTER PROCEDURE Activity.Importar_Actividades
    @RutaArchivo NVARCHAR(256),
    @NombreHoja NVARCHAR(128),
    @RangoCeldas NVARCHAR(50) -- Ej: 'A1:C7'
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Tabla temporal para importar el rango
        CREATE TABLE #TempActividades (
            Actividad NVARCHAR(100),
            ValorPorMes DECIMAL(18,2),
            Vigente_Hasta DATE
        );

        -- Importar desde Excel
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = '
            INSERT INTO #TempActividades
            SELECT 
                [Actividad], 
                [Valor por mes], 
                TRY_CONVERT(DATE, [Vigente hasta], 103)
            FROM OPENROWSET(
                ''Microsoft.ACE.OLEDB.16.0'',
                ''Excel 12.0;Database=' + @RutaArchivo + ';HDR=YES;IMEX=1'',
                ''SELECT * FROM [' + @NombreHoja + '$' + @RangoCeldas + ']'' 
            );';
        EXEC sp_executesql @SQL;

        -- Generar EXECs como string dinámico
        DECLARE @Dinamico NVARCHAR(MAX) = '';

        SELECT @Dinamico += '
        BEGIN TRY
            EXEC Activity.Agr_Actividad 
                @Nombre_Actividad = ''' + REPLACE(TRIM(Actividad), '''', '''''') + ''',
                @Desc_Act = ''Importado desde Excel'',
                @Costo = ' + CAST(ValorPorMes AS VARCHAR) + ',
                @Vigente_Hasta = ''' + CONVERT(VARCHAR, Vigente_Hasta, 23) + ''';
        END TRY
        BEGIN CATCH
            PRINT ''Error al importar: ' + REPLACE(TRIM(Actividad), '''', '''''') + ' => '' + ERROR_MESSAGE();
        END CATCH;'
        FROM #TempActividades
        WHERE Actividad IS NOT NULL AND ValorPorMes IS NOT NULL AND Vigente_Hasta IS NOT NULL;

        -- Ejecutar bloque
        EXEC sp_executesql @Dinamico;

        -- Limpiar
        DROP TABLE #TempActividades;

        PRINT 'Importación de actividades completada.';
    END TRY
    BEGIN CATCH
        PRINT 'Error general en la importación: ' + ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Groups.Importar_Categorias
    @RutaArchivo NVARCHAR(256),
    @NombreHoja NVARCHAR(128),
    @RangoCeldas NVARCHAR(50)  -- Ej: 'B1:D4'
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Tabla temporal para importar
        CREATE TABLE #TempCategorias (
            NombreCat NVARCHAR(50),
            ValorCuota DECIMAL(18,2),
            VigenteHasta DATE
        );

        -- Importar desde Excel
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = '
            INSERT INTO #TempCategorias
            SELECT 
                [Categoria socio],
                [Valor cuota],
                TRY_CONVERT(DATE, [Vigente hasta], 103)
            FROM OPENROWSET(
                ''Microsoft.ACE.OLEDB.16.0'',
                ''Excel 12.0;Database=' + @RutaArchivo + ';HDR=YES;IMEX=1'',
                ''SELECT * FROM [' + @NombreHoja + '$' + @RangoCeldas + ']'' 
            );';
        EXEC sp_executesql @SQL;

        -- Generar ejecución dinámica por categoría
        DECLARE @Dinamico NVARCHAR(MAX) = '';

        SELECT @Dinamico += '
        BEGIN TRY
            EXEC Groups.Agr_Categoria 
                @Nombre_Cat = ''' + REPLACE(TRIM(NombreCat), '''', '''''') + ''',
                @Edad_Min = ' + 
                    CASE 
                        WHEN NombreCat = 'Mayor' THEN '18'
                        WHEN NombreCat = 'Cadete' THEN '13'
                        WHEN NombreCat = 'Menor' THEN '0'
                        ELSE '0'
                    END + ',
                @Edad_Max = ' + 
                    CASE 
                        WHEN NombreCat = 'Mayor' THEN '99'
                        WHEN NombreCat = 'Cadete' THEN '17'
                        WHEN NombreCat = 'Menor' THEN '12'
                        ELSE '0'
                    END + ',
                @Descr = ''Importado desde Excel'',
                @Costo = ' + CAST(ValorCuota AS VARCHAR) + ';
        END TRY
        BEGIN CATCH
            PRINT ''Error al importar categoría: ' + REPLACE(TRIM(NombreCat), '''', '''''') + ' => '' + ERROR_MESSAGE();
        END CATCH;'
        FROM #TempCategorias
        WHERE NombreCat IS NOT NULL AND ValorCuota IS NOT NULL;

        EXEC sp_executesql @Dinamico;

        DROP TABLE #TempCategorias;
        PRINT 'Importación de categorías completada.';
    END TRY
    BEGIN CATCH
        PRINT 'Error general en la importación: ' + ERROR_MESSAGE();
    END CATCH
END

