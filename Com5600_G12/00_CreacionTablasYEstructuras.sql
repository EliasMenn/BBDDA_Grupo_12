------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro
--Del Valle, Federico
--Medina, Juan
--Mennella, Elias Damian 46357008
----------------------------------------------------------------

------------------ CREACIÓN DE BBDD -------------------

/*USE Master
  DROP DATABASE COM5600_G12*/

IF DB_ID('COM5600_G12') IS NULL
    CREATE DATABASE COM5600_G12 COLLATE Latin1_General_CI_AS;
GO	


USE COM5600_G12
GO

------------------ CREACIÓN DE ESQUEMAS -------------------
-- Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto en la creación de objetos. NO use el esquema “dbo”. --

IF SCHEMA_ID('Person') IS NULL
	EXEC('CREATE SCHEMA Person'); --El Schema User se vinculara con las tablas de Persona, Rol, Usuario, Tutor, Socio.
GO

IF SCHEMA_ID('Payment') IS NULL
	EXEC('CREATE SCHEMA Payment'); --El Schema User se vinculara con las tablas de Factura, Morosidad, Detalle_Factura, Pago, Medio_Pago, Tipo_Medio, Cuenta.
GO

IF SCHEMA_ID('Activity') IS NULL
	EXEC('CREATE SCHEMA Activity'); --El Schema Activity se vinculara con las tablas de Actividad, Horario_Actividad, Inscripto_Actividad, Actividad_Extra, Inscripto_Act_Extra
GO

IF SCHEMA_ID('Groups') IS NULL
	EXEC('CREATE SCHEMA Groups'); --El Schema Groups se vinculara con las tablas de Grupo_Familiar, Miembro_Familia, Categoria.
GO

IF SCHEMA_ID('Day') IS NULL
	EXEC('CREATE SCHEMA Day'); --El Schema Day se utilizara para la tabla de Jornada
GO

------------------ CREACIÓN DE TABLAS -------------------
-- Cree las entidades y relaciones. Incluya restricciones y claves --

IF OBJECT_ID('Person.Persona', 'U') IS NULL
BEGIN
	CREATE TABLE Person.Persona
	(
		Id_Persona INT IDENTITY(1,1) PRIMARY KEY,
		Nombre VARCHAR (25),
		Apellido VARCHAR (25),
		Email VARCHAR (50),
		Fecha_Nacimiento DATE,
		Telefono_Contacto VARCHAR(15)
	);
END

IF OBJECT_ID('Person.Tutor', 'U') IS NULL
BEGIN
	CREATE TABLE Person.Tutor
	(
		Id_Tutor INT IDENTITY(1,1) PRIMARY KEY,
		Id_Persona INT NOT NULL,
		Parentesco VARCHAR (20),
		CONSTRAINT FK_Tutor_Persona
		FOREIGN KEY (Id_Persona) REFERENCES Person.Persona(Id_Persona)
	);
END