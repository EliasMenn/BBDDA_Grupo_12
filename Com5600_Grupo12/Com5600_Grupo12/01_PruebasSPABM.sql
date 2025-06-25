
------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico 43316258
--Medina, Juan 46682620
--Mennella, Elias Damian 46357008
----------------------------------------------------------------

-- Prueba de los Stored Procedure --
USE master

USE Com5600_G12
GO



-- AGREGAR, MODIFICAR y BORRAR Personas --
/* DELETE FROM Person.Persona
DBCC CHECKIDENT ('Person.Persona', RESEED, 0); */

-- Crear persona de prueba
DECLARE @IdPersona INT;
EXEC @IdPersona = Person.Agr_Persona
	@Nombre = 'Pedro',
	@Apellido = 'Melissari',
	@DNI = '46912033',
	@Email = 'pedromelissari@mail.com',
	@Fecha_Nacimiento = '2005-07-22',
	@Telefono_Contacto = '1111222233';

--  Mostrar antes de modificar
PRINT ' Persona antes de modificar:';
SELECT * FROM Person.Persona WHERE Id_Persona = @IdPersona;

-- Modificar nombre, apellido y teléfono
EXEC Person.Modificar_Persona
	@Id_Persona = @IdPersona,
	@Nombre = 'Elias',
	@Apellido = 'Mennella',
	@Telefono_Contacto = ''; -- Deberia quedar el mismo

-- Mostrar después
PRINT ' Persona después de modificar:';
SELECT * FROM Person.Persona WHERE Id_Persona = @IdPersona;

-- Intento de poner un DNI ya existente (error esperado)
DECLARE @DNIExistente VARCHAR(10);
SELECT TOP 1 @DNIExistente = DNI FROM Person.Persona WHERE Id_Persona <> @IdPersona;

EXEC Person.Modificar_Persona
	@Id_Persona = @IdPersona,
	@DNI = @DNIExistente; -- DNI duplicado (debe fallar)

-- Borrar persona creada
EXEC Person.Borrar_Persona @Id_Persona = @IdPersona;

-- Verificar eliminación
SELECT * FROM Person.Persona


------------ Casos Erroneos ----------------

EXEC Person.Agr_Persona --Nombre con Numeros
	@Nombre = 'Elias123',
    @Apellido = 'Mennella',
    @Email = 'Mennella@gmail.com',
    @Fecha_Nacimiento = '2004-12-02',
    @Telefono_Contacto = '1122334455',
    @DNI = '1'

EXEC Person.Agr_Persona --Nombre Vacio
	@Nombre = '',
    @Apellido = 'Mennella',
    @Email = 'Mennella@gmail.com',
    @Fecha_Nacimiento = '2004-12-02',
    @Telefono_Contacto = '1122334455',
    @DNI = '2'

EXEC Person.Agr_Persona --Apellido con Numeros
	@Nombre = 'Elias',
    @Apellido = 'Mennella123',
    @Email = 'Mennella@gmail.com',
    @Fecha_Nacimiento = '2004-12-02',
    @Telefono_Contacto = '1122334455',
    @DNI = '3'

EXEC Person.Agr_Persona --Apellido Vacio
	@Nombre = 'Elias',
    @Apellido = '',
    @Email = 'Mennella@gmail.com',
    @Fecha_Nacimiento = '2004-12-02',
    @Telefono_Contacto = '1122334455',
    @DNI = '4'

EXEC Person.Agr_Persona --Mail Invalido
	@Nombre = 'Elias',
    @Apellido = 'Mennella',
    @Email = 'Mennellagmail.com',
    @Fecha_Nacimiento = '2004-12-02',
    @Telefono_Contacto = '1122334455',
    @DNI = '46357008'

EXEC Person.Agr_Persona --Mail Vacio
	@Nombre = 'Elias',
    @Apellido = 'Mennella',
    @Email = '',
    @Fecha_Nacimiento = '2004-12-02',
    @Telefono_Contacto = '1122334455',
    @DNI = '46357008'

