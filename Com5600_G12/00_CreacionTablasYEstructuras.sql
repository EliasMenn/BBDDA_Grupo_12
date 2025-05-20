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

IF OBJECT_ID('Payment.Detalle_Factura') IS NULL
BEGIN 
	CREATE TABLE Payment.Detalle_Factura
	(
		Id_Detalle INT IDENTITY(1,1) PRIMARY KEY,
		Id_Factura INT NOT NULL,
		Concepto Varchar(50),
		Monto Decimal,
		Descuento_Familiar INT,
		Id_Familia INT,
		Descuento_Act INT,
		Descuento_Lluvia INT,
		CONSTRAINT FK_Detalle_Factura
		FOREIGN KEY (Id_Factura) REFERENCES Payment.Factura(Id_Factura)
		/*CONSTRAINT FK_Detalle_Familia
		FOREIGN KEY (Id_Familia) REFERENCES Groups.Grupo_Familiar(Id_Grupo_Familiar)*/
	)
END 

IF OBJECT_ID('Payment.Morosidad') IS NULL
BEGIN
	CREATE TABLE Payment.Morosidad
	(
		Id_Factura INT PRIMARY KEY,
		Segundo_Vencimiento DATE,
		Recargo DECIMAL,
		Bloqueado INTEGER,
		Fecha_Bloqueo DATE
		CONSTRAINT FK_Morosidad_Factura
		FOREIGN KEY (Id_Factura) REFERENCES Payment.Factura(Id_Factura)
	)
END

IF OBJECT_ID('Payment.Pago') IS NULL
BEGIN
	CREATE TABLE Payment.Pago
	(
		Id_Pago INT IDENTITY (1,1) PRIMARY KEY,
		Id_Factura INT,
		Fecha_Pago DATE,
		Medio_Pago DATE,
		Monto DECIMAL,
		Reembolso INT,
		CAntidadPago DECIMAL,
		Pago_Cuenta INT
		CONSTRAINT FK_Pago_Factura
		FOREIGN KEY (Id_Factura) REFERENCES Payment.Factura(Id_Factura)
	)
END

IF OBJECT_ID('Payment.TipoMedio') IS NULL
BEGIN
	CREATE TABLE Payment.TipoMedio
	(
		Id_TipoMedio INT IDENTITY (1,1) PRIMARY KEY,
		Nombre_Medio VARCHAR(25),
		Datos_Necesarios VARCHAR(MAX)
	)
END

IF OBJECT_ID('Payment.Medio_Pago') IS NULL
BEGIN
	CREATE TABLE Payment.Medio_Pago
	(
		Id_Medio_Pago INT IDENTITY (1,1) PRIMARY KEY,
		Id_Socio INT,
		Id_TipoMedio INT,
		Datos_Medio VARCHAR(MAX)
		CONSTRAINT FK_Medio_Tipo
		FOREIGN KEY (Id_TipoMedio) REFERENCES Payment.TipoMedio(Id_TipoMedio)
	)
END

IF OBJECT_ID('Payment.Cuenta') IS NULL
BEGIN 
	CREATE TABLE Payment.Cuenta
	(
		Id_Persona INT PRIMARY KEY,
		SaldoCuenta DECIMAL
		CONSTRAINT FK_Cuenta_Persona
		FOREIGN KEY (Id_Persona) REFERENCES Person.Persona(Id_Persona)
	)
END