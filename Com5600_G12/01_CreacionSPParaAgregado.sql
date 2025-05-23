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

-- ENUNCIADO: Genere store procedures para manejar la inserción de cada tabla. --

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

		IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 25
		BEGIN
			PRINT('El nombre no es valido')
			RAISERROR('.', 16,1)
		END
		SET @Nombre = TRIM(@Nombre);

		IF @Apellido ='' OR @Apellido LIKE '%[^a-zA-Z ]%' OR LEN(@Apellido) > 25
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
			SET @Id_Tutor = NULL
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

		SET @Nombre_Rol = TRIM(@Nombre_Rol)

		IF EXISTS (SELECT 1 FROM Person.Rol WHERE Nombre_Rol = @Nombre_Rol)
		BEGIN
			PRINT('Ya existe un rol con ese nombre')
			RAISERROR('.',16,1)
		END

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

		IF EXISTS (SELECT 1 FROM Person.Usuario WHERE Nombre_Usuario = @Nombre_Usuario)
		BEGIN
			PRINT('Ya existe un usuario con ese nombre')
			RAISERROR('.',16,1)
		END

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

---------------------------- SCHEMA PAYMENT ----------------------------
-- Agregar factura
CREATE OR ALTER PROCEDURE Payment.Agr_Factura
    @Id_Persona INT,
    @Fecha_Vencimiento DATE,
    @Segundo_Vencimiento DATE,
    @Total DECIMAL(10,2),
    @Estado_Factura VARCHAR(10)
AS
BEGIN
    BEGIN TRY
        -- Validaciones básicas
        IF NOT EXISTS (SELECT 1 FROM Person.Persona WHERE Id_Persona = @Id_Persona)
        BEGIN
            PRINT('La persona no existe')
            RAISERROR('.',16,1)
        END

        IF @Total <= 0
        BEGIN
            PRINT('El total debe ser mayor a 0')
            RAISERROR('.',16,1)
        END

        SET @Estado_Factura = TRIM(@Estado_Factura)

        IF @Estado_Factura = '' OR LEN(@Estado_Factura) > 10
        BEGIN
            PRINT('Estado de factura inválido')
            RAISERROR('.',16,1)
        END

        INSERT INTO Payment.Factura (
            Id_Persona, Fecha_Emision, Fecha_Vencimiento,
            Segundo_Vencimiento, Total, Estado_Factura)
        VALUES (
            @Id_Persona, GETDATE(), @Fecha_Vencimiento,
            @Segundo_Vencimiento, @Total, @Estado_Factura
        )
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Error al registrar la factura', 16, 1)
        END
    END CATCH
END
GO

-- Agregar detalle de factura
CREATE OR ALTER PROCEDURE Payment.Agr_Detalle_Factura
    @Id_Factura INT,
    @Id_Detalle INT,
    @Concepto VARCHAR(50),
    @Monto DECIMAL(10,2),
    @Descuento_Familiar INT,
    @Id_Familia INT,
    @Descuento_Act INT,
    @Descuento_Lluvia INT
AS
BEGIN
    BEGIN TRY
        -- Validar existencia de factura
        IF NOT EXISTS (SELECT 1 FROM Payment.Factura WHERE Id_Factura = @Id_Factura)
        BEGIN
            PRINT('La factura no existe')
            RAISERROR('.',16,1)
        END

        -- Validar existencia de referencia
        IF NOT EXISTS (SELECT 1 FROM Payment.Referencia_Detalle WHERE Id_Detalle = @Id_Detalle)
        BEGIN
            PRINT('El detalle no existe en Referencia_Detalle')
            RAISERROR('.',16,1)
        END

        -- Validar duplicado
        IF EXISTS (SELECT 1 FROM Payment.Detalle_Factura WHERE Id_Factura = @Id_Factura AND Id_Detalle = @Id_Detalle)
        BEGIN
            PRINT('Ese detalle ya está registrado para esta factura')
            RAISERROR('.',16,1)
        END

        -- Validar concepto
        SET @Concepto = TRIM(@Concepto)
        IF @Concepto = '' OR LEN(@Concepto) > 50
        BEGIN
            PRINT('Concepto inválido')
            RAISERROR('.',16,1)
        END

        IF @Monto <= 0
        BEGIN
            PRINT('El monto debe ser mayor a 0')
            RAISERROR('.',16,1)
        END

        -- Insertar
        INSERT INTO Payment.Detalle_Factura (
            Id_Factura, Id_Detalle, Concepto, Monto,
            Descuento_Familiar, Id_Familia, Descuento_Act, Descuento_Lluvia)
        VALUES (
            @Id_Factura, @Id_Detalle, @Concepto, @Monto,
            @Descuento_Familiar, @Id_Familia, @Descuento_Act, @Descuento_Lluvia
        )
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al registrar el detalle de factura', 16, 1)
    END CATCH
