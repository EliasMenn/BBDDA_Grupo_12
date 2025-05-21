------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico
--Medina, Juan
--Mennella, Elias Damian 46357008
----------------------------------------------------------------

USE master

USE Com5600_G12
GO


------------- CREACION DE STORE PROCEDURE -------------

-- ENUNCIADO: Genere store procedures para manejar la inserción, modificado, borrado de cada tabla. --

-- Para Tabla Persona --

CREATE OR ALTER PROCEDURE Person.Agr_Persona
	@Nombre VARCHAR (25),
	@Apellido VARCHAR (25),
	@DNI VARCHAR(10),
	@Email VARCHAR (50),
	@Fecha_Nacimiento DATE,
	@Telefono_Contacto VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Id INT;
	--Validamos que no exista el mismo DNI--
	IF EXISTS(SELECT 1 FROM Person.Persona WHERE DNI = @DNI)
	BEGIN
		RAISERROR('Ya existe la persona con DNI: "%s"', 10,1,@DNI);
		RETURN
	END
	--Limpiamos y Validamos los string--

	IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z]%' OR LEN(@Nombre) > 25
	BEGIN
		RAISERROR('El nombre no es valido', 16,1)
		RETURN
	END
	SET @Nombre = TRIM(@Nombre);

	IF @Apellido ='' OR @Apellido LIKE '%[^a-zA-Z]%' OR LEN(@Apellido) > 25
	BEGIN
		RAISERROR('El apellido no es valido.', 16,1)
		RETURN
	END
	SET @Apellido = TRIM(@Apellido);

	IF @DNI ='' OR @DNI LIKE '%[^0-9]%' OR LEN(@DNI) > 10
	BEGIN
		RAISERROR('El DNI no es valido.', 16,1)
		RETURN
	END
		SET @DNI = TRIM(@DNI);

	IF @Email ='' OR @Email NOT LIKE '%@%.%' OR LEN(@Email) > 50
	BEGIN
		RAISERROR('El mail no es valido.', 16,1)
		RETURN
	END
	SET @Email = TRIM(@Email);

	IF @Fecha_Nacimiento IS NULL OR (@Fecha_Nacimiento NOT BETWEEN '1930-01-01' AND GETDATE())
	BEGIN
		RAISERROR('La fecha de nacimiento no es valida.', 16,1)
		RETURN
	END


	IF @Telefono_Contacto ='' OR @Telefono_Contacto LIKE '%[^0-9]%' OR LEN(@Telefono_Contacto) > 50
	BEGIN
		RAISERROR('El Telefono no es valido.', 16,1)
		RETURN
	END
	SET @Telefono_Contacto = TRIM(@Telefono_Contacto);

	INSERT INTO Person.Persona (Nombre, Apellido, DNI, Email, Fecha_Nacimiento, Telefono_Contacto)
	VALUES (@Nombre, @Apellido, @DNI, @Email, @Fecha_Nacimiento, @Telefono_Contacto)
	SET @Id = SCOPE_IDENTITY();
	RETURN @Id
END
