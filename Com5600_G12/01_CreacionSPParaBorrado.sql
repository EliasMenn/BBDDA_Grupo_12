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
			RAISERROR('Ocurrio algo el borrado de familia',16,1)
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

CREATE OR ALTER PROCEDURE Person.Borrar_Persona
	@Id_Persona INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
	DECLARE @Id_Socio INTEGER
		IF EXISTS(SELECT 1 FROM Person.Persona WHERE Id_Persona = @Id_Persona)
		BEGIN
			IF EXISTS(SELECT 1 FROM Person.Socio WHERE Id_Persona = @Id_Persona)
			BEGIN
				SELECT @Id_Socio = Id_Socio FROM Person.Socio WHERE Id_Persona = @Id_Persona
				EXEC Person.Borrar_Socio
					@Id_Socio
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
