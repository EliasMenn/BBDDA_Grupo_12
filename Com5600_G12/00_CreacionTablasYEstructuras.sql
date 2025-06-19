------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico 43316258
--Medina, Juan 46682620
--Mennella, Elias Damian 46357008
----------------------------------------------------------------

------------------ CREACIÓN DE BBDD -------------------

-- Cambiar al contexto master
/* USE master;
GO

-- Forzar modo SINGLE_USER y cerrar todas las conexiones
ALTER DATABASE COM5600_G12
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Eliminar la base
DROP DATABASE COM5600_G12;
GO */


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
	EXEC('CREATE SCHEMA Payment'); --El Schema Payment se vinculara con las tablas de Factura, Morosidad, Detalle_Factura, Pago, Medio_Pago, Tipo_Medio, Cuenta.
END

IF SCHEMA_ID('Activity') IS NULL
BEGIN
	EXEC('CREATE SCHEMA Activity'); --El Schema Activity se vinculara con las tablas de Actividad, Horario_Actividad, Inscripto_Actividad, Actividad_Extra, Inscripto_Act_Extra
END

IF SCHEMA_ID('Groups') IS NULL
BEGIN
	EXEC('CREATE SCHEMA Groups'); --El Schema Groups se vinculara con las tablas de Grupo_Familiar, Miembro_Familia, Categoria.
END

IF SCHEMA_ID('Jornada') IS NULL
BEGIN
	EXEC('CREATE SCHEMA Jornada'); --El Schema Jornada se utilizara para la tabla de Jornada
END

------------------ CREACIÓN DE TABLAS -------------------
-- Cree las entidades y relaciones. Incluya restricciones y claves --

-- Tablas Pertenencientes al Schema Person --

IF OBJECT_ID('Person.Persona', 'U') IS NULL
BEGIN
	CREATE TABLE Person.Persona
	(
		Id_Persona INT IDENTITY(1,1) PRIMARY KEY,
		Nombre VARCHAR(25),
		Apellido VARCHAR(25),
		DNI VARCHAR(15),
		Email VARCHAR(50),
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
		Parentesco VARCHAR(20),
		CONSTRAINT FK_Tutor_Persona
		FOREIGN KEY (Id_Persona) REFERENCES Person.Persona(Id_Persona)
	);
END