END
GO


-- Agregar referencia detalle
CREATE OR ALTER PROCEDURE Payment.Agr_Referencia_Detalle
    @Referencia INT,
    @Tipo_Referencia INT,
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        SET @Descripcion = TRIM(@Descripcion)
        IF @Descripcion = '' OR LEN(@Descripcion) > 50
        BEGIN
            PRINT('Descripción inválida')
            RAISERROR('.',16,1)
        END

        IF @Referencia < 100 OR @Tipo_Referencia NOT IN (1, 2, 3)
        BEGIN
            PRINT('Referencia o tipo inválido')
            RAISERROR('.',16,1)
        END

        INSERT INTO Payment.Referencia_Detalle (
            Referencia, Tipo_Referencia, Descripcion)
        VALUES (
            @Referencia, @Tipo_Referencia, @Descripcion
        )
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al registrar la referencia del detalle', 16, 1)
    END CATCH
END
GO


-- Agregar morosidad
CREATE OR ALTER PROCEDURE Payment.Agr_Morosidad
    @Id_Factura INT,
    @Segundo_Vencimiento DATE,
    @Recargo DECIMAL(10,2),
    @Bloqueado INT,
    @Fecha_Bloqueo DATE
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Payment.Factura WHERE Id_Factura = @Id_Factura)
        BEGIN
            PRINT('La factura no existe')
            RAISERROR('.',16,1)
        END

        IF @Recargo < 0
        BEGIN
            PRINT('El recargo no puede ser negativo')
            RAISERROR('.',16,1)
        END

        INSERT INTO Payment.Morosidad (
            Id_Factura, Segundo_Vencimiento, Recargo, Bloqueado, Fecha_Bloqueo)
        VALUES (
            @Id_Factura, @Segundo_Vencimiento, @Recargo, @Bloqueado, @Fecha_Bloqueo
        )
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al registrar morosidad', 16, 1)
    END CATCH
END
GO

-- Agregar pago
CREATE OR ALTER PROCEDURE Payment.Agr_Pago
    @Id_Factura INT,
    @Medio_Pago VARCHAR(50),
    @Monto DECIMAL(10,2),
    @Reembolso INT,
    @Cantidad_Pago DECIMAL(10,2),
    @Pago_Cuenta INT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Payment.Factura WHERE Id_Factura = @Id_Factura)
        BEGIN
            PRINT('La factura no existe')
            RAISERROR('.',16,1)
        END

        SET @Medio_Pago = TRIM(@Medio_Pago)
        IF @Medio_Pago = '' OR LEN(@Medio_Pago) > 50
        BEGIN
            PRINT('Medio de pago inválido')
            RAISERROR('.',16,1)
        END

        IF @Monto <= 0 OR @Cantidad_Pago <= 0
        BEGIN
            PRINT('El monto y la cantidad deben ser mayores a 0')
            RAISERROR('.',16,1)
        END

        INSERT INTO Payment.Pago (
            Id_Factura, Fecha_Pago, Medio_Pago, Monto,
            Reembolso, Cantidad_Pago, Pago_Cuenta)
        VALUES (
            @Id_Factura, GETDATE(), @Medio_Pago, @Monto,
            @Reembolso, @Cantidad_Pago, @Pago_Cuenta
        )
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al registrar el pago', 16, 1)
    END CATCH
END
GO

-- Agregar tipo medio
CREATE OR ALTER PROCEDURE Payment.Agr_TipoMedio
    @Nombre_Medio VARCHAR(25),
    @Datos_Necesarios VARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        SET @Nombre_Medio = TRIM(@Nombre_Medio)
        IF @Nombre_Medio = '' OR LEN(@Nombre_Medio) > 25
        BEGIN
            PRINT('Nombre de medio inválido')
            RAISERROR('.',16,1)
        END

        INSERT INTO Payment.TipoMedio (
            Nombre_Medio, Datos_Necesarios)
        VALUES (
            @Nombre_Medio, @Datos_Necesarios
        )
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al registrar el tipo de medio de pago', 16, 1)
    END CATCH
