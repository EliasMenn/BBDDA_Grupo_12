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
	@Nombre VARCHAR(25),
	@Apellido VARCHAR(25),
	@DNI VARCHAR(10),
	@Email VARCHAR(50),
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
	@Nombre VARCHAR(25),
	@Apellido VARCHAR(25),
	@DNI VARCHAR(10),
	@Email VARCHAR(50),
	@Fecha_Nacimiento DATE,
	@Telefono_Contacto VARCHAR(15),
	@Parentesco VARCHAR(20)
AS
BEGIN
	BEGIN TRY
		DECLARE @Id INT
		DECLARE @Id_Persona INT

		SET @Parentesco = Trim(@Parentesco)

		IF @Parentesco = '' OR @Parentesco LIKE '%[^a-zA-Z]%' OR LEN(@Parentesco) > 25
		BEGIN
			PRINT('El parentesco no es valido')
			RAISERROR('.',16,1)
		END

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

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo en el registro de tutor',16,1)
			RETURN;
		END
	END CATCH
	INSERT INTO Person.Tutor(Id_Persona, Parentesco)
	VALUES (@Id_Persona, @Parentesco)
	SET @Id = SCOPE_IDENTITY();
	RETURN @Id
END
GO

-- Para Tabla Rol --

CREATE OR ALTER PROCEDURE Person.Agr_Rol
	@Id_Rol INT,
	@Nombre_Rol VARCHAR(25),
	@Descripcion VARCHAR(50)
AS
BEGIN
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM Person.Rol WHERE Id_Rol = @Id_Rol)
		BEGIN
			PRINT('Ya existe un rol con ese ID')
			RAISERROR('.',16,1)
		END

		IF TRY_CONVERT(INT, @Id_Rol) IS NULL
		BEGIN
			PRINT('Id Invalido')
			RAISERROR('-',16,1)
		END

		IF EXISTS (SELECT 1 FROM Person.Rol WHERE Nombre_Rol = @Nombre_Rol)
		BEGIN
			PRINT('Ya existe un rol con ese nombre')
			RAISERROR('.',16,1)
		END

		SET @Nombre_Rol = TRIM(@Nombre_Rol)

		IF @Nombre_Rol = '' OR @Nombre_Rol LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre_Rol) > 25
		BEGIN
			PRINT('Nombre de rol invalido')
			RAISERROR('.',16,1)
		END

		IF @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 25
		BEGIN
			PRINT('Descripcion invalida')
			RAISERROR('.',16,1)
		END

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo en la creacion de rol',16,1)
			RETURN;
		END
	END CATCH
	INSERT INTO Person.Rol(Id_Rol,Nombre_Rol,Desc_Rol)
	VALUES (@Id_Rol,@Nombre_Rol,@Descripcion)
END
GO

-- Para Tabla Usuario --

CREATE OR ALTER PROCEDURE Person.Agr_Usuario
	@Id_Rol INTEGER,
	@Id_Persona INTEGER,
	@Nombre_Usuario VARCHAR(30),
	@Contrasenia NVARCHAR(25)
AS
BEGIN
	BEGIN TRY
		DECLARE @ContraseniaHash VARBINARY(32)
		DECLARE @Vigencia DATE
		IF TRY_CONVERT(INT, @Id_Rol) IS NULL
		BEGIN 
			PRINT('El ID ingresado no es valido')
			RAISERROR('.',16,1)
		END
		IF NOT EXISTS (SELECT 1 FROM Person.Rol WHERE Id_Rol = @Id_Rol)
		BEGIN
			PRINT('No existe el rol solicitado')
			RAISERROR('.',16,1)
		END
		
		IF TRY_CONVERT(INT,@Id_Persona) IS NULL
		BEGIN 
			PRINT('El Identificador de persona no es valido')
			RAISERROR('.',16,1)
		END
		IF NOT EXISTS (SELECT 1 FROM Person.Persona WHERE Id_Persona = @Id_Persona)
		BEGIN
			PRINT('La persona ingresada no esta registrada')
			RAISERROR('.',16,1)
		END

		SET @Nombre_Usuario = TRIM(@Nombre_Usuario)
		IF @Nombre_Usuario = '' OR LEN(@Nombre_Usuario) > 30
		BEGIN 
			PRINT('El nombre de usuario no es valido')
			RAISERROR('.',16,1)
		END

		SET @Contrasenia = TRIM(@Contrasenia)
		IF @Contrasenia = '' OR @Contrasenia NOT LIKE '%[A-Z]%' OR @Contrasenia NOT LIKE '%[a-z]%' OR @Contrasenia NOT LIKE '%[0-9]%'
		BEGIN
			PRINT('La contraseña debe contener un caracter en mayuscula, uno en minuscula y un numero')
			RAISERROR('.',16,1)
		END 
		SET @Vigencia = DATEADD(YEAR,1,GETDATE())
		SET @ContraseniaHash = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(100), @Contrasenia))
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo en la creacion de Usuario',16,1)
			RETURN;
		END
	END CATCH
	INSERT INTO Person.Usuario (Id_Rol, Id_Persona,Nombre_Usuario,Contrasenia,Vigencia_Contrasenia)
	VALUES (@Id_Rol, @Id_Persona, @Nombre_Usuario, @ContraseniaHash, @Vigencia)
