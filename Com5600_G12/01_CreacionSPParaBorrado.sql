Use master

USE Com5600_G12
GO

------------- CREACION DE STORE PROCEDURE -------------

-- ENUNCIADO: Genere store procedures para manejar el borrado --
CREATE OR ALTER PROCEDURE Groups.Borrar_Familia
	@Id_Familia INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM Groups.Grupo_Familiar WHERE Id_Grupo_Familiar = @Id_Familia)
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM Payment.Detalle_Factura WHERE Id_Familia = @Id_Familia)
			BEGIN
				DELETE FROM Groups.Miembro_Familia
				WHERE Id_Familia = @Id_Familia

				DELETE FROM Groups.Grupo_Familiar
				WHERE Id_Grupo_Familiar = @Id_Familia
			END 

			ELSE

			PRINT('No se pudo borrar el grupo familiar debido a que hay una factura impaga vinculada al mismo')
			RAISERROR('No se pudo borrar el grupo familiar debido a que hay una factura impaga vinculada al mismo',10,1)
		END
		ELSE

		BEGIN
			PRINT('No existe la familia')
			RAISERROR('No existe la familia',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo en el borrado de familia',16,1)
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			RETURN;
		END
	END CATCH
END
GO


CREATE OR ALTER PROCEDURE Groups.Borrar_Miem_Fami
	@Id_Socio INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
	DECLARE @Id_Familia INTEGER
		IF EXISTS(SELECT 1 FROM Groups.Miembro_Familia WHERE Id_Socio = @Id_Socio)
		BEGIN

			SELECT @Id_Familia = Id_Familia
			FROM Groups.Miembro_Familia
			WHERE Id_Socio = @Id_Socio

			DELETE
			FROM Groups.Miembro_Familia
			WHERE Id_Socio = @Id_Socio

			IF NOT EXISTS(SELECT 1 FROM Groups.Miembro_Familia WHERE Id_Familia = @Id_Familia)
			BEGIN
				UPDATE Groups.Grupo_Familiar
				SET ACTIVO = 1
				WHERE Id_Grupo_Familiar = @Id_Familia

				EXEC Groups.Borrar_Familia
				@Id_Familia
			END
		END 

		ELSE

		BEGIN
			PRINT('No existe la persona')
			RAISERROR('No existe la persona',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo el borrado de persona',16,1)
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			RETURN;
		END
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE Activity.Borrar_Inscripto_Extr
	@Id_Persona INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM Activity.Inscripto_Act_Extra WHERE Id_Persona = @Id_Persona)
		BEGIN
			DELETE
			FROM Activity.Inscripto_Actividad
			WHERE @Id_Persona = @Id_Persona
		END 

		ELSE

		BEGIN
			PRINT('No existe el inscripto')
			RAISERROR('No existe el inscripto',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo el borrado de inscripto',16,1)
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			RETURN;
		END
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE Activity.Borrar_Inscripto
	@Id_Socio INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM Activity.Inscripto_Actividad WHERE Id_Socio = @Id_Socio)
		BEGIN
			DELETE
			FROM Activity.Inscripto_Actividad
			WHERE Id_Socio = @Id_Socio
		END 

		ELSE

		BEGIN
			PRINT('No existe el inscripto')
			RAISERROR('No existe el inscripto',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo el borrado de persona',16,1)
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			RETURN;
		END
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE Person.Borrar_Socio
	@Id_Socio INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM Person.Socio WHERE Id_Socio = @Id_Socio)
		BEGIN
			IF EXISTS(SELECT 1 FROM Groups.Miembro_Familia WHERE Id_Socio = @Id_Socio)
			BEGIN
				EXEC Groups.Borrar_Miem_Fami
					@Id_Socio
			END
			IF EXISTS(SELECT 1 FROM Activity.Inscripto_Actividad WHERE Id_Socio = @Id_Socio)
			BEGIN
				EXEC Activity.Borrar_Inscripto
					@Id_Socio
			END
			DELETE
			FROM Person.Socio
			WHERE Id_Socio = @Id_Socio
		END

		ELSE

		BEGIN
			PRINT('No existe el socio')
			RAISERROR('No existe el socio',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de socio',16,1)
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			RETURN;
		END
	END CATCH
END
GO
CREATE OR ALTER PROCEDURE Person.Borrar_Tutor
	@Id_Persona INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY

		IF EXISTS(SELECT 1 FROM Person.Tutor WHERE Id_Persona = @Id_Persona)
		BEGIN
			DECLARE @Id_Tutor INTEGER
			SELECT @Id_Tutor = Id_Tutor
			FROM Person.Tutor
			WHERE Id_Persona = @Id_Persona
			IF NOT EXISTS (SELECT 1 FROM Person.Socio WHERE Id_Tutor = @Id_Tutor)
			BEGIN
				DELETE 
				FROM Person.Tutor
				WHERE Id_Persona = @Id_Persona
			END
			ELSE
			BEGIN
				PRINT('No se pudo borrar el tutor ya que tiene un menor a cargo')
				RAISERROR('No se pudo borrar el tutor ya que tiene un menor a cargo',16,1)
			END
		END
		ELSE
		BEGIN
			PRINT('No existe el tutor')
			RAISERROR('No existe el tutor',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de tutor',16,1)
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			RETURN;
		END
	END CATCH
END
GO
CREATE OR ALTER PROCEDURE Person.Borrar_Usuario
	@Id_Persona INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM Person.Usuario WHERE Id_Persona = @Id_Persona)
		BEGIN
			DELETE 
			FROM Person.Usuario
			WHERE Id_Persona = @Id_Persona
		END
	
		ELSE

		BEGIN 
			PRINT('No se encontro un usuario con este Id')
			RAISERROR('No se encontro un usuario con este Id',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de Usuario',16,1)
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			RETURN;
		END
	END CATCH
END
GO 

CREATE OR ALTER PROCEDURE Payment.Borrar_Detalle_Factura
@Id_Factura INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		DECLARE @Id_Familia INT
		DECLARE @Estado VARCHAR(10)
		DECLARE @Activo INT
		IF EXISTS(SELECT 1 FROM Payment.Detalle_Factura WHERE Id_Factura = @Id_Factura)
		BEGIN
			SELECT @Estado = Estado_Factura
			FROM Payment.Factura
			WHERE Id_Factura = @Id_Factura
			IF(LOWER(@Estado) LIKE 'pagada' OR LOWER(@Estado) LIKE 'anulada')
			BEGIN
				SELECT @Id_Familia = Id_Familia
				FROM Payment.Detalle_Factura
				WHERE Id_Factura = @Id_Factura
				IF EXISTS(SELECT 1 FROM Groups.Grupo_Familiar WHERE Id_Grupo_Familiar = @Id_Familia)
				BEGIN
					SELECT @Activo = Activo
					FROM Groups.Grupo_Familiar
					WHERE Id_Grupo_Familiar = @Id_Factura
					IF @Activo = 1
					EXEC Groups.Borrar_Familia
						@Id_Familia
				END
				DELETE 
				FROM Payment.Detalle_Factura
				WHERE Id_Factura = @Id_Factura
			END
		END
	
		ELSE

		BEGIN 
			PRINT('No se encontro un detalle')
			RAISERROR('No se encontro un detalle',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de este detalle',16,1)
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			RETURN;
		END
	END CATCH
END
GO 

CREATE OR ALTER PROCEDURE Payment.Borrar_Moroso
	@Id_Factura INT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
	DECLARE @Estado INT
		IF EXISTS(SELECT 1 FROM Payment.Morosidad WHERE Id_Factura = @Id_Factura)
		BEGIN
			SELECT @Estado = Estado_Factura
			FROM Payment.Factura
			WHERE Id_Factura = @Id_Factura
			IF(LOWER(@Estado) LIKE 'pagada' OR LOWER(@Estado) LIKE 'anulada')
			BEGIN
				DELETE
				FROM Payment.Morosidad
				WHERE Id_Factura = @Id_Factura
			END
		END
	
		ELSE

		BEGIN 
			PRINT('No se encontro un moroso')
			RAISERROR('No se encontro un moroso',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de morosidad',16,1)
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			RETURN;
		END
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE Payment.Borrar_Pago
	@Id_Factura INT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
	DECLARE @Estado INT
		IF EXISTS(SELECT 1 FROM Payment.Pago WHERE Id_Factura = @Id_Factura)
		BEGIN
			SELECT @Estado = Estado_Factura
			FROM Payment.Factura
			WHERE Id_Factura = @Id_Factura
			IF(LOWER(@Estado) LIKE 'pagada' OR LOWER(@Estado) LIKE 'anulada')
			BEGIN
				DELETE
				FROM Payment.Pago
				WHERE Id_Factura = @Id_Factura
			END
		END
	
		ELSE

		BEGIN 
			PRINT('No se encontro un pago')
			RAISERROR('No se encontro un pago',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de pago',16,1)
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			RETURN;
		END
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE Payment.Borrar_Factura
	@Id_Factura INT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
	DECLARE @Estado INT
		IF EXISTS(SELECT 1 FROM Payment.Pago WHERE Id_Factura = @Id_Factura)
		BEGIN
			SELECT @Estado = Estado_Factura
			FROM Payment.Factura
			WHERE Id_Factura = @Id_Factura
			IF(LOWER(@Estado) LIKE 'pagada' OR LOWER(@Estado) LIKE 'anulada')
			BEGIN
				IF EXISTS(SELECT 1 FROM Payment.Detalle_Factura WHERE Id_Factura = @Id_Factura)
				BEGIN 
					EXEC Payment.Borrar_Detalle_Factura
						@Id_Factura
				END
				IF EXISTS(SELECT 1 FROM Payment.Morosidad WHERE Id_Factura = @Id_Factura)
				BEGIN
					EXEC Payment.Borrar_Moroso
						@Id_Factura
				END
				IF EXISTS(SELECT 1 FROM Payment.Pago WHERE Id_Factura = @Id_Factura)
				BEGIN
					EXEC Payment.Borrar_Pago
						@Id_Factura
				END
			END
		END
	
		ELSE

		BEGIN 
			PRINT('No se encontro un pago')
			RAISERROR('No se encontro un pago',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de pago',16,1)
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			RETURN;
		END
	END CATCH
END
GO


CREATE OR ALTER PROCEDURE Person.Borrar_Persona
	@Id_Persona INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		DECLARE @Id_Socio INTEGER
		DECLARE @Id_Tutor INTEGER
		IF EXISTS(SELECT 1 FROM Person.Persona WHERE Id_Persona = @Id_Persona)
		BEGIN
			IF EXISTS(SELECT 1 FROM Person.Socio WHERE Id_Persona = @Id_Persona)
			BEGIN
				SELECT @Id_Socio = Id_Socio FROM Person.Socio WHERE Id_Persona = @Id_Persona
				EXEC Person.Borrar_Socio
					@Id_Socio
			END

			IF EXISTS(SELECT 1 FROM Activity.Inscripto_Act_Extra WHERE Id_Persona = @Id_Persona)
			BEGIN
				EXEC Activity.Borrar_Inscripto_Extr
					@Id_Persona
			END
			IF EXISTS(SELECT 1 FROM Person.Tutor WHERE Id_Persona = @Id_Persona)
			BEGIN
				SELECT @Id_Tutor = Id_tutor
				FROM Person.Tutor
				WHERE Id_Persona = @Id_Persona
				IF NOT EXISTS(SELECT 1 FROM Person.Socio WHERE Id_Tutor = @Id_Tutor)
				BEGIN
					EXEC Person.Borrar_Tutor
						@Id_Persona
				END

				ELSE

				BEGIN
					PRINT('No se pudo borrar a la persona ya que tiene un menor a su cargo, Fue dada de baja como socio y de otras actividades.')
					RAISERROR('No se pudo borrar a la persona ya que tiene un menor a su cargo',16,1)
				END
			END
		END

		ELSE

		BEGIN
			PRINT('No existe la persona')
			RAISERROR('No existe la persona',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de persona',16,1)
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			RETURN;
		END
	END CATCH
END