END
GO

-- Agregar medio pago
CREATE OR ALTER PROCEDURE Payment.Agr_Medio_Pago
    @Id_Persona INT,
    @Id_TipoMedio INT,
    @Datos_Medio VARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Person.Persona WHERE Id_Persona = @Id_Persona)
        BEGIN
            PRINT('La persona no existe')
            RAISERROR('.',16,1)
        END

        IF NOT EXISTS (SELECT 1 FROM Payment.TipoMedio WHERE Id_TipoMedio = @Id_TipoMedio)
        BEGIN
            PRINT('El tipo de medio no existe')
            RAISERROR('.',16,1)
        END

        INSERT INTO Payment.Medio_Pago (
            Id_Persona, Id_TipoMedio, Datos_Medio)
        VALUES (
            @Id_Persona, @Id_TipoMedio, @Datos_Medio
        )
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al registrar medio de pago', 16, 1)
    END CATCH
END
GO

-- Agregar cuenta
CREATE OR ALTER PROCEDURE Payment.Agr_Cuenta
    @Id_Persona INT,
    @SaldoCuenta DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Person.Persona WHERE Id_Persona = @Id_Persona)
        BEGIN
            PRINT('La persona no existe')
            RAISERROR('.',16,1)
        END

        IF EXISTS (SELECT 1 FROM Payment.Cuenta WHERE Id_Persona = @Id_Persona)
        BEGIN
            PRINT('La cuenta ya existe para esta persona')
            RAISERROR('.',16,1)
        END

        IF @SaldoCuenta < 0
        BEGIN
            PRINT('El saldo no puede ser negativo')
            RAISERROR('.',16,1)
        END

        INSERT INTO Payment.Cuenta (
            Id_Persona, SaldoCuenta)
        VALUES (
            @Id_Persona, @SaldoCuenta
        )
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al registrar la cuenta', 16, 1)
    END CATCH
END
GO

-----------------------------------------------------------------------
---------------------------- SCHEMA GROUPS ----------------------------

---- Para Tabla Miembro Familia ----
CREATE OR ALTER PROCEDURE Groups.Agr_Miembro_Familia
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
		DECLARE @Activo INT = 0;
		INSERT INTO Groups.Grupo_Familiar (Nombre_Familia, Activo)-- Crear grupo
		VALUES (@Nombre_Familia, @Activo)
		
		SET @Id_Grupo = SCOPE_IDENTITY()

		EXEC Groups.Agr_Miembro_Familia-- Asociar al socio al nuevo grupo
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

CREATE OR ALTER PROCEDURE Groups.Agr_Categoria
	@Nombre_Cat VARCHAR(50),
	@Edad_Min INTEGER,
	@Edad_Max INTEGER,
	@Descr VARCHAR(50),
	@Costo DECIMAL