EXEC Person.Agr_Persona --Nacimiento Invalido
	@Nombre = 'Elias',
    @Apellido = 'Mennella',
    @Email = 'Mennella@gmail.com',
    @Fecha_Nacimiento = '1000-12-02',
    @Telefono_Contacto = '1122334455',
    @DNI = '46357008'

EXEC Person.Agr_Persona --Nacimiento Invalido
	@Nombre = 'Elias',
    @Apellido = 'Mennella',
    @Email = 'Mennella@gmail.com',
    @Fecha_Nacimiento = '',
    @Telefono_Contacto = '1122334455',
    @DNI = '46357008'

EXEC Person.Agr_Persona --Nacimiento Invalido
	@Nombre = 'Elias',
    @Apellido = 'Mennella',
    @Email = 'Mennella@gmail.com',
    @Fecha_Nacimiento = '2026-12-02',
    @Telefono_Contacto = '1122334455',
    @DNI = '46357008'

EXEC Person.Agr_Persona --DNI Vacio
	@Nombre = 'Elias',
    @Apellido = 'Mennella',
    @Email = 'Mennella@gmail.com',
    @Fecha_Nacimiento = '2004-12-02',
    @Telefono_Contacto = '1122334455',
    @DNI = ''

---------------------------------------------- Para Tabla Tutor ----------------------------------------------
/* DELETE FROM Person.Tutor
DBCC CHECKIDENT ('Person.Tutor', RESEED, 0); */

-- Alta de tutor
DECLARE @Id_Tutor INT, @IdPersona_Tutor INT;

EXEC @Id_Tutor = Person.Agr_Tutor
    @Nombre = 'Roxana',
    @Apellido = 'Gomez',
    @DNI = '88331122',
    @Email = 'roxana.gomez@mail.com',
    @Fecha_Nacimiento = '1980-08-12',
    @Telefono_Contacto = '1144556677',
    @Parentesco = 'Madre';

-- Obtener el Id_Persona correspondiente a ese tutor
SELECT @IdPersona_Tutor = Id_Persona FROM Person.Tutor WHERE Id_Tutor = @Id_Tutor;

-- Mostrar persona y tutor después del alta
SELECT * FROM Person.Persona WHERE Id_Persona = @IdPersona_Tutor;
SELECT * FROM Person.Tutor WHERE Id_Tutor = @Id_Tutor;

-- Modificar nombre y email (con Modificar_Persona)
EXEC Person.Modificar_Persona
    @Id_Persona = @IdPersona_Tutor,
    @Nombre = 'Roxi',
    @Email = 'roxigomez@mail.com';

-- Modificar parentesco (con Modificar_Tutor)
EXEC Person.Modificar_Tutor
    @Id_Tutor = @Id_Tutor,
    @Parentesco = 'Tía';

-- Ver cambios aplicados
SELECT * FROM Person.Persona WHERE Id_Persona = @IdPersona_Tutor;
SELECT * FROM Person.Tutor WHERE Id_Tutor = @Id_Tutor;

-- Crear socio menor con ese tutor (para probar restricción)
EXEC Person.Agr_Socio
	@NroSocio = 'SN-9999',
	@Nombre = 'Lautaro',
    @Apellido = 'Gomez',
    @DNI = '99887755',
    @Email = 'lautaro.gomez@mail.com',
    @Fecha_Nacimiento = '2015-10-15',
    @Telefono_Contacto = '1166778899',
    @Telefono_Contacto_Emg = '1199887766',
    @Obra_Social = '',
    @Nro_Socio_Obra = '',
    @Id_Tutor = @Id_Tutor;

-- Intentar borrar tutor (debe fallar por tener un menor a cargo)
EXEC Person.Borrar_Tutor @Id_Persona = @IdPersona_Tutor;

-- Borrar al socio para liberar al tutor
DECLARE @IdSocio VARCHAR(20);
SELECT TOP 1 @IdSocio = Id_Socio FROM Person.Socio WHERE Id_Tutor = @Id_Tutor;
EXEC Person.Borrar_Socio @Id_Socio = @IdSocio;

-- Ahora sí: borrar al tutor
EXEC Person.Borrar_Tutor @Id_Persona = @IdPersona_Tutor;

