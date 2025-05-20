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
BEGIN
	EXEC('CREATE SCHEMA Person'); --El Schema User se vinculara con las tablas de Persona, Rol, Usuario, Tutor, Socio.
END

IF SCHEMA_ID('Payment') IS NULL
BEGIN
	EXEC('CREATE SCHEMA Payment'); --El Schema User se vinculara con las tablas de Factura, Morosidad, Detalle_Factura, Pago, Medio_Pago, Tipo_Medio, Cuenta.
END

IF SCHEMA_ID('Activity') IS NULL
BEGIN
	EXEC('CREATE SCHEMA Activity'); --El Schema Activity se vinculara con las tablas de Actividad, Horario_Actividad, Inscripto_Actividad, Actividad_Extra, Inscripto_Act_Extra
END

IF SCHEMA_ID('Groups') IS NULL
BEGIN
	EXEC('CREATE SCHEMA Groups'); --El Schema Groups se vinculara con las tablas de Grupo_Familiar, Miembro_Familia, Categoria.
END

IF SCHEMA_ID('Day') IS NULL
BEGIN
	EXEC('CREATE SCHEMA Day'); --El Schema Day se utilizara para la tabla de Jornada
END

------------------ CREACIÓN DE TABLAS -------------------
-- Cree las entidades y relaciones. Incluya restricciones y claves --

-- Tablas Pertenencientes al Schema Person --
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
		Id_Persona INT UNIQUE NOT NULL,
		Parentesco VARCHAR (20),
		CONSTRAINT FK_Tutor_Persona
		FOREIGN KEY (Id_Persona) REFERENCES Person.Persona(Id_Persona)
	);
END

IF OBJECT_ID('Person.Socio', 'U') IS NULL
BEGIN
	CREATE TABLE Person.Socio
	(
		Id_Socio INT IDENTITY(1,1) PRIMARY KEY,
		Id_Persona INT UNIQUE NOT NULL,
		Id_Categoria INT NOT NULL,
		Id_Tutor INT,
		Telefono_Emergencia VARCHAR(15),
		Obra_Social VARCHAR(30),
		Nro_Obra_Social VARCHAR(20),
		CONSTRAINT FK_Socio_Persona
		FOREIGN KEY (Id_Persona) REFERENCES Person.Persona(Id_Persona),
		/*CONSTRAINT FK_Socio_Categoria
		FOREIGN KEY (Id_Categoria) REFERENCES Groups.Categoria(Id_Categoria),*/
		CONSTRAINT FK_Socio_Tutor
		FOREIGN KEY (Id_Tutor) REFERENCES Person.Tutor(Id_Tutor)

	);
END

IF OBJECT_ID('Person.Rol','U') IS NULL
BEGIN
	CREATE TABLE Person.Rol
	(	
		Id_Rol Integer PRIMARY KEY,
		Nombre_Rol VARCHAR(25),
		Desc_Rol VARCHAR(50)
	)
END

IF OBJECT_ID('Person.Usuario', 'U') IS NULL
BEGIN
	CREATE TABLE Person.Usuario
	(
		Id_Usuario INT IDENTITY(1,1) PRIMARY KEY,
		Id_Rol INT NOT NULL,
		Id_Persona INT UNIQUE NOT NULL,
		Nombre_Usuario VARCHAR(30),
		Contraseña VARCHAR(25),
		Vigencia_Contraseña DATE,
		CONSTRAINT FK_Usuario_Rol
		FOREIGN KEY (Id_Rol) REFERENCES Person.Rol(Id_Rol),
		CONSTRAINT FK_Usuario_Persona
		FOREIGN KEY (Id_Persona) REFERENCES Person.Persona(Id_Persona),
	);
END

-- Tablas Pertenecientes al Schema Payment --

IF OBJECT_ID('Payment.Factura') IS NULL
BEGIN 
	CREATE TABLE Payment.Factura
	(
		Id_Factura INT IDENTITY(1,1) PRIMARY KEY,
		Id_Persona INT NOT NULL,
		Fecha_Emision DATE,
		Fecha_Vencimiento DATE,
		Segundo_Vencimiento DATE,
		Total Decimal,
		Estado_Factura Varchar(10)
		CONSTRAINT FK_Factura_Persona
		FOREIGN KEY (Id_Persona) REFERENCES Person.Persona(Id_Persona)

	)
END 

IF OBJECT_ID('Payment.') IS NULL
BEGIN 
	CREATE TABLE Payment.Factura
	(
		Id_Factura INT IDENTITY(1,1) PRIMARY KEY,
		Id_Persona INT NOT NULL,
		Fecha_Emision DATE,
		Fecha_Vencimiento DATE,
		Segundo_Vencimiento DATE,
		Total Decimal,
		Estado_Factura Varchar(10)
		CONSTRAINT FK_Factura_Persona

	)
END 

