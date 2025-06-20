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

		CREATE TABLE #DNI_Repetidos (
		DNI VARCHAR(15)
		);


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
		SELECT 
			t.Nombre, t.Apellido, t.DNI, t.Email, t.FechaNacimiento, t.TelefonoContacto
		FROM #TempResponsables t
		WHERE NOT EXISTS (
			SELECT 1 FROM Person.Persona p 
			WHERE p.DNI COLLATE Latin1_General_CI_AS = t.DNI COLLATE Latin1_General_CI_AS
		)
		AND t.DNI IN (
			SELECT DNI
			FROM #TempResponsables
			GROUP BY DNI
			HAVING COUNT(*) = 1  -- Solo DNI no duplicados
		);
		PRINT 'Los siguientes DNIs están duplicados en el archivo y no fueron insertados:';
		SELECT DNI, COUNT(*) AS Cantidad
		FROM #TempResponsables
		GROUP BY DNI
		HAVING COUNT(*) > 1;


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
			WHERE s.Id_Socio COLLATE Latin1_General_CI_AS = t.NroSocioRP COLLATE Latin1_General_CI_AS
			OR s.Id_Persona = p.Id_Persona
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
CREATE OR ALTER PROCEDURE Groups.ImportarGrupoFamiliar
    @RutaArchivo NVARCHAR(256),
    @NombreHoja NVARCHAR(256)  -- Ejemplo: 'Grupo Familiar$'
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #DNI_Repetidos (
        DNI VARCHAR(15)
    );

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
    DECLARE @Nombre VARCHAR(25), @Apellido VARCHAR(25), @DNI VARCHAR(10),
            @Email VARCHAR(50), @FechaNacimiento DATE, @TelefonoContacto VARCHAR(15);

    DECLARE cur CURSOR FOR
    SELECT Nombre, Apellido, DNI, Email, FechaNacimiento, TelefonoContacto
    FROM #TempGrupoFamiliar;

    OPEN cur;
    FETCH NEXT FROM cur INTO @Nombre, @Apellido, @DNI, @Email, @FechaNacimiento, @TelefonoContacto;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC Person.Agr_Persona
            @Nombre = @Nombre,
            @Apellido = @Apellido,
            @DNI = @DNI,
            @Email = @Email,
            @Fecha_Nacimiento = @FechaNacimiento,
            @Telefono_Contacto = @TelefonoContacto;

        FETCH NEXT FROM cur INTO @Nombre, @Apellido, @DNI, @Email, @FechaNacimiento, @TelefonoContacto;
    END

    CLOSE cur;
    DEALLOCATE cur;

    -- Guardar los que no se pudieron insertar por repetición
    INSERT INTO #DNI_Repetidos (DNI)
    SELECT DISTINCT t.DNI
    FROM #TempGrupoFamiliar t
    WHERE EXISTS (
        SELECT 1 FROM Person.Persona p 
        WHERE p.DNI COLLATE Latin1_General_CI_AS = t.DNI COLLATE Latin1_General_CI_AS
    );

    -- Insertar en Socio con cálculo de categoría por edad
    INSERT INTO Person.Socio (
        Id_Socio, Id_Persona, Id_Categoria, Telefono_Emergencia, Obra_Social, Nro_Obra_Social
    )
    SELECT
        t.Id_Socio,
        p.Id_Persona,
        c.Id_Categoria,
        NULL,
        t.ObraSocial,
        t.NroObraSocial
    FROM #TempGrupoFamiliar t
    JOIN Person.Persona p 
        ON p.DNI COLLATE Latin1_General_CI_AS = t.DNI COLLATE Latin1_General_CI_AS
    JOIN Groups.Categoria c
        ON (
            DATEDIFF(YEAR, t.FechaNacimiento, GETDATE()) 
            - CASE WHEN MONTH(t.FechaNacimiento) > MONTH(GETDATE()) 
                     OR (MONTH(t.FechaNacimiento) = MONTH(GETDATE()) AND DAY(t.FechaNacimiento) > DAY(GETDATE())) 
                   THEN 1 ELSE 0 END
        ) BETWEEN c.EdadMin AND c.EdadMax
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

    -- Grupo familiar
    INSERT INTO Groups.Grupo_Familiar (Nombre_Familia, Activo)
    SELECT 
        'Familia ' + p.Apellido AS Nombre_Familia,
        1 AS Activo
    FROM Person.Tutor t
    JOIN Person.Persona p ON p.Id_Persona = t.Id_Persona
    WHERE NOT EXISTS (
        SELECT 1
        FROM Groups.Grupo_Familiar gf
        WHERE gf.Nombre_Familia = 'Familia ' + p.Apellido
    );

    -- Miembros de familia
    INSERT INTO Groups.Miembro_Familia (Id_Socio, Id_Familia)
    SELECT
        s.Id_Socio,
        gf.Id_Grupo_Familiar
    FROM Person.Socio s
    JOIN Person.Tutor t ON t.Id_Tutor = s.Id_Tutor
    JOIN Person.Persona p ON p.Id_Persona = t.Id_Persona
    JOIN Groups.Grupo_Familiar gf ON gf.Nombre_Familia = 'Familia ' + p.Apellido
    WHERE NOT EXISTS (
        SELECT 1
        FROM Groups.Miembro_Familia mf
        WHERE mf.Id_Socio = s.Id_Socio
    );

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
GO