END
GO


		---- Para Tabal Groups ----
CREATE OR ALTER PROCEDURE Groups.Agr_Miembro_Familiar
	@Id_Socio INT,
	@Id_Grupo INT
AS
BEGIN
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Groups.Grupo_Familiar WHERE Id_Grupo_Familiar = @Id_Grupo)-- Validar existencia del grupo familiar
		BEGIN
			PRINT('El grupo familiar no existe')
			RAISERROR('hubo un error ya que no existe el grupo familiar', 16, 1)
		END

		IF NOT EXISTS (SELECT 1 FROM Person.Socio WHERE Id_Socio = @Id_Socio)-- Validar existencia del socio
		BEGIN
			PRINT('El socio no existe')
			RAISERROR('hubo un error ya que no existe el socio', 16, 1)
		END

		IF EXISTS (SELECT 1 FROM Groups.Miembro_Familia WHERE Id_Socio = @Id_Socio)-- Validar que el socio no pertenezca ya a un grupo
		BEGIN
			PRINT('El socio ya pertenece a un grupo familiar')
			RAISERROR('hubo un error ya que pertenece a un grupo familiar', 16, 1)
		END

		INSERT INTO Groups.Miembro_Familia (Id_Socio, Id_Familia)-- Insertar relación
		VALUES (@Id_Socio, @Id_Grupo)

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió un error al vincular el socio al grupo familiar', 16, 1)
			RETURN
		END
	END CATCH
END
GO



CREATE OR ALTER PROCEDURE Groups.Agr_Grupo_Familiar
	@Nombre_Familia VARCHAR(50),
	@Id_Socio INT  -- socio que se va a asociar al grupo recién creado
AS
BEGIN
	BEGIN TRY
		DECLARE @Id_Grupo INT

		SET @Nombre_Familia = TRIM(@Nombre_Familia)	-- Validación nombre
		IF @Nombre_Familia = '' OR LEN(@Nombre_Familia) > 50
		BEGIN
			PRINT('Nombre de familia inválido')
			RAISERROR('.', 16, 1)
		END

		
		IF NOT EXISTS (SELECT 1 FROM Person.Socio WHERE Id_Socio = @Id_Socio)-- Validar que el socio exista y no esté ya en un grupo
		BEGIN
			PRINT('El socio no existe')
			RAISERROR('.', 16, 1)
		END

		IF EXISTS (
			SELECT 1 FROM Groups.Miembro_Familia WHERE Id_Socio = @Id_Socio
		)
		BEGIN
			PRINT('El socio ya pertenece a un grupo familiar')
			RAISERROR('.', 16, 1)
		END

		INSERT INTO Groups.Grupo_Familiar (Nombre_Familia)-- Crear grupo
		VALUES (@Nombre_Familia)

		SET @Id_Grupo = SCOPE_IDENTITY()

		EXEC Groups.Agr_MiembroFamilia-- Asociar al socio al nuevo grupo
			@Id_Socio = @Id_Socio,
			@Id_Grupo = @Id_Grupo

		RETURN @Id_Grupo
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Error al crear grupo familiar', 16, 1)
			RETURN
		END
	END CATCH
END
GO

EXEC Person.Agr_Tutor
	@Nombre = 'Marcos',
	@Apellido = 'Fernandez',
	@DNI = '30444555',
	@Email = 'marcos.fernandez@gmail.com',
	@Fecha_Nacimiento = '1980-03-12',
	@Telefono_Contacto = '1122334455',
	@Parentesco = 'Padre';

SELECT * FROM Person.Socio
-- Crear socio
-- Socio mayor de edad (no necesita tutor)
EXEC Person.Agr_Socio
    @Nombre = 'Lucial',
    @Apellido = 'Fernandez',
    @DNI = '50223347',
    @Email = 'lucia.fernandez@gmail.com',
    @Fecha_Nacimiento = '2005-07-15',
    @Telefono_Contacto = '1166778899',
    @Telefono_Contacto_Emg = '1177665544',
    @Obra_Social = 'OSDE',
    @Nro_Socio_Obra = '123456',  -- Cambiar de '000000' a un número válido
    @Id_Tutor = NULL  -- IMPORTANTE: NULL para mayores de edad

-- Crear grupo familiar
EXEC Groups.Agr_GrupoFamiliar
	@Nombre_Familia = 'Fernandez',
	@Id_Socio = @Id_Socio;