-- Verificar que fue eliminado correctamente
SELECT * FROM Person.Tutor WHERE Id_Tutor = @Id_Tutor;
SELECT * FROM Person.Persona WHERE Id_Persona = @IdPersona_Tutor;


-- CASO ERROR: parentesco inválido (con números)
EXEC Person.Agr_Tutor
	@Nombre = 'Federico',
	@Apellido = 'Del Valle',
	@DNI = '44332211',
	@Email = 'fededelvalle@gmail.com',
	@Fecha_Nacimiento = '2001-06-16',
	@Telefono_Contacto = '1122112255',
	@Parentesco = 'Padre123'


---------------------------------------------- Para Tabla Socios ----------------------------------------------

-- Carga básica de una categoría para menores
INSERT INTO Groups.Categoria (Nombre_Cat, EdadMin, EdadMax, Descr, Costo)
VALUES ('Infantil', 0, 12, 'Niños hasta 12 años', 1000);

-- Otra categoría para adolescentes
INSERT INTO Groups.Categoria (Nombre_Cat, EdadMin, EdadMax, Descr, Costo)
VALUES ('Juvenil', 13, 17, 'Adolescentes', 1200);

-- Otra categoría para adultos
INSERT INTO Groups.Categoria (Nombre_Cat, EdadMin, EdadMax, Descr, Costo)
VALUES ('Adultos', 18, 99, 'Mayores de edad', 1500);


-------------- SOCIO MAYOR SIN TUTOR
-- Alta de socio mayor
DECLARE @IdPersona_Socio INT;

EXEC Person.Agr_Socio
    @NroSocio = 'SN-1234',
	@Nombre = 'Federico',
    @Apellido = 'Del Valle',
    @DNI = '77777777',
    @Email = 'federico.dv@mail.com',
    @Fecha_Nacimiento = '1995-06-16',
    @Telefono_Contacto = '1144556677',
    @Telefono_Contacto_Emg = '1199887766',
    @Obra_Social = '',
    @Nro_Socio_Obra = '',
    @Id_Tutor = NULL;

-- Obtener Id_Persona asociado
SELECT @IdPersona_Socio = Id_Persona FROM Person.Socio WHERE Id_Socio = @IdSocio;

-- Verificar alta
SELECT * FROM Person.Persona WHERE Id_Persona = @IdPersona_Socio;
SELECT * FROM Person.Socio WHERE Id_Socio = @IdSocio;

-- Modificar datos de persona
EXEC Person.Modificar_Persona
    @Id_Persona = @IdPersona_Socio,
    @Nombre = 'Fede',
    @Email = 'fede.dv@mail.com';

-- Modificar datos de socio
EXEC Person.Modificar_Socio
    @Id_Socio = @IdSocio,
    @Obra_Social = 'OSDE',
    @Nro_Socio_Obra = '12345678',
    @Telefono_Contacto_Emg = '1188112211';

-- Verificar cambios
SELECT * FROM Person.Persona WHERE Id_Persona = @IdPersona_Socio;
SELECT * FROM Person.Socio WHERE Id_Socio = @IdSocio;

-- Borrar socio
EXEC Person.Borrar_Socio @Id_Socio = @IdSocio;
SELECT * FROM Person.Socio WHERE Id_Socio = @IdSocio;
SELECT * FROM Person.Persona WHERE Id_Persona = @IdPersona_Socio;

-------------

------------- SOCIO MENOR CON TUTOR

-- Alta del tutor

EXEC @Id_Tutor = Person.Agr_Tutor
    @Nombre = 'Romina',
    @Apellido = 'Salas',
    @DNI = '88664433',
    @Email = 'romina.salas@mail.com',
    @Fecha_Nacimiento = '1982-03-10',
    @Telefono_Contacto = '1144998811',
    @Parentesco = 'Madre';

-- Obtener Id_Persona asociado al tutor
SELECT @IdPersona_Tutor = Id_Persona FROM Person.Tutor WHERE Id_Tutor = @Id_Tutor;

-- Alta del socio menor
DECLARE @Id_SocioMenor VARCHAR(20), @IdPersona_SocioMenor INT;