IF OBJECT_ID('Person.Socio', 'U') IS NULL
BEGIN
	CREATE TABLE Person.Socio
	(
		Id_Socio VARCHAR(20) PRIMARY KEY,
		Id_Persona INT UNIQUE NOT NULL,
		Id_Categoria INT NOT NULL,
		Id_Tutor INT,
		Telefono_Emergencia VARCHAR(15),
		Obra_Social VARCHAR(100),
		Nro_Obra_Social VARCHAR(20),
		CONSTRAINT FK_Socio_Persona
		FOREIGN KEY (Id_Persona) REFERENCES Person.Persona(Id_Persona),
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
		Id_Rol INT NOT NULL,
		Id_Persona INT PRIMARY KEY,
		Nombre_Usuario VARCHAR(30),
		Contrasenia VARBINARY(32),
		Vigencia_Contrasenia DATE,
		CONSTRAINT FK_Usuario_Rol
		FOREIGN KEY (Id_Rol) REFERENCES Person.Rol(Id_Rol),
		CONSTRAINT FK_Usuario_Persona
		FOREIGN KEY (Id_Persona) REFERENCES Person.Persona(Id_Persona)
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

IF OBJECT_ID('Payment.Referencia_Detalle') IS NULL
BEGIN 
	CREATE TABLE Payment.Referencia_Detalle
	(
		Referencia INT,		--Referencias arrancando en 100 = Categoria, 200 = Actividad, 300 = Actividad_Extra
		Tipo_Referencia INT, -- Lo utilizamos para saber donde buscar, 1 tabla categorias, 2 tabla actividad, 3 tabla actividad extra
		Descripcion VARCHAR(50),
		Id_Detalle INT IDENTITY(1,1) PRIMARY KEY  -- Clave primaria necesaria para FK
	)
END 

IF OBJECT_ID('Payment.Detalle_Factura') IS NULL
BEGIN 
	CREATE TABLE Payment.Detalle_Factura
	(
		Id_Factura INT,
		Id_Detalle INT,
		Concepto VARCHAR(50),
		Monto DECIMAL,
		Descuento_Familiar INT,
		Id_Familia INT,
		Descuento_Act INT,
		Descuento_Lluvia INT,
		CONSTRAINT PK_Detalle_Factura PRIMARY KEY (Id_Factura),
		CONSTRAINT FK_Detalle_Factura FOREIGN KEY (Id_Factura) REFERENCES Payment.Factura(Id_Factura),
		CONSTRAINT FK_Detalle_Referencia FOREIGN KEY (Id_Detalle) REFERENCES Payment.Referencia_Detalle(Id_Detalle)
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
		Medio_Pago VARCHAR(50),
		Monto DECIMAL,
		Reembolso INT,
		Cantidad_Pago DECIMAL,
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
		Id_Persona INT,
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

-- Tablas Pertenecientes al Schema Activity --

IF OBJECT_ID('Activity.Actividad') IS NULL
BEGIN
	CREATE TABLE Activity.Actividad
	(
		Id_Actividad INT IDENTITY (200,1) PRIMARY KEY,
		Nombre VARCHAR(50),
		Costo DECIMAL,
		Vigencia DATE
	)
END

IF OBJECT_ID('Activity.Actividad_Extra') IS NULL
BEGIN
	CREATE TABLE Activity.Actividad_Extra
	(
		Id_Actividad_Extra INT IDENTITY (300,1) PRIMARY KEY,
		Nombre VARCHAR(50),
		Descr VARCHAR(50),
		Costo_Soc DECIMAL,
		Costo DECIMAL,
	)
END

IF OBJECT_ID('Activity.Horario_Actividad') IS NULL
BEGIN 
	CREATE TABLE Activity.Horario_Actividad
	(
		Id_Horario INT IDENTITY (1,1) PRIMARY KEY, 
		Id_Actividad INT,
		Id_Categoria INT,
		Horario TIME,
		Dias VARCHAR(100)
		CONSTRAINT FK_Horario__Actividad
		FOREIGN KEY (Id_Actividad) REFERENCES Activity.Actividad(Id_Actividad)
	)
END

IF OBJECT_ID('Activity.Inscripto_Actividad') IS NULL
BEGIN 
	CREATE TABLE Activity.Inscripto_Actividad
	(
		Id_Horario INT,
		Id_Socio VARCHAR(20),
		Fecha_Inscripcion DATE,
		CONSTRAINT FK_Inscripto_Horario
		FOREIGN KEY (Id_Horario) REFERENCES Activity.Horario_Actividad(Id_Horario),
		CONSTRAINT FK_Inscripto_Socio
		FOREIGN KEY (Id_Socio) REFERENCES Person.Socio(Id_Socio),
	)
END

IF OBJECT_ID('Activity.Inscripto_Act_Extra') IS NULL
BEGIN 
	CREATE TABLE Activity.Inscripto_Act_Extra
	(
		Id_Act_Extra INT,
		Fecha DATE,
		Id_Persona INT,
		CONSTRAINT FK_InscrExt_ActExt
		FOREIGN KEY (Id_Act_Extra) REFERENCES Activity.Actividad_Extra(Id_Actividad_Extra),
		CONSTRAINT FK_InscrExt_Persona
		FOREIGN KEY (Id_Persona) REFERENCES Person.Persona(Id_Persona),

	)
END

IF OBJECT_ID('Activity.Asistencia') IS NULL
BEGIN 
	CREATE TABLE Activity.Asistencia
	(
		Id_Socio VARCHAR(20),
		Nombre_Act NVARCHAR(30),
		Fecha DATE,
		Asistencia CHAR(1),
		Profesor NVARCHAR(50)
		CONSTRAINT FK_Asistencia_Socio
		FOREIGN KEY (Id_Socio) REFERENCES Person.Socio
	)
END 

-- Tablas Pertenecientes al Schema Groups --

IF OBJECT_ID('Groups.Categoria') IS NULL
BEGIN 
	CREATE TABLE Groups.Categoria
	(
		Id_Categoria INT PRIMARY KEY IDENTITY (100,1),
		Nombre_Cat VARCHAR(50),
		EdadMin INT,
		EdadMax INT,
		Descr VARCHAR(50),
		Costo DECIMAL,
	)
END


IF OBJECT_ID('Groups.Grupo_Familiar') IS NULL
BEGIN 
	CREATE TABLE Groups.Grupo_Familiar
	(
		Id_Grupo_Familiar INT IDENTITY(1,1) PRIMARY KEY,
		Nombre_Familia VARCHAR(50),
		Activo INT,
	)
END

IF OBJECT_ID('Groups.Miembro_Familia') IS NULL
BEGIN 
	CREATE TABLE Groups.Miembro_Familia
	(
		Id_Socio VARCHAR(20), 
		Id_Familia INT
		CONSTRAINT FK_Familia_Socio
		FOREIGN KEY (Id_Socio) REFERENCES Person.Socio(Id_Socio),
		CONSTRAINT FK_Socio_Familia
		FOREIGN KEY (Id_Familia) REFERENCES Groups.Grupo_Familiar(Id_Grupo_Familiar)
	)
END

-- Tablas Pertenecientes al Schema Jornada --

IF OBJECT_ID('Jornada.Jornada') IS NULL
BEGIN
	CREATE TABLE Jornada.Jornada
	(
		Fecha DATE PRIMARY KEY,
		Lluvia Integer,
		MM Decimal
	)
END

-- Agregamos FK que no se pudieron agregar al momento de crear las tablas --

IF OBJECT_ID('Person.Socio','U') IS NOT NULL
BEGIN
	IF NOT EXISTS(
		SELECT 1
		FROM sys.foreign_keys
		WHERE name = 'FK_Socio_Categoria'
		AND parent_object_id = OBJECT_ID('Person.Socio','U')
	)
	BEGIN
		ALTER TABLE Person.Socio
		ADD CONSTRAINT FK_Socio_Categoria
		FOREIGN KEY (Id_Categoria) REFERENCES Groups.Categoria(Id_Categoria)
	END
END

IF OBJECT_ID('Payment.Detalle_Factura','U') IS NOT NULL
BEGIN
	IF NOT EXISTS(
		SELECT 1
		FROM sys.foreign_keys
		WHERE name = 'FK_Detalle_Familia'
		AND parent_object_id = OBJECT_ID('Payment.Detalle_Factura','U')
	)
	BEGIN 
		ALTER TABLE Payment.Detalle_Factura 
		ADD CONSTRAINT FK_Detalle_Familia
		FOREIGN KEY (Id_Familia) REFERENCES Groups.Grupo_Familiar(Id_Grupo_Familiar)
	END
END

IF OBJECT_ID('Activity.Horario_Actividad','U') IS NOT NULL
BEGIN
	IF NOT EXISTS(
		SELECT 1
		FROM sys.foreign_keys
		WHERE name = 'FK_Horario_Categoria'
		AND parent_object_id = OBJECT_ID('Activity.Horario_Actividad','U')
	)
	BEGIN 
		ALTER TABLE Activity.Horario_Actividad 
		ADD CONSTRAINT FK_Horario_Categoria
		FOREIGN KEY (Id_Categoria) REFERENCES Groups.Categoria(Id_Categoria)
	END
END

IF OBJECT_ID('Activity.Inscripto_Act_Extra','U') IS NOT NULL
BEGIN 
	IF NOT EXISTS(
		SELECT 1
		FROM sys.foreign_keys
		WHERE name = 'FK_InscrExt_Jornada'
		AND parent_object_id = OBJECT_ID('Activity.Inscripto_Act_Extra','U')
	)
	BEGIN 
		ALTER TABLE Activity.Inscripto_Act_Extra
		ADD CONSTRAINT FK_InscrExt_Jornada
		FOREIGN KEY (FECHA) REFERENCES Jornada.Jornada(Fecha)
	END
END