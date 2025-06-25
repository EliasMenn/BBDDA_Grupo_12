------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico 43316258
--Medina, Juan 46682620
--Mennella, Elias Damian 46357008
----------------------------------------------------------------

USE master

USE Com5600_G12
GO
------------------------------------------ SCHEMA PERSON -------------------------------------------
---------------------------------------- Para Tabla Persona ----------------------------------------
CREATE OR ALTER PROCEDURE Person.Modificar_Persona
	@Id_Persona INT,
	@Nombre VARCHAR(25) = NULL,
	@Apellido VARCHAR(25) = NULL,
	@DNI VARCHAR(10) = NULL,
	@Email VARCHAR(50) = NULL,
	@Fecha_Nacimiento DATE = NULL,
	@Telefono_Contacto VARCHAR(15) = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Person.Persona WHERE Id_Persona = @Id_Persona)
		BEGIN
			PRINT('No existe una persona con el Id proporcionado.');
			RETURN;
		END

		-- Modificar Nombre
		IF @Nombre IS NOT NULL AND @Nombre <> ''
		BEGIN
			SET @Nombre = TRIM(@Nombre);
			IF @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 25
			BEGIN
				PRINT('El nombre no es válido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Persona
			SET Nombre = @Nombre
			WHERE Id_Persona = @Id_Persona;
		END

		-- Modificar Apellido
		IF @Apellido IS NOT NULL AND @Apellido <> ''
		BEGIN
			SET @Apellido = TRIM(@Apellido);
			IF @Apellido LIKE '%[^a-zA-Z ]%' OR LEN(@Apellido) > 25
			BEGIN
				PRINT('El apellido no es válido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Persona
			SET Apellido = @Apellido
			WHERE Id_Persona = @Id_Persona;
		END

		-- Modificar DNI
		IF @DNI IS NOT NULL AND @DNI <> ''
		BEGIN
			SET @DNI = TRIM(@DNI);
			IF @DNI LIKE '%[^0-9]%' OR LEN(@DNI) > 10
			BEGIN
				PRINT('El DNI no es válido');
				RAISERROR('.', 16, 1);
			END

			-- Validar que no exista otra persona con el mismo DNI
			IF EXISTS (
				SELECT 1 FROM Person.Persona 
				WHERE DNI = @DNI AND Id_Persona <> @Id_Persona
			)
			BEGIN
				PRINT('Ya existe otra persona con el DNI ingresado.');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Persona
			SET DNI = @DNI
			WHERE Id_Persona = @Id_Persona;
		END

		-- Modificar Email
		IF @Email IS NOT NULL AND @Email <> ''
		BEGIN
			SET @Email = TRIM(@Email);
			IF @Email NOT LIKE '%@%.%' OR LEN(@Email) > 50
			BEGIN
				PRINT('El email no es válido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Persona
			SET Email = @Email
			WHERE Id_Persona = @Id_Persona;
		END

		-- Modificar Fecha de Nacimiento
		IF @Fecha_Nacimiento IS NOT NULL
		BEGIN
			IF @Fecha_Nacimiento NOT BETWEEN '1930-01-01' AND GETDATE()
			BEGIN
				PRINT('La fecha de nacimiento no es válida');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Persona
			SET Fecha_Nacimiento = @Fecha_Nacimiento
			WHERE Id_Persona = @Id_Persona;
		END

		-- Modificar Teléfono
		IF @Telefono_Contacto IS NOT NULL AND @Telefono_Contacto <> ''
		BEGIN
			SET @Telefono_Contacto = TRIM(@Telefono_Contacto);
			IF @Telefono_Contacto LIKE '%[^0-9]%' OR LEN(@Telefono_Contacto) > 50
			BEGIN
				PRINT('El teléfono no es válido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Persona
			SET Telefono_Contacto = @Telefono_Contacto
			WHERE Id_Persona = @Id_Persona;
		END

		PRINT('Persona actualizada correctamente.');
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió un error al modificar la persona.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO

---------------------------------------- Para Tabla Socio ----------------------------------------
CREATE OR ALTER PROCEDURE Person.Modificar_Socio
	@Id_Socio VARCHAR(20),
	@Telefono_Contacto_Emg VARCHAR(15) = NULL,
	@Obra_Social VARCHAR(25) = NULL,
	@Nro_Socio_Obra VARCHAR(15) = NULL,
	@Id_Tutor INT = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		DECLARE @Id_Persona INT;
		DECLARE @Fecha_Nacimiento DATE;
		DECLARE @Edad INT;
		DECLARE @Id_Categoria INT;

		-- Validamos que exista el socio y obtenemos datos necesarios
		SELECT 
			@Id_Persona = S.Id_Persona,
			@Fecha_Nacimiento = P.Fecha_Nacimiento
		FROM Person.Socio S
		JOIN Person.Persona P ON S.Id_Persona = P.Id_Persona
		WHERE Id_Socio = @Id_Socio;

		IF @Id_Persona IS NULL
		BEGIN
			PRINT('No existe un socio con el Id especificado.');
			RETURN;
		END

		-- Recalculamos edad y categoría
		SET @Edad = DATEDIFF(YEAR, @Fecha_Nacimiento, GETDATE());
		IF DATEADD(YEAR, @Edad, @Fecha_Nacimiento) > GETDATE()
			SET @Edad = @Edad - 1;

		SELECT @Id_Categoria = Id_Categoria
		FROM Groups.Categoria
		WHERE @Edad BETWEEN EdadMin AND EdadMax;

		IF @Id_Categoria IS NULL
		BEGIN
			PRINT('No se encontró una categoría válida.');
			RAISERROR('.', 16, 1);
		END

		-- Actualizamos categoría siempre (dependiente de la edad actual)
		UPDATE Person.Socio
		SET Id_Categoria = @Id_Categoria
		WHERE Id_Socio = @Id_Socio;

		-- Teléfono emergencia
		IF @Telefono_Contacto_Emg IS NOT NULL AND @Telefono_Contacto_Emg <> ''
		BEGIN
			IF @Telefono_Contacto_Emg LIKE '%[^0-9]%' OR LEN(@Telefono_Contacto_Emg) > 50
			BEGIN
				PRINT('El teléfono de emergencia no es válido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Socio
			SET Telefono_Emergencia = TRIM(@Telefono_Contacto_Emg)
			WHERE Id_Socio = @Id_Socio;
		END

		-- Obra social y número
		IF @Obra_Social IS NOT NULL AND @Obra_Social <> ''
		BEGIN
			SET @Obra_Social = TRIM(@Obra_Social);

			IF @Obra_Social LIKE '%[^a-zA-Z ]%' OR LEN(@Obra_Social) > 25
			BEGIN
				PRINT('La obra social no es válida');
				RAISERROR('.', 16, 1);
			END

			-- Si obra social no es N/A, validamos número
			IF @Obra_Social NOT LIKE 'N/A'
			BEGIN
				IF @Nro_Socio_Obra IS NULL OR @Nro_Socio_Obra = '' OR @Nro_Socio_Obra LIKE '%[^0-9]%' OR LEN(@Nro_Socio_Obra) > 50
				BEGIN
					PRINT('El número de obra social no es válido');
					RAISERROR('.', 16, 1);
				END
			END
			ELSE
				SET @Nro_Socio_Obra = 'N/A';

			UPDATE Person.Socio
			SET Obra_Social = @Obra_Social,
				Nro_Obra_Social = TRIM(@Nro_Socio_Obra)
			WHERE Id_Socio = @Id_Socio;
		END

		-- Tutor (solo si es menor)
		IF @Edad <= 18
		BEGIN
			IF @Id_Tutor IS NULL
			BEGIN
				PRINT('El socio es menor de edad y requiere un tutor');
				RAISERROR('.', 16, 1);
			END

			IF NOT EXISTS (SELECT 1 FROM Person.Tutor WHERE Id_Tutor = @Id_Tutor)
			BEGIN
				PRINT('Tutor no existe para un socio menor de edad');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Socio
			SET Id_Tutor = @Id_Tutor
			WHERE Id_Socio = @Id_Socio;
		END
		ELSE
		BEGIN
			-- Si es mayor, se elimina tutor
			UPDATE Person.Socio
			SET Id_Tutor = NULL
			WHERE Id_Socio = @Id_Socio;
		END

		PRINT('Socio actualizado correctamente.');
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió un error al modificar al socio.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO

---------------------------------------- Para Tabla Tutor ----------------------------------------

CREATE OR ALTER PROCEDURE Person.Modificar_Tutor
	@Id_Tutor INT,
	@Parentesco VARCHAR(20) = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		DECLARE @Id_Persona INT;

		-- Verificamos que exista el tutor
		SELECT @Id_Persona = Id_Persona
		FROM Person.Tutor
		WHERE Id_Tutor = @Id_Tutor;

		IF @Id_Persona IS NULL
		BEGIN
			PRINT('No existe un tutor con el Id proporcionado.');
			RETURN;
		END

		-- Si se desea modificar el parentesco
		IF @Parentesco IS NOT NULL AND @Parentesco <> ''
		BEGIN
			SET @Parentesco = TRIM(@Parentesco);

			IF @Parentesco LIKE '%[^a-zA-Z]%' OR LEN(@Parentesco) > 25
			BEGIN
				PRINT('El parentesco no es válido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Tutor
			SET Parentesco = @Parentesco
			WHERE Id_Tutor = @Id_Tutor;
		END

		PRINT('Tutor modificado correctamente.');
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió un error al modificar el tutor.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO


---------------------------------------- Para Tabla Rol ----------------------------------------
CREATE OR ALTER PROCEDURE Person.Modificar_Rol
	@Id_Rol INT,
	@Nombre_Rol VARCHAR(30) = NULL,
	@Descripcion VARCHAR(50) = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validar que exista el rol
		IF NOT EXISTS (SELECT 1 FROM Person.Rol WHERE Id_Rol = @Id_Rol)
		BEGIN
			PRINT('No existe un rol con ese ID');
			RAISERROR('.', 16, 1);
		END

		-- Validar que el ID sea numérico
		IF TRY_CONVERT(INT, @Id_Rol) IS NULL
		BEGIN
			PRINT('ID inválido');
			RAISERROR('-', 16, 1);
		END

		-- Actualizar Nombre_Rol si corresponde
		IF @Nombre_Rol IS NOT NULL AND @Nombre_Rol <> ''
		BEGIN
			SET @Nombre_Rol = TRIM(@Nombre_Rol);

			IF @Nombre_Rol LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre_Rol) > 30
			BEGIN
				PRINT('Nombre de rol inválido');
				RAISERROR('.', 16, 1);
			END

			-- Verificar que no se repita con otro rol
			IF EXISTS (
				SELECT 1 FROM Person.Rol
				WHERE Nombre_Rol = @Nombre_Rol AND Id_Rol <> @Id_Rol
			)
			BEGIN
				PRINT('Ya existe otro rol con ese nombre');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Rol
			SET Nombre_Rol = @Nombre_Rol
			WHERE Id_Rol = @Id_Rol;
		END

		-- Actualizar Descripcion si corresponde
		IF @Descripcion IS NOT NULL AND @Descripcion <> ''
		BEGIN
			SET @Descripcion = TRIM(@Descripcion);

			IF @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 50
			BEGIN
				PRINT('Descripción inválida');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Rol
			SET Desc_Rol = @Descripcion
			WHERE Id_Rol = @Id_Rol;
		END

		PRINT('Rol modificado correctamente.');
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió un error al modificar el rol.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO


---------------------------------------- Para Tabla Usuario ----------------------------------------
CREATE OR ALTER PROCEDURE Person.Modificar_Usuario
	@Id_Usuario INT,
	@Id_Rol INT = NULL,
	@Nombre_Usuario VARCHAR(30) = NULL,
	@Contrasenia NVARCHAR(25) = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		DECLARE @Vigencia DATE;
		DECLARE @ContraseniaHash VARBINARY(32);

		-- Validar que exista el usuario
		IF NOT EXISTS (SELECT 1 FROM Person.Usuario WHERE Id_Persona = @Id_Usuario)
		BEGIN
			PRINT('No existe un usuario con ese ID');
			RAISERROR('.', 16, 1);
		END

		-- Si se quiere actualizar el rol
		IF @Id_Rol IS NOT NULL
		BEGIN
			IF TRY_CONVERT(INT, @Id_Rol) IS NULL
			BEGIN
				PRINT('ID de rol no válido');
				RAISERROR('.', 16, 1);
			END
			IF NOT EXISTS (SELECT 1 FROM Person.Rol WHERE Id_Rol = @Id_Rol)
			BEGIN
				PRINT('El rol especificado no existe');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Usuario
			SET Id_Rol = @Id_Rol
			WHERE Id_Persona= @Id_Usuario;
		END

		-- Si se quiere actualizar el nombre de usuario
		IF @Nombre_Usuario IS NOT NULL AND @Nombre_Usuario <> ''
		BEGIN
			SET @Nombre_Usuario = TRIM(@Nombre_Usuario);

			IF LEN(@Nombre_Usuario) > 30
			BEGIN
				PRINT('El nombre de usuario excede el largo permitido');
				RAISERROR('.', 16, 1);
			END

			IF EXISTS (
				SELECT 1 FROM Person.Usuario 
				WHERE Nombre_Usuario = @Nombre_Usuario AND Id_Persona <> @Id_Usuario
			)
			BEGIN
				PRINT('Ya existe otro usuario con ese nombre');
				RAISERROR('.', 16, 1);
			END

			UPDATE Person.Usuario
			SET Nombre_Usuario = @Nombre_Usuario
			WHERE Id_Persona = @Id_Usuario;
		END

		-- Si se quiere actualizar la contraseña
		IF @Contrasenia IS NOT NULL AND @Contrasenia <> ''
		BEGIN
			SET @Contrasenia = TRIM(@Contrasenia);

			IF @Contrasenia NOT LIKE '%[A-Z]%' OR 
			   @Contrasenia NOT LIKE '%[a-z]%' OR 
			   @Contrasenia NOT LIKE '%[0-9]%'
			BEGIN
				PRINT('La contraseña debe contener al menos una mayúscula, una minúscula y un número');
				RAISERROR('.', 16, 1);
			END

			SET @ContraseniaHash = HASHBYTES('SHA2_256', CONVERT(NVARCHAR(100), @Contrasenia));
			SET @Vigencia = DATEADD(YEAR, 1, GETDATE());

			UPDATE Person.Usuario
			SET Contrasenia = @ContraseniaHash,
				Vigencia_Contrasenia = @Vigencia
			WHERE Id_Persona = @Id_Usuario;
		END

		PRINT('Usuario modificado correctamente.');

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió un error al modificar el usuario.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO

------------------------------------------ SCHEMA PAYMENT ------------------------------------------
---------------------------------------- Para Tabla Factura ----------------------------------------

CREATE OR ALTER PROCEDURE Payment.Modificar_Factura
    @Id_Factura INT,
    @Id_Persona INT = NULL,
    @Fecha_Vencimiento DATE = NULL,
    @Segundo_Vencimiento DATE = NULL,
    @Total DECIMAL(10,2) = NULL,
    @Estado_Factura VARCHAR(10) = NULL
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Validar existencia de la factura
        IF NOT EXISTS (SELECT 1 FROM Payment.Factura WHERE Id_Factura = @Id_Factura)
        BEGIN
            PRINT('No existe una factura con ese ID');
            RAISERROR('.', 16, 1);
        END

        -- Validar y actualizar Id_Persona si corresponde
        IF @Id_Persona IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Person.Persona WHERE Id_Persona = @Id_Persona)
            BEGIN
                PRINT('La persona especificada no existe');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Factura
            SET Id_Persona = @Id_Persona
            WHERE Id_Factura = @Id_Factura;
        END

        -- Validar y actualizar Fecha_Vencimiento
        IF @Fecha_Vencimiento IS NOT NULL
        BEGIN
            UPDATE Payment.Factura
            SET Fecha_Vencimiento = @Fecha_Vencimiento
            WHERE Id_Factura = @Id_Factura;
        END

        -- Validar y actualizar Segundo_Vencimiento
        IF @Segundo_Vencimiento IS NOT NULL
        BEGIN
            UPDATE Payment.Factura
            SET Segundo_Vencimiento = @Segundo_Vencimiento
            WHERE Id_Factura = @Id_Factura;
        END

        -- Validar y actualizar Total
        IF @Total IS NOT NULL
        BEGIN
            IF @Total <= 0
            BEGIN
                PRINT('El total debe ser mayor a 0');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Factura
            SET Total = @Total
            WHERE Id_Factura = @Id_Factura;
        END

        -- Validar y actualizar Estado_Factura
        IF @Estado_Factura IS NOT NULL AND @Estado_Factura <> ''
        BEGIN
            SET @Estado_Factura = TRIM(@Estado_Factura);
            IF LEN(@Estado_Factura) > 10
            BEGIN
                PRINT('Estado de factura inválido');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Factura
            SET Estado_Factura = @Estado_Factura
            WHERE Id_Factura = @Id_Factura;
        END

        PRINT('Factura modificada correctamente.');
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Ocurrió un error al modificar la factura.', 16, 1);
            RETURN;
        END
    END CATCH
END
GO


---------------------------------------- Para Tabla Detalle Factura ----------------------------------------
CREATE OR ALTER PROCEDURE Payment.Modificar_Detalle_Factura
    @Id_Factura INT,
    @Id_Detalle INT,
    @Concepto VARCHAR(50) = NULL,
    @Monto DECIMAL(10,2) = NULL,
    @Descuento_Familiar INT = NULL,
    @Id_Familia INT = NULL,
    @Descuento_Act INT = NULL,
    @Descuento_Lluvia INT = NULL
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Verificar existencia del detalle en la factura
        IF NOT EXISTS (
            SELECT 1 FROM Payment.Detalle_Factura
            WHERE Id_Factura = @Id_Factura AND Id_Detalle = @Id_Detalle
        )
        BEGIN
            PRINT('No existe ese detalle en esa factura');
            RAISERROR('.', 16, 1);
        END

        -- Modificar Concepto
        IF @Concepto IS NOT NULL AND @Concepto <> ''
        BEGIN
            SET @Concepto = TRIM(@Concepto);
            IF LEN(@Concepto) > 50
            BEGIN
                PRINT('Concepto inválido');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Detalle_Factura
            SET Concepto = @Concepto
            WHERE Id_Factura = @Id_Factura AND Id_Detalle = @Id_Detalle;
        END

        -- Modificar Monto
        IF @Monto IS NOT NULL
        BEGIN
            IF @Monto <= 0
            BEGIN
                PRINT('El monto debe ser mayor a 0');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Detalle_Factura
            SET Monto = @Monto
            WHERE Id_Factura = @Id_Factura AND Id_Detalle = @Id_Detalle;
        END

        -- Modificar Descuento_Familiar
        IF @Descuento_Familiar IS NOT NULL
        BEGIN
            UPDATE Payment.Detalle_Factura
            SET Descuento_Familiar = @Descuento_Familiar
            WHERE Id_Factura = @Id_Factura AND Id_Detalle = @Id_Detalle;
        END

        -- Modificar Id_Familia
        IF @Id_Familia IS NOT NULL
        BEGIN
            UPDATE Payment.Detalle_Factura
            SET Id_Familia = @Id_Familia
            WHERE Id_Factura = @Id_Factura AND Id_Detalle = @Id_Detalle;
        END

        -- Modificar Descuento_Act
        IF @Descuento_Act IS NOT NULL
        BEGIN
            UPDATE Payment.Detalle_Factura
            SET Descuento_Act = @Descuento_Act
            WHERE Id_Factura = @Id_Factura AND Id_Detalle = @Id_Detalle;
        END

        -- Modificar Descuento_Lluvia
        IF @Descuento_Lluvia IS NOT NULL
        BEGIN
            UPDATE Payment.Detalle_Factura
            SET Descuento_Lluvia = @Descuento_Lluvia
            WHERE Id_Factura = @Id_Factura AND Id_Detalle = @Id_Detalle;
        END

        PRINT('Detalle de factura modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al modificar el detalle de factura', 16, 1);
    END CATCH
END
GO

---------------------------------------- Para Tabla Referencia Detalle ----------------------------------------
CREATE OR ALTER PROCEDURE Payment.Modificar_Referencia_Detalle
    @Id_Detalle INT,
    @Referencia INT = NULL,
    @Tipo_Referencia INT = NULL,
    @Descripcion VARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Validar existencia del registro
        IF NOT EXISTS (SELECT 1 FROM Payment.Referencia_Detalle WHERE Id_Detalle = @Id_Detalle)
        BEGIN
            PRINT('No existe un detalle con ese ID');
            RAISERROR('.', 16, 1);
        END

        -- Modificar Referencia
        IF @Referencia IS NOT NULL
        BEGIN
            IF @Referencia < 100
            BEGIN
                PRINT('Referencia inválida');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Referencia_Detalle
            SET Referencia = @Referencia
            WHERE Id_Detalle = @Id_Detalle;
        END

        -- Modificar Tipo_Referencia
        IF @Tipo_Referencia IS NOT NULL
        BEGIN
            IF @Tipo_Referencia NOT IN (1, 2, 3)
            BEGIN
                PRINT('Tipo de referencia inválido');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Referencia_Detalle
            SET Tipo_Referencia = @Tipo_Referencia
            WHERE Id_Detalle = @Id_Detalle;
        END

        -- Modificar Descripción
        IF @Descripcion IS NOT NULL AND @Descripcion <> ''
        BEGIN
            SET @Descripcion = TRIM(@Descripcion);

            IF LEN(@Descripcion) > 50
            BEGIN
                PRINT('Descripción inválida');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Referencia_Detalle
            SET Descripcion = @Descripcion
            WHERE Id_Detalle = @Id_Detalle;
        END

        PRINT('Referencia de detalle modificada correctamente.');
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al modificar la referencia del detalle', 16, 1);
    END CATCH
END
GO

---------------------------------------- Para Tabla Morosidad ----------------------------------------
CREATE OR ALTER PROCEDURE Payment.Modificar_Morosidad
    @Id_Factura INT,
    @Segundo_Vencimiento DATE = NULL,
    @Recargo DECIMAL(10,2) = NULL,
    @Bloqueado INT = NULL,
    @Fecha_Bloqueo DATE = NULL
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Validar existencia del registro de morosidad
        IF NOT EXISTS (SELECT 1 FROM Payment.Morosidad WHERE Id_Factura = @Id_Factura)
        BEGIN
            PRINT('No existe morosidad registrada para esa factura');
            RAISERROR('.', 16, 1);
        END

        -- Validar y actualizar Segundo_Vencimiento
        IF @Segundo_Vencimiento IS NOT NULL
        BEGIN
            UPDATE Payment.Morosidad
            SET Segundo_Vencimiento = @Segundo_Vencimiento
            WHERE Id_Factura = @Id_Factura;
        END

        -- Validar y actualizar Recargo
        IF @Recargo IS NOT NULL
        BEGIN
            IF @Recargo < 0
            BEGIN
                PRINT('El recargo no puede ser negativo');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Morosidad
            SET Recargo = @Recargo
            WHERE Id_Factura = @Id_Factura;
        END

        -- Validar y actualizar Bloqueado
        IF @Bloqueado IS NOT NULL
        BEGIN
            UPDATE Payment.Morosidad
            SET Bloqueado = @Bloqueado
            WHERE Id_Factura = @Id_Factura;
        END

        -- Validar y actualizar Fecha_Bloqueo
        IF @Fecha_Bloqueo IS NOT NULL
        BEGIN
            UPDATE Payment.Morosidad
            SET Fecha_Bloqueo = @Fecha_Bloqueo
            WHERE Id_Factura = @Id_Factura;
        END

        PRINT('Morosidad actualizada correctamente.');
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al modificar el registro de morosidad', 16, 1);
    END CATCH
END
GO

---------------------------------------- Para Tabla Pago ----------------------------------------
CREATE OR ALTER PROCEDURE Payment.Modificar_Pago
    @Id_Pago INT,
    @Medio_Pago VARCHAR(50) = NULL,
    @Monto DECIMAL(10,2) = NULL,
    @Reembolso INT = NULL,
    @Cantidad_Pago DECIMAL(10,2) = NULL,
    @Pago_Cuenta INT = NULL
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Verificar existencia del pago
        IF NOT EXISTS (SELECT 1 FROM Payment.Pago WHERE Id_Pago = @Id_Pago)
        BEGIN
            PRINT('No existe un pago con ese ID');
            RAISERROR('.', 16, 1);
        END

        -- Validar y actualizar Medio_Pago
        IF @Medio_Pago IS NOT NULL AND @Medio_Pago <> ''
        BEGIN
            SET @Medio_Pago = TRIM(@Medio_Pago);

            IF LEN(@Medio_Pago) > 50
            BEGIN
                PRINT('Medio de pago inválido');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Pago
            SET Medio_Pago = @Medio_Pago
            WHERE Id_Pago = @Id_Pago;
        END

        -- Validar y actualizar Monto
        IF @Monto IS NOT NULL
        BEGIN
            IF @Monto <= 0
            BEGIN
                PRINT('El monto debe ser mayor a 0');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Pago
            SET Monto = @Monto
            WHERE Id_Pago = @Id_Pago;
        END

        -- Validar y actualizar Reembolso
        IF @Reembolso IS NOT NULL
        BEGIN
            UPDATE Payment.Pago
            SET Reembolso = @Reembolso
            WHERE Id_Pago = @Id_Pago;
        END

        -- Validar y actualizar Cantidad_Pago
        IF @Cantidad_Pago IS NOT NULL
        BEGIN
            IF @Cantidad_Pago <= 0
            BEGIN
                PRINT('La cantidad debe ser mayor a 0');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Pago
            SET Cantidad_Pago = @Cantidad_Pago
            WHERE Id_Pago = @Id_Pago;
        END

        -- Validar y actualizar Pago_Cuenta
        IF @Pago_Cuenta IS NOT NULL
        BEGIN
            UPDATE Payment.Pago
            SET Pago_Cuenta = @Pago_Cuenta
            WHERE Id_Pago = @Id_Pago;
        END

        PRINT('Pago modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al modificar el pago', 16, 1);
    END CATCH
END
GO

---------------------------------------- Para Tabla Medio ----------------------------------------
CREATE OR ALTER PROCEDURE Payment.Modificar_TipoMedio
    @Id_Tipo_Medio INT,
    @Nombre_Medio VARCHAR(25) = NULL,
    @Datos_Necesarios VARCHAR(MAX) = NULL
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Verificar existencia
        IF NOT EXISTS (SELECT 1 FROM Payment.TipoMedio WHERE Id_TipoMedio = @Id_Tipo_Medio)
        BEGIN
            PRINT('No existe un tipo de medio con ese ID');
            RAISERROR('.', 16, 1);
        END

        -- Validar y actualizar Nombre_Medio
        IF @Nombre_Medio IS NOT NULL AND @Nombre_Medio <> ''
        BEGIN
            SET @Nombre_Medio = TRIM(@Nombre_Medio);

            IF LEN(@Nombre_Medio) > 25
            BEGIN
                PRINT('Nombre de medio inválido');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.TipoMedio
            SET Nombre_Medio = @Nombre_Medio
            WHERE Id_TipoMedio = @Id_Tipo_Medio;
        END

        -- Actualizar Datos_Necesarios
        IF @Datos_Necesarios IS NOT NULL
        BEGIN
            UPDATE Payment.TipoMedio
            SET Datos_Necesarios = @Datos_Necesarios
            WHERE Id_TipoMedio = @Id_Tipo_Medio;
        END

        PRINT('Tipo de medio de pago modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al modificar el tipo de medio de pago', 16, 1);
    END CATCH
END
GO

---------------------------------------- Para Tabla Medio Pago ----------------------------------------
CREATE OR ALTER PROCEDURE Payment.Modificar_Medio_Pago
    @Id_MedioPago INT,
    @Id_TipoMedio INT = NULL,
    @Datos_Medio VARCHAR(MAX) = NULL
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Validar existencia del medio de pago
        IF NOT EXISTS (SELECT 1 FROM Payment.Medio_Pago WHERE Id_Medio_Pago = @Id_MedioPago)
        BEGIN
            PRINT('No existe un medio de pago con ese ID');
            RAISERROR('.', 16, 1);
        END

        -- Validar y actualizar Id_TipoMedio
        IF @Id_TipoMedio IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Payment.TipoMedio WHERE Id_TipoMedio = @Id_TipoMedio)
            BEGIN
                PRINT('El tipo de medio no existe');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Medio_Pago
            SET Id_TipoMedio = @Id_TipoMedio
            WHERE Id_Medio_Pago = @Id_MedioPago;
        END

        -- Actualizar Datos_Medio si se provee
        IF @Datos_Medio IS NOT NULL
        BEGIN
            UPDATE Payment.Medio_Pago
            SET Datos_Medio = @Datos_Medio
            WHERE Id_Medio_Pago = @Id_MedioPago;
        END

        PRINT('Medio de pago modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al modificar medio de pago', 16, 1);
    END CATCH
END
GO

---------------------------------------- Para Tabla Cuenta ----------------------------------------
CREATE OR ALTER PROCEDURE Payment.Modificar_Cuenta
    @Id_Persona INT,
    @SaldoCuenta DECIMAL(10,2) = NULL
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Validar existencia de la cuenta
        IF NOT EXISTS (SELECT 1 FROM Payment.Cuenta WHERE Id_Persona = @Id_Persona)
        BEGIN
            PRINT('No existe una cuenta con ese ID');
            RAISERROR('.', 16, 1);
        END

        -- Validar y actualizar saldo
        IF @SaldoCuenta IS NOT NULL
        BEGIN
            IF @SaldoCuenta < 0
            BEGIN
                PRINT('El saldo no puede ser negativo');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Cuenta
            SET SaldoCuenta = @SaldoCuenta
            WHERE Id_Persona = @Id_Persona;
        END

        PRINT('Cuenta modificada correctamente.');
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al modificar la cuenta', 16, 1);
    END CATCH
END
GO


------------------------------------------ SCHEMA GROUPS -------------------------------------------
---------------------------------------- Para Tabla Factura ----------------------------------------
CREATE OR ALTER PROCEDURE Groups.Modificar_Miembro_Familia
	@Id_Socio INT,
	@Id_Grupo INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Verificar que el socio esté vinculado a algún grupo
		IF NOT EXISTS (SELECT 1 FROM Groups.Miembro_Familia WHERE Id_Socio = @Id_Socio)
		BEGIN
			PRINT('El socio no está asociado a ningún grupo familiar');
			RAISERROR('.', 16, 1);
		END

		-- Verificar existencia del grupo familiar destino
		IF NOT EXISTS (SELECT 1 FROM Groups.Grupo_Familiar WHERE Id_Grupo_Familiar = @Id_Grupo)
		BEGIN
			PRINT('El grupo familiar destino no existe');
			RAISERROR('.', 16, 1);
		END

		-- Actualizar grupo
		UPDATE Groups.Miembro_Familia
		SET Id_Familia = @Id_Grupo
		WHERE Id_Socio = @Id_Socio;

		PRINT('Grupo familiar actualizado correctamente.');
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió un error al modificar el grupo familiar del socio', 16, 1);
			RETURN;
		END
	END CATCH
END
GO

---------------------------------------- Para Tabla Grupo Familiar ----------------------------------------
CREATE OR ALTER PROCEDURE Groups.Modificar_Grupo_Familiar
	@Id_Grupo INT,
	@Nombre_Familia VARCHAR(50) = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Verificar que el grupo exista
		IF NOT EXISTS (SELECT 1 FROM Groups.Grupo_Familiar WHERE Id_Grupo_Familiar = @Id_Grupo)
		BEGIN
			PRINT('No existe un grupo familiar con ese ID');
			RAISERROR('.', 16, 1);
		END

		-- Validar y actualizar nombre de familia
		IF @Nombre_Familia IS NOT NULL AND @Nombre_Familia <> ''
		BEGIN
			SET @Nombre_Familia = TRIM(@Nombre_Familia);

			IF LEN(@Nombre_Familia) > 50
			BEGIN
				PRINT('Nombre de familia inválido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Groups.Grupo_Familiar
			SET Nombre_Familia = @Nombre_Familia
			WHERE Id_Grupo_Familiar = @Id_Grupo;
		END

		PRINT('Grupo familiar modificado correctamente.');
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
			RAISERROR('Error al modificar el grupo familiar', 16, 1);
	END CATCH
END
GO

---------------------------------------- Para Tabla Categoria ----------------------------------------

CREATE OR ALTER PROCEDURE Groups.Modificar_Categoria
	@Id_Categoria INT,
	@Nombre_Cat VARCHAR(50) = NULL,
	@Edad_Min INT = NULL,
	@Edad_Max INT = NULL,
	@Descr VARCHAR(50) = NULL,
	@Costo DECIMAL = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Verificamos existencia
		IF NOT EXISTS (SELECT 1 FROM Groups.Categoria WHERE Id_Categoria = @Id_Categoria)
		BEGIN
			PRINT('No existe una categoría con ese ID');
			RAISERROR('.', 16, 1);
		END

		-- Nombre
		IF @Nombre_Cat IS NOT NULL AND @Nombre_Cat <> ''
		BEGIN
			SET @Nombre_Cat = TRIM(@Nombre_Cat);
			IF @Nombre_Cat LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre_Cat) > 50
			BEGIN
				PRINT('Nombre de categoría inválido');
				RAISERROR('.', 16, 1);
			END
			UPDATE Groups.Categoria SET Nombre_Cat = @Nombre_Cat WHERE Id_Categoria = @Id_Categoria;
		END

		-- Edad mínima
		IF @Edad_Min IS NOT NULL
			UPDATE Groups.Categoria SET EdadMin = @Edad_Min WHERE Id_Categoria = @Id_Categoria;

		-- Edad máxima
		IF @Edad_Max IS NOT NULL
			UPDATE Groups.Categoria SET EdadMax = @Edad_Max WHERE Id_Categoria = @Id_Categoria;

		-- Validar coherencia de edades
		IF @Edad_Min IS NOT NULL AND @Edad_Max IS NOT NULL AND @Edad_Max < @Edad_Min
		BEGIN
			PRINT('Rango de edades inválido');
			RAISERROR('.', 16, 1);
		END

		-- Descripción
		IF @Descr IS NOT NULL AND @Descr <> ''
		BEGIN
			SET @Descr = TRIM(@Descr);
			IF @Descr LIKE '%[^a-zA-Z ]%' OR LEN(@Descr) > 50
			BEGIN
				PRINT('Descripción inválida');
				RAISERROR('.', 16, 1);
			END
			UPDATE Groups.Categoria SET Descr = @Descr WHERE Id_Categoria = @Id_Categoria;
		END

		-- Costo
		IF @Costo IS NOT NULL
		BEGIN
			IF @Costo < 0
			BEGIN
				PRINT('El costo no puede ser negativo');
				RAISERROR('.', 16, 1);
			END
			UPDATE Groups.Categoria SET Costo = @Costo WHERE Id_Categoria = @Id_Categoria;
		END

		PRINT('Categoría modificada correctamente.');
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
			RAISERROR('Ocurrió un error al modificar la categoría', 16, 1);
	END CATCH
END
GO

---------------------------------------- Para Tabla Actividad ----------------------------------------

CREATE OR ALTER PROCEDURE Activity.Modificar_Actividad
	@Id_Actividad INT,
	@Nombre_Actividad VARCHAR(50) = NULL,
	@Desc_Act VARCHAR(50) = NULL,
	@Costo DECIMAL = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		IF NOT EXISTS (SELECT 1 FROM Activity.Actividad WHERE Id_Actividad = @Id_Actividad)
		BEGIN
			PRINT('La actividad no existe');
			RAISERROR('.', 16, 1);
		END

		IF @Nombre_Actividad IS NOT NULL AND @Nombre_Actividad <> ''
		BEGIN
			SET @Nombre_Actividad = TRIM(@Nombre_Actividad);
			IF @Nombre_Actividad LIKE '%[^a-zA-Z]%' OR LEN(@Nombre_Actividad) > 50
			BEGIN
				PRINT('El nombre de la actividad no es válido');
				RAISERROR('.', 16, 1);
			END
			UPDATE Activity.Actividad SET Nombre = @Nombre_Actividad WHERE Id_Actividad = @Id_Actividad;
		END

		IF @Desc_Act IS NOT NULL AND @Desc_Act <> ''
		BEGIN
			SET @Desc_Act = TRIM(@Desc_Act);
			IF @Desc_Act LIKE '%[^a-zA-Z ]%' OR LEN(@Desc_Act) > 50
			BEGIN
				PRINT('La descripción no es válida');
				RAISERROR('.', 16, 1);
			END
			UPDATE Activity.Actividad SET Descr = @Desc_Act WHERE Id_Actividad = @Id_Actividad;
		END

		IF @Costo IS NOT NULL
		BEGIN
			IF @Costo < 0
			BEGIN
				PRINT('El costo no puede ser negativo');
				RAISERROR('.', 16, 1);
			END
			UPDATE Activity.Actividad SET Costo = @Costo WHERE Id_Actividad = @Id_Actividad;
		END

		PRINT('Actividad modificada correctamente.');
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
			RAISERROR('Ocurrió un error al modificar la actividad', 16, 1);
	END CATCH
END
GO

------------------------------------ Para Tabla Actividad Extra --------------------------------------

CREATE OR ALTER PROCEDURE Activity.Modificar_Actividad_Extr
	@Id_Actividad INT,
	@Nombre_Actividad VARCHAR(50) = NULL,
	@Desc_Act VARCHAR(50) = NULL,
	@Costo_Soc DECIMAL = NULL,
	@Costo_No_Soc DECIMAL = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		IF NOT EXISTS (SELECT 1 FROM Activity.Actividad_Extra WHERE Id_Actividad_Extra = @Id_Actividad)
		BEGIN
			PRINT('La actividad extra no existe');
			RAISERROR('.', 16, 1);
		END

		IF @Nombre_Actividad IS NOT NULL AND @Nombre_Actividad <> ''
		BEGIN
			SET @Nombre_Actividad = TRIM(@Nombre_Actividad);
			IF @Nombre_Actividad LIKE '%[^a-zA-Z]%' OR LEN(@Nombre_Actividad) > 50
			BEGIN
				PRINT('El nombre de la actividad no es válido');
				RAISERROR('.', 16, 1);
			END
			UPDATE Activity.Actividad_Extra SET Nombre = @Nombre_Actividad WHERE Id_Actividad_Extra = @Id_Actividad;
		END

		IF @Desc_Act IS NOT NULL AND @Desc_Act <> ''
		BEGIN
			SET @Desc_Act = TRIM(@Desc_Act);
			IF @Desc_Act LIKE '%[^a-zA-Z ]%' OR LEN(@Desc_Act) > 50
			BEGIN
				PRINT('La descripción no es válida');
				RAISERROR('.', 16, 1);
			END
			UPDATE Activity.Actividad_Extra SET Descr = @Desc_Act WHERE Id_Actividad_Extra = @Id_Actividad;
		END

		IF @Costo_Soc IS NOT NULL
		BEGIN
			IF @Costo_Soc < 0
			BEGIN
				PRINT('El costo para socios no puede ser negativo');
				RAISERROR('.', 16, 1);
			END
			UPDATE Activity.Actividad_Extra SET Costo_Soc = @Costo_Soc WHERE Id_Actividad_Extra = @Id_Actividad;
		END

		IF @Costo_No_Soc IS NOT NULL
		BEGIN
			IF @Costo_No_Soc < 0
			BEGIN
				PRINT('El costo para no socios no puede ser negativo');
				RAISERROR('.', 16, 1);
			END
			UPDATE Activity.Actividad_Extra SET Costo = @Costo_No_Soc WHERE Id_Actividad_Extra = @Id_Actividad;
		END

		PRINT('Actividad extra modificada correctamente.');
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
			RAISERROR('Ocurrió un error al modificar la actividad extra', 16, 1);
	END CATCH
END
GO

----------------------------------- Para Tabla Horario Actividad -------------------------------------

CREATE OR ALTER PROCEDURE Activity.Modificar_Horario
	@Id_Horario INT,
	@Id_Actividad INT = NULL,
	@Id_Categoria INT = NULL,
	@Horario TIME = NULL,
	@Dias VARCHAR(100) = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		IF NOT EXISTS (SELECT 1 FROM Activity.Horario_Actividad WHERE Id_Horario = @Id_Horario)
		BEGIN
			PRINT('No existe un horario con ese ID');
			RAISERROR('.', 16, 1);
		END

		-- Validar y actualizar actividad
		IF @Id_Actividad IS NOT NULL
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM Activity.Actividad WHERE Id_Actividad = @Id_Actividad)
			BEGIN
				PRINT('La actividad indicada no existe');
				RAISERROR('.', 16, 1);
			END

			UPDATE Activity.Horario_Actividad
			SET Id_Actividad = @Id_Actividad
			WHERE Id_Horario = @Id_Horario;
		END

		-- Validar y actualizar categoría
		IF @Id_Categoria IS NOT NULL
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM Groups.Categoria WHERE Id_Categoria = @Id_Categoria)
			BEGIN
				PRINT('La categoría indicada no existe');
				RAISERROR('.', 16, 1);
			END

			UPDATE Activity.Horario_Actividad
			SET Id_Categoria = @Id_Categoria
			WHERE Id_Horario = @Id_Horario;
		END

		-- Actualizar horario
		IF @Horario IS NOT NULL
		BEGIN
			UPDATE Activity.Horario_Actividad
			SET Horario = @Horario
			WHERE Id_Horario = @Id_Horario;
		END

		-- Validar y actualizar días
		IF @Dias IS NOT NULL AND @Dias <> ''
		BEGIN
			IF @Dias LIKE '%[^a-zA-Z,]%'
			BEGIN
				PRINT('Los días contienen caracteres inválidos');
				RAISERROR('.', 16, 1);
			END

			DECLARE @Temporal TABLE (Dia VARCHAR(100));
			DECLARE @Normalizados VARCHAR(100) = '';

			INSERT INTO @Temporal
			SELECT value FROM string_split(@Dias, ',');

			SELECT @Normalizados = STRING_AGG(UPPER(LEFT(Dia,1)) + LOWER(SUBSTRING(Dia,2,LEN(Dia))), ',')
			FROM @Temporal;

			IF EXISTS (
				SELECT 1 
				FROM string_split(@Normalizados, ',') AS d
				WHERE d.value NOT IN ('Lunes','Martes','Miercoles','Jueves','Viernes','Sabado','Domingo')
			)
			BEGIN
				PRINT('Se ingresó un día inválido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Activity.Horario_Actividad
			SET Dias = @Normalizados
			WHERE Id_Horario = @Id_Horario;
		END

		PRINT('Horario modificado correctamente.');
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
			RAISERROR('Ocurrió un error al modificar el horario', 16, 1);
	END CATCH
END
GO

---------------------------------- Para Tabla Inscripto Actividad ------------------------------------

CREATE OR ALTER PROCEDURE Activity.Modificar_Inscripto_Actividad
	@Id_Horario INT,
	@Id_Socio INT,
	@Fecha_Inscripcion DATE = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		IF NOT EXISTS (
			SELECT 1 FROM Activity.Inscripto_Actividad 
			WHERE Id_Horario = @Id_Horario AND Id_Socio = @Id_Socio)
		BEGIN
			PRINT('No existe esta inscripción');
			RAISERROR('.', 16, 1);
		END

		IF @Fecha_Inscripcion IS NOT NULL
		BEGIN
			UPDATE Activity.Inscripto_Actividad
			SET Fecha_Inscripcion = @Fecha_Inscripcion
			WHERE Id_Horario = @Id_Horario AND Id_Socio = @Id_Socio;
		END

		PRINT('Inscripción modificada correctamente.');
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
			RAISERROR('Ocurrió un error al modificar la inscripción', 16, 1);
	END CATCH
END
GO

------------------------------- Para Tabla Inscripto Actividad Extra ---------------------------------

CREATE OR ALTER PROCEDURE Activity.Modificar_Inscripto_Act_Extra
	@Id_Actividad_Extra INT,
	@Id_Persona INT,
	@Fecha DATE = NULL,
	@Es_Alquiler INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validación de existencia
		IF NOT EXISTS (
			SELECT 1 FROM Activity.Inscripto_Act_Extra
			WHERE Id_Act_Extra = @Id_Actividad_Extra AND Id_Persona = @Id_Persona)
		BEGIN
			PRINT('No existe esta inscripción a actividad extra');
			RAISERROR('.', 16, 1);
		END

		-- Validar y actualizar Fecha (solo si es alquiler)
		IF @Fecha IS NOT NULL
		BEGIN
			IF @Es_Alquiler = 1
			BEGIN
				IF @Fecha < GETDATE()
				BEGIN
					PRINT('La fecha ingresada ya pasó');
					RAISERROR('.', 16, 1);
				END
				IF @Fecha > DATEADD(MONTH, 2, GETDATE())
				BEGIN
					PRINT('La fecha ingresada está a más de 2 meses');
					RAISERROR('.', 16, 1);
				END
			END

			UPDATE Activity.Inscripto_Act_Extra
			SET Fecha = @Fecha
			WHERE Id_Act_Extra = @Id_Actividad_Extra AND Id_Persona = @Id_Persona;
		END

		PRINT('Inscripción a actividad extra modificada correctamente.');
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
			RAISERROR('Ocurrió un error al modificar la inscripción a actividad extra', 16, 1);
	END CATCH
END
GO

----------------------------------- Para Tabla Referencia Detalle ------------------------------------
CREATE OR ALTER PROCEDURE Payment.Modificar_Referencia_Detalle
    @Id_Detalle INT,
    @Referencia INT = NULL,
    @Descripcion VARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Verificar existencia del registro
        IF NOT EXISTS (SELECT 1 FROM Payment.Referencia_Detalle WHERE Id_Detalle = @Id_Detalle)
        BEGIN
            PRINT('No existe un detalle con ese ID');
            RAISERROR('.', 16, 1);
        END

        -- Validar y actualizar Referencia
        IF @Referencia IS NOT NULL
        BEGIN
            IF @Referencia < 100 OR @Referencia > 400
            BEGIN
                PRINT('La referencia debe estar entre 100 y 400');
                RAISERROR('.', 16, 1);
            END

            IF EXISTS (
                SELECT 1 FROM Payment.Referencia_Detalle
                WHERE Referencia = @Referencia AND Id_Detalle <> @Id_Detalle
            )
            BEGIN
                PRINT('Ya existe otro registro con esa referencia');
                RAISERROR('.', 16, 1);
            END

            DECLARE @Tipo_Referencia INT;
            IF @Referencia > 300 SET @Tipo_Referencia = 3;
            ELSE IF @Referencia < 200 SET @Tipo_Referencia = 1;
            ELSE SET @Tipo_Referencia = 2;

            UPDATE Payment.Referencia_Detalle
            SET Referencia = @Referencia,
                Tipo_Referencia = @Tipo_Referencia
            WHERE Id_Detalle = @Id_Detalle;
        END

        -- Validar y actualizar Descripción
        IF @Descripcion IS NOT NULL AND @Descripcion <> ''
        BEGIN
            SET @Descripcion = TRIM(@Descripcion);
            IF LEN(@Descripcion) > 50
            BEGIN
                PRINT('Descripción inválida');
                RAISERROR('.', 16, 1);
            END

            UPDATE Payment.Referencia_Detalle
            SET Descripcion = @Descripcion
            WHERE Id_Detalle = @Id_Detalle;
        END

        PRINT('Referencia modificada correctamente.');
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al modificar la referencia del detalle', 16, 1);
    END CATCH
END
GO


----------------------------------------- SCHEMA JORNADA ---------------------------------------------
---------------------------------------- Para Tabla Jornada ------------------------------------------
CREATE OR ALTER PROCEDURE Jornada.Modificar_Jornada
    @Fecha DATE,
    @Lluvia INT = NULL,
    @MM DECIMAL(10,2) = NULL
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Verificar existencia
        IF NOT EXISTS (SELECT 1 FROM Jornada.Jornada WHERE Fecha = @Fecha)
        BEGIN
            PRINT('No existe una jornada con esa fecha');
            RAISERROR('.', 16, 1);
        END

        -- Lluvia
        IF @Lluvia IS NOT NULL
        BEGIN
            IF @Lluvia NOT IN (0, 1)
            BEGIN
                PRINT('El valor de lluvia debe ser 0 o 1');
                RAISERROR('.', 16, 1);
            END

            UPDATE Jornada.Jornada
            SET Lluvia = @Lluvia
            WHERE Fecha = @Fecha;
        END

        -- Milímetros
        IF @MM IS NOT NULL
        BEGIN
            IF @MM < 0
            BEGIN
                PRINT('Los milímetros no pueden ser negativos');
                RAISERROR('.', 16, 1);
            END

            UPDATE Jornada.Jornada
            SET MM = @MM
            WHERE Fecha = @Fecha;
        END

        PRINT('Jornada modificada correctamente.');
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
            RAISERROR('Error al modificar la jornada', 16, 1);
    END CATCH
END
GO
