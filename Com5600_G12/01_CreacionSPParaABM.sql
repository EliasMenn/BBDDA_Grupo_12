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
 -- Para la tabla Actividad --
CREATE OR ALTER PROCEDURE Activity.Agr_Actividad
	@Nombre_Actividad VARCHAR(50),
	@Desc_Act VARCHAR(50),
	@Costo DECIMAL
AS
BEGIN
	BEGIN TRY
		SET @Nombre_Actividad = TRIM(@Nombre_Actividad)

		IF @Nombre_Actividad = '' OR @Nombre_Actividad LIKE '%[^a-zA-Z]%'
		BEGIN
			PRINT('El nombre de la actividad no es valido.')
			RAISERROR('El nombre de la actividad no es valido.',16,1)
		END

		IF EXISTS (SELECT 1 FROM Activity.Actividad WHERE Nombre = @Nombre_Actividad)
		BEGIN
			PRINT('Ya existe una actividad con el mismo nombre.')
			RAISERROR('Ya existe una activdad con el mismo nombre.',16,1)
		END

		SET @Desc_Act = TRIM(@Desc_Act)
		IF @Desc_Act = '' OR @Desc_Act LIKE '%[^a-zA-Z ]%'
		BEGIN
			PRINT('La descripcion de la actividad no es valida.')
			RAISERROR('La descripcion de la actividad no es valida.',16,1)
		END

		IF TRY_CONVERT(decimal,@Costo) IS NULL 
		BEGIN
			PRINT('El costo no se puede transformar en decimal')
			RAISERROR('El costo no se puede transformar en decimal',16,1)
		END

		IF @Costo < 0
		BEGIN
			PRINT('El costo no puede ser negativo')
			RAISERROR('El costo no puede ser negativo',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo en la creacion de Actividad',16,1)
			RETURN;
		END
	END CATCH
	INSERT INTO Activity.Actividad(Nombre,Descr,Costo)
	VALUES(@Nombre_Actividad,@Desc_Act,@Costo)
END
GO

-- Para Tabla Act Extra

CREATE OR ALTER PROCEDURE Activity.Agr_Actividad_Extr
	@Nombre_Actividad VARCHAR(50),
	@Desc_Act VARCHAR(50),
	@Costo_Soc DECIMAL,
	@Costo_No_Soc DECIMAL
AS
BEGIN
	BEGIN TRY
		SET @Nombre_Actividad = TRIM(@Nombre_Actividad)

		IF @Nombre_Actividad = '' OR @Nombre_Actividad LIKE '%[^a-zA-Z]%'
		BEGIN
			PRINT('El nombre de la actividad no es valido.')
			RAISERROR('El nombre de la actividad no es valido.',16,1)
		END

		IF EXISTS (SELECT 1 FROM Activity.Actividad WHERE Nombre = @Nombre_Actividad)
		BEGIN
			PRINT('Ya existe una actividad con el mismo nombre.')
			RAISERROR('Ya existe una activdad con el mismo nombre.',16,1)
		END

		SET @Desc_Act = TRIM(@Desc_Act)
		IF @Desc_Act = '' OR @Desc_Act LIKE '%[^a-zA-Z ]%'
		BEGIN
			PRINT('La descripcion de la actividad no es valida.')
			RAISERROR('La descripcion de la actividad no es valida.',16,1)
		END

		IF TRY_CONVERT(decimal,@Costo_Soc) IS NULL 
		BEGIN
			PRINT('El costo no se puede transformar en decimal')
			RAISERROR('El costo no se puede transformar en decimal',16,1)
		END

		IF @Costo_Soc < 0
		BEGIN
			PRINT('El costo no puede ser negativo')
			RAISERROR('El costo no puede ser negativo',16,1)
		END

		IF TRY_CONVERT(decimal,@Costo_No_Soc) IS NULL 
		BEGIN
			PRINT('El costo no se puede transformar en decimal')
			RAISERROR('El costo no se puede transformar en decimal',16,1)
		END

		IF @Costo_No_Soc < 0
		BEGIN
			PRINT('El costo no puede ser negativo')
			RAISERROR('El costo no puede ser negativo',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo en la creacion de Actividad',16,1)
			RETURN;
		END
	END CATCH
	INSERT INTO Activity.Actividad_Extra(Nombre,Descr,Costo_Soc, Costo)
	VALUES(@Nombre_Actividad,@Desc_Act,@Costo_Soc,@Costo_No_Soc)
END
GO

-- Para tabla Actividad_Horario --

CREATE OR ALTER PROCEDURE Activity.Agr_Horario
	@Id_Actividad INTEGER,
	@Id_Categoria INTEGER,
	@Horario TIME,
	@Dias VARCHAR(100)
AS
BEGIN
	BEGIN TRY
		DECLARE @Temporal TABLE (Dia VARCHAR(100))
		DECLARE @Normalizados VARCHAR(100) = ''
		IF TRY_CONVERT(INT,@Id_Actividad) IS NULL
		BEGIN
			PRINT('El codigo de actividad no es valido')
			RAISERROR('El codigo de actividad no es valido',16,1)
		END

		IF NOT EXISTS (SELECT 1 FROM Activity.Actividad WHERE Id_Actividad = @Id_Actividad)
		BEGIN	
			PRINT('No existe actividad con este codigo')
			RAISERROR('No existe actividad con este codigo',16,1)
		END

		IF TRY_CONVERT(INT,@Id_Categoria) IS NULL
		BEGIN
			PRINT('El codigo de categoria no es valido')
			RAISERROR('El codigo de categoria no es valido',16,1)
		END

		IF NOT EXISTS (SELECT 1 FROM Groups.Categoria WHERE Id_Categoria = @Id_Categoria)
		BEGIN	
			PRINT('No existe categoria con este codigo')
			RAISERROR('No existe categoria con este codigo',16,1)
		END

		IF @Horario NOT LIKE '[0-2][0-9]:[0-5][0-9]' OR LEN(@Horario) != 5
		BEGIN 
			PRINT('Por favor utilize formato hh:mm')
			SET @Horario = CONVERT(VARCHAR(5), @Horario, 108)
		END

		IF @Dias LIKE '%[^a-zA-Z,]%'
		BEGIN
			PRINT('Los dias contienen caracteres no validos (utilice una coma como separador)')
			RAISERROR('Los dias contienen caracteres no validos (utilice una coma como separador)',16,1)
		END
		
		--Separamos el string en los dias, partimos los mismos para normalizarlos y luego los volvemos a juntar--

		INSERT INTO @Temporal
		SELECT value FROM string_split(@Dias, ',')

		SELECT @Normalizados = STRING_AGG(UPPER(LEFT(Dia,1)) + LOWER(SUBSTRING(Dia, 2,LEN(Dia))), ',')
		FROM @Temporal

		IF EXISTS
		(
			SELECT 1 
			FROM string_split(@Normalizados, ',') AS d
			WHERE d.value NOT IN(
				'Lunes','Martes','Miercoles','Jueves','Viernes','Sabado','Domingo')
		)
		BEGIN
			PRINT('Se ingreso un dia invalido')
			RAISERROR('Se ingreso un dia invalido',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo en la creacion de Horario',16,1)
			RETURN;
		END
	END CATCH
	INSERT INTO Activity.Horario_Actividad(Id_Actividad,Id_Categoria,Horario,Dias)
	VALUES (@Id_Actividad, @Id_Categoria, @Horario, @Normalizados)
END
GO

-- Para tabla Inscripto_Actividad --

CREATE OR ALTER PROCEDURE