CREATE OR ALTER PROCEDURE Activity.Importar_Costos_Actividad_Extra
    @RutaArchivo NVARCHAR(256),
    @NombreHoja NVARCHAR(128),
    @RangoCeldas NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Tabla temporal genérica
        CREATE TABLE #TmpExcel (
            F1 NVARCHAR(50),  -- Tipo_Valor
            F2 NVARCHAR(50),  -- Categoria
            F3 NVARCHAR(50),  -- Socios
            F4 NVARCHAR(50),  -- Invitados
            F5 NVARCHAR(50)   -- Fecha
        );

        -- Cargar desde Excel
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = '
            INSERT INTO #TmpExcel (F1, F2, F3, F4, F5)
            SELECT * 
            FROM OPENROWSET(
                ''Microsoft.ACE.OLEDB.16.0'',
                ''Excel 12.0;HDR=NO;IMEX=1;Database=' + @RutaArchivo + ''',
                ''SELECT * FROM [' + @NombreHoja + '$' + @RangoCeldas + ']''
            );';
        EXEC sp_executesql @SQL;

        -- Tabla intermedia con propagación del tipo
        WITH DatosConTipo AS (
            SELECT 
                Tipo_Valor = 
                    ISNULL(NULLIF(F1, ''), 
                        LAST_VALUE(NULLIF(F1, '')) 
                        IGNORE NULLS OVER (ORDER BY (SELECT NULL) 
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)),
                Categoria = F2,
                Socios = TRY_CAST(REPLACE(REPLACE(REPLACE(F3, '$', ''), '.', ''), ',', '.') AS DECIMAL(18,2)),
                Invitados = TRY_CAST(REPLACE(REPLACE(REPLACE(F4, '$', ''), '.', ''), ',', '.') AS DECIMAL(18,2)),
                Vigente_Hasta = TRY_CONVERT(DATE, F5, 103)
            FROM #TmpExcel
        )

        -- Insertar directamente
        INSERT INTO Activity.Costo_Actividad_Extra (Tipo_Valor, Categoria, Costo_Socios, Costo_Invitados, Vigente_Hasta)
        SELECT Tipo_Valor, Categoria, Socios, Invitados, Vigente_Hasta
        FROM DatosConTipo
        WHERE Categoria IS NOT NULL AND Vigente_Hasta IS NOT NULL;

        DROP TABLE #TmpExcel;

        PRINT 'Importación completada con éxito.';
    END TRY
    BEGIN CATCH
        PRINT 'Error en la importación: ' + ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Activity.Importar_Asistencia
    @RutaArchivo NVARCHAR(256),
    @NombreHoja NVARCHAR(128)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Tabla temporal para importar el rango
        CREATE TABLE #TempAsistencia (
			Id_Socio VARCHAR(20),
			Actividad VARCHAR(20),
			Fecha DATE,
			Asistencia CHAR(1),
			Profesor VARCHAR(50)
        );

        -- Importar desde Excel
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = '
            INSERT INTO #TempAsistencia
            SELECT 
                [Nro de Socio], 
                [Actividad], 
                TRY_CONVERT(DATE, [Fecha de asistencia], 103),
				[Asistencia]
				[Profesor]
            FROM OPENROWSET(
                ''Microsoft.ACE.OLEDB.16.0'',
                ''Excel 12.0;Database=' + @RutaArchivo + ';HDR=YES;IMEX=1'',
                ''SELECT * FROM [' + @NombreHoja + ']'' 
            );';
		EXEC sp_executesql @SQL
		
		DECLARE 
		    @Id_Socio VARCHAR(20),
			@Actividad VARCHAR(20),
			@Fecha DATE,
			@Asistencia CHAR(1),
			@Profesor VARCHAR(50)

		WHILE EXISTS(SELECT 1 FROM #TempAsistencia)
		BEGIN
			SELECT TOP 1
				@Id_Socio = TRIM(Id_Socio),
				@Actividad = TRIM(Actividad),
				@Fecha = Fecha,
				@Asistencia = Asistencia,
				@Profesor = TRIM(Profesor)
			FROM #TempAsistencia

			EXEC Activity.Agr_Asistencia
				@Id_Socio,
				@Actividad,
				@Fecha,
				@Asistencia,
				@Profesor

			DELETE TOP (1) FROM #TempAsistencia
			WHERE	@Id_Socio = Id_Socio
			  AND 	@Actividad = Actividad
			  AND	@Fecha = Fecha
			  AND	@Asistencia = Asistencia
			  AND   @Profesor = Profesor
		END
		DROP TABLE #TempAsistencia
	END TRY
    BEGIN CATCH
        RAISERROR('Error en la importacion',16,1)
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Payment.Importar_Pagos
    @RutaArchivo NVARCHAR(256),
    @NombreHoja NVARCHAR(128)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Tabla temporal para importar el rango
        CREATE TABLE #TempPagos (
			Id_Pago INT,
			Fecha DATE,
			Responsable VARCHAR(20),
			Valor DECIMAL(10,2),
			Medio VARCHAR(50)
        );

        -- Importar desde Excel
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = '
            INSERT INTO #TempAsistencia
            SELECT 
                [Id de pago],  
                TRY_CONVERT(DATE, [fecha], 103),
				[Responsable de pago]
				[Valor]
				[Medio de pago]
            FROM OPENROWSET(
                ''Microsoft.ACE.OLEDB.16.0'',
                ''Excel 12.0;Database=' + @RutaArchivo + ';HDR=YES;IMEX=1'',
                ''SELECT * FROM [' + @NombreHoja + ']'' 
            );';
		EXEC sp_executesql @SQL
		
		DECLARE 
			@Id_Pago INT,
			@Fecha DATE,
			@Responsable VARCHAR(20),
			@Valor DECIMAL(10,2),
			@Medio VARCHAR(50)

		WHILE EXISTS(SELECT 1 FROM #TempPagos)
		BEGIN
			SELECT TOP 1
				@Id_Pago = Id_Pago,
				@Responsable = TRIM(Responsable),
				@Fecha = Fecha,
				@Valor = Valor,
				@Medio = TRIM(Medio)
			FROM #TempPagos

			EXEC Payment.Agr_Pago
				@Id_Socio = @Responsable,
				@Id_Pago = @Id_Pago,
				@Id_Factura = NULL,
				@Fecha_Pago = @Fecha,
				@Medio_Pago = @Medio,
				@Monto = @Valor,
				@Reembolso = 0,
				@Cantidad_Pago = 0,
				@Pago_Cuenta = 0

			DELETE TOP (1) FROM #TempPagos
			WHERE @Id_Pago = Id_Pago
			  AND @Responsable = TRIM(Responsable)
			  AND @Fecha = Fecha
			  AND @Valor = Valor
			  AND @Medio = TRIM(Medio)
		END
		DROP TABLE #TempPagos
	END TRY
    BEGIN CATCH
        RAISERROR('Error en la importacion',16,1)
    END CATCH
END