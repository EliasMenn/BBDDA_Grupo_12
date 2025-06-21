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


---Encriptado de datos del Usuario-Persona-Socio
CREATE OR ALTER PROCEDURE Person.Encriptar_Empleado
    @Id_Persona INT
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        DECLARE @FraseSecreta NVARCHAR(128) = 'VivaelFulvol';

        DECLARE @Nombre_Usuario_Cifrado VARBINARY(MAX) 
        DECLARE @Nombre_Cifrado VARBINARY(MAX)
        DECLARE @Apellido_Cifrado VARBINARY(MAX)
        DECLARE @DNI_Cifrado VARBINARY(MAX)
        DECLARE @Email_Cifrado VARBINARY(MAX)
        DECLARE @Telefono_Contacto_Cifrado VARBINARY(MAX)
        DECLARE @Telefono_Emergencia_Cifrado VARBINARY(MAX)
        DECLARE @Obra_Social_Cifrado VARBINARY(MAX)
        DECLARE @Nro_Obra_Social_Cifrado VARBINARY(MAX)

        DECLARE @Nombre_Usuario VARCHAR(30)
        DECLARE @Nombre VARCHAR(25)
        DECLARE @Apellido VARCHAR(25)
        DECLARE @DNI VARCHAR(15)
        DECLARE @Email VARCHAR(50)
        DECLARE @Telefono_Contacto VARCHAR(15)
        DECLARE @Telefono_Emergencia VARCHAR(15)
        DECLARE @Obra_Social VARCHAR(100)
        DECLARE @Nro_Obra_Social VARCHAR(20)
 

        -- Validar existencia de la persona
        IF NOT EXISTS (SELECT 1 FROM Person.Persona WHERE Id_Persona = @Id_Persona)
        BEGIN
            RAISERROR('La persona con el Id especificado no existe.', 16, 1);
            RETURN;
        END
		
		
		SELECT TOP 1 
		@Nombre_Usuario = u.Nombre_Usuario,
		@Nombre = p.Nombre, 
		@Apellido = p.Apellido, 
		@DNI = p.DNI, 
		@Email = p.Email, 
		@Telefono_Contacto = p.Telefono_Contacto,
		@Telefono_Emergencia = s.Telefono_Emergencia,
		@Obra_Social = s.Obra_Social,
		@Nro_Obra_Social = s.Nro_Obra_Social
		FROM Person.Persona p 
		JOIN Person.Socio s ON s.Id_Persona = p.Id_Persona 
		JOIN Person.Usuario u ON u.Id_Persona = p.Id_Persona
		WHERE p.Id_Persona = @Id_Persona 
		


		IF NOT EXISTS (SELECT 1 FROM Person.Persona p
		JOIN Person.Usuario u ON u.Id_persona = p.Id_Persona 
		WHERE u.Id_Rol = 6) 
		BEGIN 
		
		SET @Nombre_Cifrado = EncryptByPassPhrase(@FraseSecreta, @Nombre);
        SET @Apellido_Cifrado = EncryptByPassPhrase(@FraseSecreta, @Apellido);
        SET @DNI_Cifrado = EncryptByPassPhrase(@FraseSecreta, @DNI);
        SET @Email_Cifrado = EncryptByPassPhrase(@FraseSecreta, @Email);
        SET @Telefono_Contacto_Cifrado = EncryptByPassPhrase(@FraseSecreta, @Telefono_Contacto);		
		SET @Nombre_Usuario_Cifrado = EncryptByPassPhrase(@FraseSecreta, @Nombre_Usuario);

		SET @Telefono_Emergencia_Cifrado = EncryptByPassPhrase(@FraseSecreta, @Telefono_Emergencia);
        SET @Obra_Social_Cifrado = EncryptByPassPhrase(@FraseSecreta, @Obra_Social);
        SET @Nro_Obra_Social_Cifrado = EncryptByPassPhrase(@FraseSecreta, @Nro_Obra_Social);
		
		UPDATE Person.Socio
		SET 
			Telefono_Emergencia_Cifrado = @Telefono_Emergencia_Cifrado,
			Obra_Social_Cifrado = @Obra_Social_Cifrado,
			Nro_Obra_Social_Cifrado = @Nro_Obra_Social_Cifrado,
			
			Telefono_Emergencia = NULL,
			Obra_Social = NULL,
			Nro_Obra_Social = NULL
		WHERE Id_Persona = @Id_Persona

		UPDATE Person.Usuario
			SET 
			Nombre_Usuario_Cifrado = @Nombre_Usuario_Cifrado,
			Nombre_Usuario = NULL
		WHERE Id_Persona = @Id_Persona;

		UPDATE Person.Persona
		SET 
			Nombre_Cifrado = @Nombre_Cifrado,
			Apellido_Cifrado = @Apellido_Cifrado,
			DNI_Cifrado = @DNI_Cifrado,
			Email_Cifrado = @Email_Cifrado,
			Telefono_Contacto_Cifrado = @Telefono_Contacto_Cifrado,
			Nombre = NULL,
			Apellido = NULL,
			DNI = NULL,
			Email = NULL,
			Telefono_Contacto = NULL
		WHERE Id_Persona = @Id_Persona;

		END

    END TRY
    BEGIN CATCH
        RAISERROR('Error',16,1);
    END CATCH
END;