EXEC Person.Agr_Socio
	@NroSocio = 'SN-6666',
    @Nombre = 'Camila',
    @Apellido = 'Salas',
    @DNI = '77889955',
    @Email = 'camila.salas@mail.com',
    @Fecha_Nacimiento = '2012-11-20',
    @Telefono_Contacto = '1166778899',
    @Telefono_Contacto_Emg = '1199887766',
    @Obra_Social = '',
    @Nro_Socio_Obra = '',
    @Id_Tutor = @Id_Tutor;

-- Obtener Id_Persona
SELECT @IdPersona_SocioMenor = Id_Persona FROM Person.Socio WHERE Id_Socio = @Id_SocioMenor;

-- Modificar datos de persona
EXEC Person.Modificar_Persona
    @Id_Persona = @IdPersona_SocioMenor,
    @Nombre = 'Cami',
    @Email = 'cami.salas@mail.com';

-- Modificar datos de socio menor
EXEC Person.Modificar_Socio
    @Id_Socio = @Id_SocioMenor,
    @Obra_Social = 'Swiss Medical',
    @Nro_Socio_Obra = '447788',
    @Telefono_Contacto_Emg = '1122001199',
    @Id_Tutor = @Id_Tutor;

-- Verificación
SELECT * FROM Person.Persona WHERE Id_Persona = @IdPersona_SocioMenor;
SELECT * FROM Person.Socio WHERE Id_Socio = @Id_SocioMenor;

-- Probar restricción de tutor no borrable
EXEC Person.Borrar_Tutor @Id_Persona = @IdPersona_Tutor; -- debería fallar

-- Borrar socio menor
EXEC Person.Borrar_Socio @Id_Socio = @Id_SocioMenor;

-- Ahora sí: borrar tutor
EXEC Person.Borrar_Tutor @Id_Persona = @IdPersona_Tutor;

-- Verificación final
SELECT * FROM Person.Tutor WHERE Id_Tutor = @Id_Tutor;
SELECT * FROM Person.Persona WHERE Id_Persona = @IdPersona_Tutor;

-------------

-- CASO ERROR: menor sin tutor
EXEC Person.Agr_Socio
	@NroSocio = 'SN-8888',
	@Nombre = 'Tomas',
	@Apellido = 'Garcia',
	@Email = 'tomas.garcia@gmail.com',
	@Fecha_Nacimiento = '2014-05-15',
	@Telefono_Contacto = '1155667788',
	@DNI = '50223346',
	@Telefono_Contacto_Emg = '1144556677',
	@Obra_Social = 'OSDE',
	@Nro_Socio_Obra = '998877',
	@Id_Tutor = NULL

-- CASO ERROR: socio con obra social pero sin número válido
EXEC Person.Agr_Socio
	@NroSocio = 'SN-7777',
	@Nombre = 'Lucia',
	@Apellido = 'Fernandez',
	@Email = 'lucia.fernandez@gmail.com',
	@Fecha_Nacimiento = '2005-07-15',
	@Telefono_Contacto = '1166778899',
	@DNI = '50223347',
	@Telefono_Contacto_Emg = '1177665544',
	@Obra_Social = 'OSDE',
	@Nro_Socio_Obra = '',
	@Id_Tutor = 1


----------------------------------------------------------------------------------------------------------
--------------------------------------------- SCHEMA PAYMENT ---------------------------------------------

-- REFERENCIA DETALLE

-- Agregar Referencia válida
EXEC Payment.Agr_Referencia_Detalle
    @Referencia = 300,
    @Descripcion = 'Patín artístico';

	DECLARE @Id_Detalle INT = SCOPE_IDENTITY()
-- Modificar descripción
EXEC Payment.Modificar_Referencia_Detalle
    @Id_detalle = @Id_Detalle,
    @Descripcion = 'Patinaje artístico';

-- Intento de modificación inválida
EXEC Payment.Modificar_Referencia_Detalle
    @Id_detalle = @Id_Detalle,
    @Descripcion = ''; -- vacía

-- Borrar referencia
EXEC Payment.Borrar_Referencia_Detalle
    @Id_Detalle = @Id_Detalle;

SELECT * FROM Payment.Referencia_Detalle WHERE Referencia = 300;