AS
BEGIN
	BEGIN TRY
		DECLARE @Id INTEGER
		SET @Nombre_Cat = TRIM(@Nombre_Cat)

		IF EXISTS (SELECT 1 FROM Groups.Categoria WHERE @Nombre_Cat = @Nombre_Cat)
		BEGIN
			PRINT('Ya existe una categoria con ese nombre')
			RAISERROR('.',16,1)
		END

		IF @Nombre_Cat = '' OR @Nombre_Cat LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre_Cat) > 50
		BEGIN
			PRINT('Nombre de categoria invalido')
			RAISERROR('.',16,1)
		END
		
		IF @Edad_Min < 0 OR @Edad_Max < @Edad_Min
		BEGIN
			PRINT('Rango de edades invalido')
			RAISERROR('El rango de edades es invalido',16,1)
		END

		SET @Descr = TRIM(@Descr)

		IF @Descr = '' OR @Descr LIKE '%[^a-zA-Z ]%' OR LEN(@Descr) > 50
		BEGIN
			PRINT('Descripcion Invalida')
			RAISERROR('.',16,1)
		END

		IF @Costo < 0
		BEGIN
			PRINT('El costo no puede ser negativo')
			RAISERROR('El costo no debe ser negativo',16,1)
		END
		INSERT INTO Groups.Categoria (Nombre_Cat, EdadMin, EdadMax, Descr, Costo)
		VALUES (@Nombre_Cat,@Edad_Min, @Edad_Max, @Descr, @Costo)

		SET @Id = SCOPE_IDENTITY()

		EXEC Payment.Agr_Referencia_Detalle
			@Id,
			@Nombre_Cat

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo en la creacion de categoria',16,1)
			RETURN;
		END
	END CATCH
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
		DECLARE @Id INTEGER
		SET @Nombre_Actividad = TRIM(@Nombre_Actividad)

		IF EXISTS (SELECT 1 FROM Activity.Actividad WHERE Nombre = @Nombre_Actividad)
		BEGIN
			PRINT('Ya existe una actividad con ese nombre')
			RAISERROR('.',16,1)
		END

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
	
	SET @Id = SCOPE_IDENTITY()

	EXEC Payment.Agr_Referencia_Detalle
	@Id,
	@Nombre_Actividad
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
		DEClARE @Id INTEGER
		SET @Nombre_Actividad = TRIM(@Nombre_Actividad)

		IF EXISTS (SELECT 1 FROM Activity.Actividad_Extra WHERE Nombre = @Nombre_Actividad)
		BEGIN
			PRINT('Ya existe una actividad con ese nombre')
			RAISERROR('.',16,1)
		END

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

	SET @Id = SCOPE_IDENTITY()

	EXEC Payment.Agr_Referencia_Detalle
	@Id,
	@Nombre_Actividad
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

CREATE OR ALTER PROCEDURE Activity.Agr_Inscripto_Actividad
	@Id_Horario INTEGER,
	@Id_Socio INTEGER

