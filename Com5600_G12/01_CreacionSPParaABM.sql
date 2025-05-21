------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico
--Medina, Juan 46682620
--Mennella, Elias Damian 46357008
----------------------------------------------------------------

USE master

USE Com5600_G12
GO


------------- CREACION DE STORE PROCEDURE -------------

-- ENUNCIADO: Genere store procedures para manejar la inserción, modificado, borrado de cada tabla. --

-- Para Tabla Persona --

CREATE OR ALTER PROCEDURE Person.Agr_Persona
	@Nombre VARCHAR(25),
	@Apellido VARCHAR(25),
	@DNI VARCHAR(10),
	@Email VARCHAR(50),
	@Fecha_Nacimiento DATE,
	@Telefono_Contacto VARCHAR(15)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		DECLARE @Id INT;
		--Validamos que no exista el mismo DNI--
		SELECT @Id = Id_Persona
		FROM Person.Persona
		WHERE DNI = @DNI;

		IF @Id IS NOT NULL
		BEGIN
			Print('Ya existe la persona con el DNI ingresado');
			RETURN @Id;  
		END
		--Limpiamos y Validamos los string--

		IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z]%' OR LEN(@Nombre) > 25
		BEGIN
			PRINT('El nombre no es valido')
			RAISERROR('.', 16,1)
		END
		SET @Nombre = TRIM(@Nombre);

		IF @Apellido ='' OR @Apellido LIKE '%[^a-zA-Z]%' OR LEN(@Apellido) > 25
		BEGIN
			PRINT('El apellido no es valido,')
			RAISERROR('.', 16,1)
		END
		SET @Apellido = TRIM(@Apellido);

		IF @DNI ='' OR @DNI LIKE '%[^0-9]%' OR LEN(@DNI) > 10
		BEGIN
			PRINT('El DNI no es valido.')
			RAISERROR('.', 16,1)
		END
			SET @DNI = TRIM(@DNI);

		IF @Email ='' OR @Email NOT LIKE '%@%.%' OR LEN(@Email) > 50
		BEGIN
			PRINT('El mail no es valido.')
			RAISERROR('.', 16,1)
		END
		SET @Email = TRIM(@Email);

		IF @Fecha_Nacimiento IS NULL OR (@Fecha_Nacimiento NOT BETWEEN '1930-01-01' AND GETDATE())
		BEGIN
			PRINT('La fecha de nacimiento no es valida.')
			RAISERROR('.', 16,1)
		END

		IF @Telefono_Contacto ='' OR @Telefono_Contacto LIKE '%[^0-9]%' OR LEN(@Telefono_Contacto) > 50
		BEGIN
			PRINT('El Telefono no es valido.')
			RAISERROR('.', 16,1)
		END
		SET @Telefono_Contacto = TRIM(@Telefono_Contacto);
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY()>10
		BEGIN	
			RAISERROR('Algo salio mal en el registro de persona',16,1);
			RETURN;
		END
	END CATCH

	INSERT INTO Person.Persona (Nombre, Apellido, DNI, Email, Fecha_Nacimiento, Telefono_Contacto)
	VALUES (@Nombre, @Apellido, @DNI, @Email, @Fecha_Nacimiento, @Telefono_Contacto)
	SET @Id = SCOPE_IDENTITY();
	RETURN @Id
END
GO


-- Para Tabla Socio --

CREATE OR ALTER PROCEDURE Person.Agr_Socio
	@Nombre VARCHAR (25),
	@Apellido VARCHAR (25),
	@DNI VARCHAR(10),
	@Email VARCHAR (50),
	@Fecha_Nacimiento DATE,
	@Telefono_Contacto VARCHAR(15),
	@Telefono_Contacto_Emg VARCHAR(15),
	@Obra_Social VARCHAR(25),
	@Nro_Socio_Obra VARCHAR(15),
	@Id_Tutor INTEGER