---------------------------------------------------------------------------

-- FACTURA

-- Agregar factura
EXEC Payment.Agr_Factura
    @Id_Persona = 1,
    @Fecha_Vencimiento = '2025-06-01',
    @Segundo_Vencimiento = '2025-06-15',
    @Total = 3000,
    @Estado_Factura = 'Emitida';

-- Obtener ID
DECLARE @Id_Factura INT = SCOPE_IDENTITY();

-- Modificar factura
EXEC Payment.Modificar_Factura
    @Id_Factura = @Id_Factura,
    @Total = 3500,
    @Estado_Factura = 'Pagada';

-- Borrar factura
EXEC Payment.Borrar_Factura @Id_Factura = @Id_Factura;

SELECT * FROM Payment.Factura WHERE Id_Factura = @Id_Factura;

---------------------------------------------------------------------------

-- DETALLE FACTURA

-- Prerrequisito: crear factura y referencia
DECLARE @FacturaDF INT;
EXEC Payment.Agr_Factura @Id_Persona = 1, @Fecha_Vencimiento = '2025-07-01', @Segundo_Vencimiento = '2025-07-15', @Total = 1000, @Estado_Factura = 'Emitida';
SET @FacturaDF = SCOPE_IDENTITY();
EXEC Payment.Agr_Referencia_Detalle @Referencia = 301, @Descripcion = 'Gimnasia rítmica';


-- Agregar detalle
EXEC Payment.Agr_Detalle_Factura
    @Id_Factura = @FacturaDF,
    @Id_Detalle = 1,
    @Concepto = 'Cuota Julio',
    @Monto = 1000,
    @Descuento_Familiar = 0,
    @Id_Familia = NULL,
    @Descuento_Act = 0,
    @Descuento_Lluvia = 0;

-- Modificar detalle
EXEC Payment.Modificar_Detalle_Factura
    @Id_Factura = @FacturaDF,
    @Id_Detalle = 301,
    @Concepto = 'Cuota Julio Modificada',
    @Monto = 900;

-- Borrar detalle
EXEC Payment.Borrar_Detalle_Factura
    @Id_Factura = @FacturaDF;

SELECT * FROM Payment.Detalle_Factura WHERE Id_Factura = @FacturaDF;
---------------------------------------------------------------------------

-- PAGO

-- Prerrequisito: crear factura
DECLARE @FacturaPago INT;
EXEC Payment.Agr_Factura
    @Id_Persona = 1,
    @Fecha_Vencimiento = '2025-08-01',
    @Segundo_Vencimiento = '2025-08-15',
    @Total = 1500,
    @Estado_Factura = 'Emitida';
SET @FacturaPago = SCOPE_IDENTITY();

-- Agregar pago
EXEC Payment.Agr_Pago
	@Id_Socio = 'SN-9999',
    @Id_Pago = 1,
	@Id_Factura = @FacturaPago,
	@Fecha_Pago = '2025/06/25',
    @Medio_Pago = 'Tarjeta',
    @Monto = 1000,
    @Reembolso = 0,
    @Cantidad_Pago = 1,
    @Pago_Cuenta = 0;

-- Modificar pago
EXEC Payment.Modificar_Pago
    @Id_Pago = 1,
    @Medio_Pago = 'Transferencia',
    @Monto = 1200;

-- Borrar pago
EXEC Payment.Borrar_Pago @Id_Pago = 1;

SELECT * FROM Payment.Pago WHERE Id_Pago = @FacturaPago;

---------------------------------------------------------------------------

-- MOROSIDAD

-- Prerrequisito: factura vencida
DECLARE @FacturaMoro INT;
EXEC Payment.Agr_Factura
    @Id_Persona = 1,
    @Fecha_Vencimiento = '2025-05-01',
    @Segundo_Vencimiento = '2025-05-15',
    @Total = 1000,
    @Estado_Factura = 'Emitida';
SET @FacturaMoro = SCOPE_IDENTITY();

-- Agregar morosidad
EXEC Payment.Agr_Morosidad
    @Id_Factura = @FacturaMoro,
    @Segundo_Vencimiento = '2025-05-30',
    @Recargo = 200,
    @Bloqueado = 1,
    @Fecha_Bloqueo = '2025-06-01';

