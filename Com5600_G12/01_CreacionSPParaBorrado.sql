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
		BEGIN TRANSACTION
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
				IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK TRANSACTION
				END
				RETURN;
			END
			IF ERROR_SEVERITY() = 10
			BEGIN
				COMMIT TRANSACTION
				RETURN;
			END
	END CATCH
	COMMIT TRANSACTION
END
GO


CREATE OR ALTER PROCEDURE Groups.Borrar_Miem_Fami
	@Id_Socio INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
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
			RAISERROR('Ocurrio algo en el borrado de persona',16,1)
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Activity.Borrar_Inscripto_Extr
	@Id_Persona INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
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
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Activity.Borrar_Inscripto
	@Id_Socio INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
	BEGIN TRANSACTION
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
			RAISERROR('Ocurrio algo el borrado de inscripto',16,1)
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Payment.Borrar_Cuenta
	@Id_Persona INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		IF EXISTS(SELECT 1 FROM Payment.Cuenta WHERE Id_Persona = @Id_Persona)
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM Payment.Factura WHERE Id_Persona = @Id_Persona)
			BEGIN
				DELETE
				FROM Payment.Cuenta
				WHERE Id_Persona = @Id_Persona
			END

			ELSE

			BEGIN
				PRINT('No se pudo borrar la cuenta debido a que hay facturas vinculadas a la persona y se podria realizar una devolucion')
				RAISERROR('No se pudo borrar',16,1)
			END

		END

		ELSE

		BEGIN
			PRINT('No se encuentro la cuenta')
			RAISERROR('No se encuentro la cuenta',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de cuenta',16,1)
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Person.Borrar_Socio
	@Id_Socio INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
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
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Person.Borrar_Tutor
	@Id_Persona INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
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
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO
CREATE OR ALTER PROCEDURE Person.Borrar_Usuario
	@Id_Persona INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
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
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO 

CREATE OR ALTER PROCEDURE Payment.Borrar_Detalle_Factura
@Id_Factura INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
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

			ELSE

			BEGIN
				PRINT('La factura no se encuentra paga/anulada')
				RAISERROR('La factura no se encuentra paga/anulada',16,1)
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
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO 

CREATE OR ALTER PROCEDURE Payment.Borrar_Moroso
	@Id_Factura INT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
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

			ELSE

			BEGIN
				PRINT('La factura no se encuentra paga/anulada')
				RAISERROR('La factura no se encuentra paga/anulada',16,1)
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
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Payment.Borrar_Pago
	@Id_Factura INT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
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

			ELSE

			BEGIN
				PRINT('La factura no se encuentra paga/anulada')
				RAISERROR('La factura no se encuentra paga/anulada',16,1)
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
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Payment.Borrar_Factura
	@Id_Factura INT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		DECLARE @Estado INT
		IF EXISTS(SELECT 1 FROM Payment.Factura WHERE Id_Factura = @Id_Factura)
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
				DELETE 
				FROM Payment.Factura
			END

			ELSE

			BEGIN
				PRINT('La factura no se encuentra paga/anulada')
				RAISERROR('La factura no se encuentra paga/anulada',16,1)
			END
		END
	
		ELSE

		BEGIN 
			PRINT('La factura no se encontro')
			RAISERROR('La factura no se encontro',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de pago',16,1)
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Payment.Borrar_Medio
	@Id_Medio INTEGER
AS 
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		IF EXISTS(SELECT 1 FROM Payment.Medio_Pago WHERE Id_Persona = @Id_Medio)
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM Payment.Pago WHERE Medio_Pago = @Id_Medio)
			BEGIN
				DELETE 
				FROM Payment.Medio_Pago
				WHERE Id_Persona = @Id_Medio
			END

			ELSE

			BEGIN
				PRINT('Hay pagos vinculados a este medio, por favor verifique de eliminarlos antes de seguir')
				RAISERROR('Error al eliminar el medio',16,1)
			END

		END

		ELSE

		BEGIN
			PRINT('No se encontraron medios de pago registrados')
			RAISERROR('No se encontro el medio de pago',16,1)
		END
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de persona',16,1)
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Person.Borrar_Persona
	@Id_Persona INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		DECLARE @Id_Socio INTEGER
		DECLARE @Id_Tutor INTEGER
		DECLARE @Id_Medio INTEGER
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
					RAISERROR('No se pudo borrar a la persona ya que tiene un menor a su cargo',10,1)
				END
			END
			
			IF EXISTS(SELECT 1 FROM Payment.Factura WHERE Id_Persona = @Id_Persona)
			BEGIN
				PRINT('Se registran facturas pendientes de pago, si esto no es verdad por favor coroborre las facturas relacionadas a la persona, los modulos de Usuario, Cuenta y medio de pago no fueron desactivados')
				RAISERROR('Se registran facturas pendientes de pago, si esto no es verdad por favor coroborre las facturas relacionadas a la persona',10,1)
			END

			IF EXISTS(SELECT 1 FROM Person.Usuario WHERE Id_Persona = @Id_Persona)
			BEGIN
				EXEC Person.Borrar_Usuario
					@Id_Persona
			END

			IF EXISTS(SELECT 1 FROM Payment.Cuenta WHERE Id_Persona = @Id_Persona)
			BEGIN
				EXEC Payment.Borrar_Cuenta
					@Id_Persona
			END

			WHILE EXISTS(SELECT 1 FROM Payment.Medio_Pago WHERE Id_Persona = @Id_Persona)
			BEGIN
				SELECT @Id_Medio = Id_Medio_Pago
				FROM Payment.Medio_Pago
				WHERE Id_Persona = @Id_Persona

				EXEC Payment.Borrar_Medio
					@Id_Medio
			END
			
			DELETE
			FROM Person.Persona
			WHERE Id_Persona = @Id_Persona

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
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Jornada.Borrar_Jornada
	@Fecha DATE
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		IF EXISTS(SELECT 1 FROM Jornada.Jornada WHERE Fecha = @Fecha)
		BEGIN
			DELETE 
			FROM Jornada.Jornada
			WHERE Fecha = @Fecha
		END

		ELSE

		BEGIN
			PRINT('No se encontro la jornada')
			RAISERROR('No se encontro la jornada',16,1)
		END

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de jornada',16,1)
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Person.Borrar_Rol
	@Id_Rol INTEGER
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		IF EXISTS(SELECT 1 FROM Person.Rol WHERE Id_Rol = @Id_Rol)
			IF NOT EXISTS(SELECT 1 FROM Person.Usuario WHERE Id_Rol = @Id_Rol)
			BEGIN
				DELETE 
				FROM Person.Rol
				WHERE Id_Rol = @Id_Rol
			END

			ELSE

			BEGIN 
				PRINT('Hay usuarios con este rol, eliminelos antes de seguir')
				RAISERROR('Hay usuarios con este rol',16,1)
			END
		ELSE

		BEGIN
			PRINT('No se encontro el rol')
			RAISERROR('No se encontro el rol',16,1)
		END

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado de rol',16,1)
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Payment.Borrar_Referencia_Detalle
	@Id_Detalle INT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		DECLARE @Referencia INT
		DECLARE @Tipo INT
		IF EXISTS(SELECT 1 FROM Payment.Referencia_Detalle WHERE Id_Detalle = @Id_Detalle)
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM Payment.Detalle_Factura WHERE Id_Detalle = @Id_Detalle)
			BEGIN
				SELECT @Referencia = Referencia
				FROM Payment.Referencia_Detalle
				WHERE Id_Detalle = @Id_Detalle

				SELECT @Tipo = Tipo_Referencia
				FROM Payment.Referencia_Detalle
				WHERE Id_Detalle = @Id_Detalle
				IF(@Tipo=1)
				BEGIN
					IF EXISTS(SELECT 1 FROM Groups.Categoria WHERE Id_Categoria = @Referencia)
					BEGIN
						PRINT('Hay categorias vinculadas a esta referencia')
						RAISERROR('Hay categorias vinculadas a esta referencia',16,1)
					END
				END
				ELSE
				IF(@Tipo=2)
				BEGIN
					IF EXISTS(SELECT 1 FROM Activity.Actividad WHERE Id_Actividad = @Referencia)
					BEGIN
						PRINT('Hay categorias vinculadas a esta referencia')
						RAISERROR('Hay categorias vinculadas a esta referencia',16,1)
					END
				END
				ELSE
				IF(@Tipo=3)
				BEGIN
					BEGIN
					IF EXISTS(SELECT 1 FROM Activity.Actividad WHERE Id_Actividad = @Referencia)
					BEGIN
						PRINT('Hay categorias vinculadas a esta referencia')
						RAISERROR('Hay categorias vinculadas a esta referencia',16,1)
					END
				END
				ELSE
				BEGIN
					DELETE
					FROM Payment.Referencia_Detalle
					WHERE Id_Detalle = @Id_Detalle
				END
			END

			ELSE

			BEGIN
				PRINT('Hay facturas vinculadas a este detalle')
				RAISERROR('Hay facturas vinculadas al detalle',16,1)
			END
		END

		ELSE

		BEGIN
			PRINT('No se encontro el detalle')
			RAISERROR('No se encontro el detalle',16,1)
		END

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrio algo durante el borrado del detalle',16,1)
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN;
		END
		IF ERROR_SEVERITY() = 10
		BEGIN
			COMMIT TRANSACTION
			RETURN;
		END
	END CATCH
	COMMIT TRANSACTION
END
GO