AS
BEGIN
	BEGIN TRY
		DECLARE @Id_Persona INT
		DECLARE @Id_Categoria INT
		DECLARE @Edad INT
		DECLARE @Id INT

		EXEC @Id_Persona= Person.Agr_Persona
		@Nombre = @Nombre,
		@Apellido = @Apellido,
		@Email = @Email,
		@Fecha_Nacimiento = @Fecha_Nacimiento,
		@Telefono_Contacto = @Telefono_Contacto,
		@DNI = @DNI
	
	--Verificamos que la persona no sea socio--

		SELECT @Id = Id_Socio
		FROM Person.Socio 
		WHERE Id_Persona = @Id_Persona

		IF @Id IS NOT NULL
		BEGIN 
			PRINT('Esta persona ya es socio');
			RETURN @Id
		END
	--Verificamos todos sus demas datos--
		IF @Telefono_Contacto_Emg ='' OR @Telefono_Contacto_Emg LIKE '%[^0-9]%' OR LEN(@Telefono_Contacto_Emg) > 50
		BEGIN
			PRINT('El Telefono no es valido');
			RAISERROR('.', 16,1)
		END

		SET @Telefono_Contacto_Emg = TRIM(@Telefono_Contacto_Emg);

		IF @Obra_Social LIKE '%[^a-zA-Z ]%' OR LEN(@Obra_Social) > 25
		BEGIN
			PRINT('La obra social no es valida');
			RAISERROR('.', 16,1)
		END

		SET @Obra_Social = TRIM(@Obra_Social);

		IF @Obra_Social LIKE ''
		BEGIN
			SET @Obra_Social = 'N/A'
		END 

		IF @Obra_Social NOT LIKE 'N/A' AND (@Nro_Socio_Obra LIKE '' OR  @Nro_Socio_Obra LIKE '%[^0-9]%' OR  LEN(@Nro_Socio_Obra) > 50)
		BEGIN
			PRINT('El numero no es valido.');
			RAISERROR('.', 16,1)
		END

		SET @Nro_Socio_Obra = TRIM(@Nro_Socio_Obra);

		IF @Obra_Social LIKE 'N/A'
		BEGIN
			SET @Nro_Socio_Obra = 'N/A'
		END

		SET @Edad = DATEDIFF(YEAR, @Fecha_Nacimiento, GETDATE());

		IF DATEADD(YEAR, @Edad, @Fecha_Nacimiento) > GETDATE()
		BEGIN
			SET @Edad = @Edad - 1;
		END

		IF @Edad > '18'
		BEGIN
			SET @Id_Tutor = 'N/A'
		END

		Else

		BEGIN
			IF NOT EXISTS (SELECT 1 FROM Person.Tutor WHERE Id_Tutor = @Id_Tutor)
			BEGIN
				PRINT('Tutor no existe para un socio menor de edad');
				RAISERROR('.', 16, 1);
			END
		END

		SELECT @Id_Categoria = Id_Categoria
		FROM Groups.Categoria
		WHERE @Edad BETWEEN EdadMin AND EdadMax

		IF @Id_Categoria IS NULL
		BEGIN
			PRINT('No se encontro una categoria valida');
			RAISERROR('.',16,1)
		END

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo en el registro de socio',16,1)
			RETURN;
		END
	END CATCH
	INSERT INTO Person.Socio (Id_Persona,Id_Categoria,Telefono_Emergencia,Obra_Social,Nro_Obra_Social,Id_Tutor)
	VALUES (@Id_Persona, @Id_Categoria, @Telefono_Contacto_Emg, @Obra_Social, @Nro_Socio_Obra, @Id_Tutor)
	SET @Id = SCOPE_IDENTITY();
	RETURN @Id
END
GO
-- Para Tabla tutor --

CREATE OR ALTER PROCEDURE Person.Agr_Tutor
	@Nombre VARCHAR (25),
	@Apellido VARCHAR (25),
	@DNI VARCHAR(10),
	@Email VARCHAR (50),
	@Fecha_Nacimiento DATE,
	@Telefono_Contacto VARCHAR(15),
	@Parentesco VARCHAR(20)
AS
BEGIN
	BEGIN TRY
		DECLARE @Id INT
		DECLARE @Id_Persona INT

		EXEC @Id_Persona= Person.Agr_Persona
		@Nombre = @Nombre,
		@Apellido = @Apellido,
		@Email = @Email,	
		@Fecha_Nacimiento = @Fecha_Nacimiento,
		@Telefono_Contacto = @Telefono_Contacto,
		@DNI = @DNI

		--Verificamos que no este registrado como tutor--

		SELECT @Id = Id_Tutor
		FROM Person.Tutor 
		WHERE Id_Persona = @Id_Persona

		IF @Id IS NOT NULL
		BEGIN 
			PRINT ('Esta persona ya es tutor')
			RETURN @Id
		END
		
		IF @Parentesco = '' OR @Parentesco LIKE '%[^a-zA-Z]%' OR LEN(@Parentesco) > 25
		BEGIN
			PRINT('El parentesco no es valido')
			RAISERROR('.',16,1)
		END

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo en el registro de socio',16,1)
			RETURN;
		END
	END CATCH

END