-- Modificar morosidad
EXEC Payment.Modificar_Morosidad
    @Id_Factura = @FacturaMoro,
    @Recargo = 250,
    @Bloqueado = 0;

-- Borrar morosidad
EXEC Payment.Borrar_Moroso @Id_Factura = @FacturaMoro;

SELECT * FROM Payment.Morosidad WHERE Id_Factura = @FacturaMoro;

---------------------------------------------------------------------------

-- CUENTA

-- Agregar cuenta
EXEC Payment.Agr_Cuenta
    @Id_Persona = 1,
    @SaldoCuenta = 2500;

-- Modificar cuenta
EXEC Payment.Modificar_Cuenta
    @Id_Persona = 1,
    @SaldoCuenta = 3000;

-- Borrar cuenta
EXEC Payment.Borrar_Cuenta @Id_Persona = 1;

SELECT * FROM Payment.Cuenta WHERE Id_Persona = 1;

---------------------------------------------------------------------------

-- TIPO MEDIO

-- Agregar tipo medio
EXEC Payment.Agr_TipoMedio
    @Nombre_Medio = 'Crédito',
    @Datos_Necesarios = 'Número, Vencimiento, CVV';

-- Obtener ID
DECLARE @IdTipoMedio INT = SCOPE_IDENTITY();

-- Modificar tipo medio
EXEC Payment.Modificar_TipoMedio
    @Id_Tipo_Medio = @IdTipoMedio,
    @Nombre_Medio = 'Crédito Modificado',
    @Datos_Necesarios = 'Tarjeta, CVV';

-- Borrar tipo medio
EXEC Payment.Borrar_Tipo_Medio @Id_Tipo = @IdTipoMedio;

SELECT * FROM Payment.TipoMedio WHERE Id_TipoMedio = @IdTipoMedio;

---------------------------------------------------------------------------

-- MEDIO PAGO

-- Agregar medio de pago
EXEC Payment.Agr_Medio_Pago
    @Id_Persona = 1,
    @Id_TipoMedio = 1,
    @Datos_Medio = 'CBU:12345678';

DECLARE @Id_MedioPago INT = SCOPE_IDENTITY()
-- Modificar medio de pago
EXEC Payment.Modificar_Medio_Pago
	@Id_MedioPago = 1,
	@Id_TipoMedio = @Id_MedioPago,
	@Datos_Medio = 'CBU:87654321'

-- Borrar Medio Pago
EXEC Payment.Borrar_Medio
	@Id_Medio = @Id_MedioPago
SELECT * FROM Payment.Medio_Pago WHERE Id_Persona = 1 AND Id_TipoMedio = 1;

----------------------------------------------------------------------------------------------------------
--------------------------------------------- SCHEMA JORNADA ---------------------------------------------
-- Agregar jornada
EXEC Jornada.Agr_Jornada
    @Fecha = '2025-10-01',
    @Lluvia = 1,
    @MM = 12.5;

-- Verificar alta
SELECT * FROM Jornada.Jornada WHERE Fecha = '2025-10-01';

-- Modificar solo MM
EXEC Jornada.Modificar_Jornada
    @Fecha = '2025-10-01',
    @MM = 15.0;

-- Modificar solo lluvia
EXEC Jornada.Modificar_Jornada
    @Fecha = '2025-10-01',
    @Lluvia = 0;

-- Modificación con lluvia inválida
EXEC Jornada.Modificar_Jornada
    @Fecha = '2025-10-01',
    @Lluvia = 2;

-- Modificación con mm negativos
EXEC Jornada.Modificar_Jornada
    @Fecha = '2025-10-01',
    @MM = -1;

-- Modificación de jornada inexistente
EXEC Jornada.Modificar_Jornada
    @Fecha = '2099-01-01',
    @Lluvia = 1;

-- Borrar jornada
EXEC Jornada.Borrar_Jornada @Fecha = '2025-10-01';

-- Verificar borrado
SELECT * FROM Jornada.Jornada WHERE Fecha = '2025-10-01';