AS
BEGIN
	BEGIN TRY
		DECLARE @Fecha DATE
		SET @Fecha = GETDATE()
		IF TRY_CONVERT(INT,@Id_Horario) IS NULL
		BEGIN
			PRINT('El Id de horario ingresado no es un numero')
			RAISERROR('El Id de horario ingresado no es un numero',16,1)
		END

		IF NOT EXISTS (SELECT 1 FROM Activity.Horario_Actividad WHERE Id_Horario = @Id_Horario)
		BEGIN
			PRINT('El Id de horario ingresado no existe')
			RAISERROR('El Id de horario ingresado no existe',16,1)
		END

		IF TRY_CONVERT(INT,@Id_Socio) IS NULL
		BEGIN
			PRINT('El Id de socio ingresado no es un numero')
			RAISERROR('El Id de socio ingresado no es un numero',16,1)
		END

		IF NOT EXISTS (SELECT 1 FROM Person.Socio WHERE Id_Socio = @Id_Socio)
		BEGIN
			PRINT('El Id de socio ingresado no existe')
			RAISERROR('El Id de socio ingresado no existe',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo en la creacion de Inscripto',16,1)
			RETURN;
		END
	END CATCH
	INSERT INTO Activity.Inscripto_Actividad(Id_Horario, Id_Socio, Fecha_Inscripcion)
	VALUES (@Id_Horario, @Id_Socio, @Fecha)
END
GO

CREATE OR ALTER PROCEDURE Activity.Agr_Inscripto_Act_Extra
	@Id_Act_Extra INTEGER,
	@Id_Persona INT,
	@Fecha DATE,
	@Es_Alquiler INT
AS
BEGIN
	BEGIN TRY
	IF TRY_CONVERT(INT,@Id_Act_Extra) IS NULL
	BEGIN
		PRINT('El valor de ID no es numerico')
		RAISERROR('El valor de ID no es numerico',16,1)
	END

	IF NOT EXISTS (SELECT 1 FROM Activity.Actividad_Extra WHERE Id_Actividad_Extra = @Id_Act_Extra)
	BEGIN
		PRINT('El valor de ID actividad no existe')
		RAISERROR('El valor de ID actividad no existe',16,1)
	END

	IF TRY_CONVERT(INT,@Id_Persona) IS NULL
	BEGIN
		PRINT('El valor de ID no es numero')
		RAISERROR('El valor de ID no es numerico',16,1)
	END

	IF NOT EXISTS (SELECT 1 FROM Person.Persona WHERE Id_Persona = @Id_Persona)
	BEGIN
		PRINT('El valor de ID persona no existe')
		RAISERROR('El valor de ID persona no existe',16,1)
	END
	IF @Es_Alquiler > 1 OR @Es_Alquiler < 0
		BEGIN
			PRINT('Ingrese un 1 para indicar alquiler, un 0 para indicar actividad normal (pileta, colonia, etc)')
			RAISERROR('Ingrese un 1 para indicar alquiler, un 0 para indicar actividad normal (pileta, colonia, etc)',16,1)
		END
	IF @Es_Alquiler = 1
	BEGIN
		IF @Fecha NOT BETWEEN GETDATE() AND DATEADD(MONTH,2,GETDATE())
		BEGIN
			IF @Fecha < GETDATE()
			BEGIN
				PRINT('Doc, I need you to get me to the future.')
				RAISERROR('Doc, I need you to get me to the future.',16,1)
			END

			ELSE
			
			BEGIN
				PRINT('La fecha ingresada esta a mas de 2 meses de distancia')
				RAISERROR('La fecha ingresada esta a mas de 2 meses de distancia',16,1)
			END
		END
	END
	
	ELSE

	SET @Fecha = GETDATE()
	IF NOT EXISTS(SELECT 1 FROM Jornada.Jornada WHERE Fecha = @Fecha)
	BEGIN
		PRINT('La fecha ingresada no esta cargada a nuestro sistema')
	END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo en la creacion de Inscripto',16,1)
			RETURN;
		END
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE Payment.Agr_Referencia_Detalle
    @Referencia INT,
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRY
		IF EXISTS (SELECT 1 FROM Payment.Referencia_Detalle WHERE Referencia = @Referencia)
		BEGIN
			PRINT('No puede haber numeros de referencia repetidos')
            RAISERROR('.', 16, 1)
		END
		DECLARE @TIPO_REFERENCIA INTEGER
        SET @Descripcion = TRIM(@Descripcion)

        IF @Descripcion = '' OR LEN(@Descripcion) > 50
        BEGIN
            PRINT('Descripción inválida')
            RAISERROR('.', 16, 1)
        END

        IF @Referencia < 100 OR @Referencia > 400
        BEGIN
            PRINT('La referencia debe ser mayor o igual a 100 y menor a 400')
            RAISERROR('.', 16, 1)
        END

		IF @Referencia > 300
		BEGIN 
			SET @TIPO_REFERENCIA = 3
		END
		ELSE
		IF @Referencia < 200
		BEGIN
			SET @TIPO_REFERENCIA = 1
		END
		ELSE
		BEGIN 
			SET @TIPO_REFERENCIA = 2
		END

        IF @Tipo_Referencia NOT IN (1, 2, 3)
        BEGIN
            PRINT('Tipo de referencia inválido (debe ser 1, 2 o 3)')
            RAISERROR('.', 16, 1)
        END

        INSERT INTO Payment.Referencia_Detalle (Referencia, Tipo_Referencia, Descripcion)
        VALUES (@Referencia, @Tipo_Referencia, @Descripcion)
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al registrar la referencia del detalle', 16, 1)
    END CATCH
END
GO

-----------------------------------------------------------------------
---------------------------- SCHEMA JORNADA ---------------------------

CREATE OR ALTER PROCEDURE Jornada.Agr_Jornada
    @Fecha DATE,
    @Lluvia INT,
    @MM DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        -- Validar que la fecha no esté duplicada
        IF EXISTS (SELECT 1 FROM Jornada.Jornada WHERE Fecha = @Fecha)
        BEGIN
            PRINT('Ya existe una jornada con esa fecha')
            RAISERROR('.', 16, 1)
        END

        -- Validar rango de lluvia (0 o 1)
        IF @Lluvia NOT IN (0, 1)
        BEGIN
            PRINT('El valor de lluvia debe ser 0 (no llovió) o 1 (sí llovió)')
            RAISERROR('.', 16, 1)
        END

        -- Validar MM
        IF @MM < 0
        BEGIN
            PRINT('Los milímetros de lluvia no pueden ser negativos')
            RAISERROR('.', 16, 1)
        END

        -- Insertar jornada
        INSERT INTO Jornada.Jornada (Fecha, Lluvia, MM)
        VALUES (@Fecha, @Lluvia, @MM)
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Error al registrar la jornada', 16, 1)
        END
    END CATCH
END
GO

