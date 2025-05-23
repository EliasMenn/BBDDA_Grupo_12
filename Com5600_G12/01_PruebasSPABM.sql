
------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico
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

SELECT * FROM Person.Persona

-- Borrar persona --





---------------------------------------------- Para Tabla Tutor ----------------------------------------------
-- CASO CORRECTO: tutor con datos válidos
EXEC Person.Agr_Tutor
	@Nombre = 'Pedro',
	@Apellido = 'Melissari',
	@DNI = '46912033',
	@Email = 'melissaripedro@gmail.com',
	@Fecha_Nacimiento = '2005-07-22',
	@Telefono_Contacto = '3773620337',
	@Parentesco = 'Padre'

-- CASO ERROR: parentesco inválido (con números)
EXEC Person.Agr_Tutor
	@Nombre = 'Federico',
	@Apellido = 'Del Valle',
	@DNI = '44332211',
	@Email = 'fededelvalle@gmail.com',
	@Fecha_Nacimiento = '2001-06-16',
	@Telefono_Contacto = '1122112255',
	@Parentesco = 'Padre123'

-- CASO ERROR: tutor ya existe
EXEC Person.Agr_Tutor
	@Nombre = 'Pedro',
	@Apellido = 'Melissari',
	@DNI = '46912033',
	@Email = 'melissaripedro@gmail.com',
	@Fecha_Nacimiento = '2005-07-22',
	@Telefono_Contacto = '3773620337',
	@Parentesco = 'Padre'

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


-- CASO CORRECTO: menor de edad con tutor válido
EXEC Person.Agr_Socio
	@Nombre = 'Juan',
	@Apellido = 'Medina',
	@Email = 'Medina@CABJ.com',
	@Fecha_Nacimiento = '2011-6-26',
	@Telefono_Contacto = '1122334455',
	@DNI = '46682620',
	@Telefono_Contacto_Emg = '1122334455',
	@Obra_Social ='OSDE',
	@Nro_Socio_Obra = '1',
	@Id_Tutor = '1' -- suponiendo que el tutor ya fue creado

-- CASO CORRECTO: mayor de edad sin tutor
EXEC Person.Agr_Socio
	@Nombre = 'Federico',
	@Apellido = 'Del Valle',
	@Email = 'fededelvalle@gmail.com',
	@Fecha_Nacimiento = '2001-06-16',
	@Telefono_Contacto = '1144556677',
	@DNI = '43935693',
	@Telefono_Contacto_Emg = '1199887766',
	@Obra_Social = 'SWISS MEDICAL',
	@Nro_Socio_Obra = '1',
	@Id_Tutor = NULL

-- CASO ERROR: menor sin tutor
EXEC Person.Agr_Socio
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

------------------------------------------- Para Tabla Factura -------------------------------------------

-- CASO CORRECTO
EXEC Payment.Agr_Factura
    @Id_Persona = 1, -- debe existir en Person.Persona
    @Fecha_Vencimiento = '2025-06-01',
    @Segundo_Vencimiento = '2025-06-15',
    @Total = 1500,
    @Estado_Factura = 'Emitida';

-- CASO ERROR: Persona inexistente
EXEC Payment.Agr_Factura
    @Id_Persona = 999,
    @Fecha_Vencimiento = '2025-06-01',
    @Segundo_Vencimiento = '2025-06-15',
    @Total = 1500,
    @Estado_Factura = 'Emitida';

-- CASO ERROR: Total inválido
EXEC Payment.Agr_Factura
    @Id_Persona = 1,
    @Fecha_Vencimiento = '2025-06-01',
    @Segundo_Vencimiento = '2025-06-15',
    @Total = -50,
    @Estado_Factura = 'Emitida';

------------------------------------------- Para Tabla Detalle Factura -------------------------------------------

-- Carga de una familia ficticia
EXEC Groups.Agr_Grupo_Familiar
	@Nombre_Familia = 'Familia López',
	@Id_Socio = '1'

-- Otra familia opcional
INSERT INTO Groups.Grupo_Familiar (Nombre_Familia)
VALUES ('Familia Melissari');

-- CASO CORRECTO
EXEC Payment.Agr_Detalle_Factura
    @Id_Factura = 1,
    @Id_Detalle = 1, -- debe existir en Referencia_Detalle
    @Concepto = 'Cuota de abril',
    @Monto = 1200,
    @Descuento_Familiar = 10,
    @Id_Familia = 1,
    @Descuento_Act = 5,
    @Descuento_Lluvia = 0;

-- CASO ERROR: Factura no existe
EXEC Payment.Agr_Detalle_Factura
    @Id_Factura = 999,
	@Id_Detalle = 1, 
    @Concepto = 'Cuota abril',
    @Monto = 1200,
    @Descuento_Familiar = 10,
    @Id_Familia = 1,
    @Descuento_Act = 5,
    @Descuento_Lluvia = 0;

-- CASO ERROR: Monto negativo
EXEC Payment.Agr_Detalle_Factura
    @Id_Factura = 1,
	@Id_Detalle = 1, 
    @Concepto = 'Cuota abril',
    @Monto = -500,
    @Descuento_Familiar = 10,
    @Id_Familia = 1,
    @Descuento_Act = 5,
    @Descuento_Lluvia = 0;

----------------------------------- Para Tabla Referencia_Detalle -------------------------------------

-- CASO CORRECTO
EXEC Payment.Agr_Referencia_Detalle
    @Referencia = 200,
    @Descripcion = 'Fútbol infantil';

-- CASO ERROR: Descripción vacía
EXEC Payment.Agr_Referencia_Detalle
    @Referencia = 201,
    @Descripcion = '';

-- CASO ERROR: Tipo inválido
EXEC Payment.Agr_Referencia_Detalle
    @Referencia = 502,
    @Descripcion = 'Yoga adultos';

------------------------------------------- Para Tabla Pago -------------------------------------------

-- CASO CORRECTO
EXEC Payment.Agr_Pago
    @Id_Factura = 1,
    @Medio_Pago = 'Tarjeta',
    @Monto = 1000,
    @Reembolso = 0,
    @Cantidad_Pago = 1,
    @Pago_Cuenta = 0;

-- CASO ERROR: Medio de pago vacío
EXEC Payment.Agr_Pago
    @Id_Factura = 1,
    @Medio_Pago = '',
    @Monto = 1000,
    @Reembolso = 0,
    @Cantidad_Pago = 1,
    @Pago_Cuenta = 0;

-- CASO ERROR: Monto cero
EXEC Payment.Agr_Pago
    @Id_Factura = 1,
    @Medio_Pago = 'Tarjeta',
    @Monto = 0,
    @Reembolso = 0,
    @Cantidad_Pago = 1,
    @Pago_Cuenta = 0;

------------------------------------------- Para Tabla Morosidad -------------------------------------------

-- CASO CORRECTO
EXEC Payment.Agr_Morosidad
    @Id_Factura = 1,
    @Segundo_Vencimiento = '2025-06-30',
    @Recargo = 200,
    @Bloqueado = 1,
    @Fecha_Bloqueo = '2025-07-01';

-- CASO ERROR: Factura inexistente
EXEC Payment.Agr_Morosidad
    @Id_Factura = 999,
    @Segundo_Vencimiento = '2025-06-30',
    @Recargo = 200,
    @Bloqueado = 1,
    @Fecha_Bloqueo = '2025-07-01';

-- CASO ERROR: Recargo negativo
EXEC Payment.Agr_Morosidad
    @Id_Factura = 1,
    @Segundo_Vencimiento = '2025-06-30',
    @Recargo = -100,
    @Bloqueado = 1,
    @Fecha_Bloqueo = '2025-07-01';

------------------------------------------- Para Tabla Cuenta -------------------------------------------
-- CASO CORRECTO
EXEC Payment.Agr_Cuenta
    @Id_Persona = 1,
    @SaldoCuenta = 2000;

-- CASO ERROR: Ya existe la cuenta
EXEC Payment.Agr_Cuenta
    @Id_Persona = 1,
    @SaldoCuenta = 3000;

-- CASO ERROR: Saldo negativo
EXEC Payment.Agr_Cuenta
    @Id_Persona = 2,
    @SaldoCuenta = -100;


------------------------------------------- Para Tabla Tipo Medio -------------------------------------------
-- CASO CORRECTO
EXEC Payment.Agr_TipoMedio
    @Nombre_Medio = 'Débito automático',
    @Datos_Necesarios = 'CBU, Banco, Titular';

-- CASO ERROR: Nombre muy largo
EXEC Payment.Agr_TipoMedio
    @Nombre_Medio = 'EsteNombreEsMuyLargoParaElCampo',
    @Datos_Necesarios = 'Tarjeta, Vto, CVV';

------------------------------------------- Para Tabla Medio Pago -------------------------------------------
-- CASO CORRECTO
EXEC Payment.Agr_Medio_Pago
    @Id_Persona = 1,
    @Id_TipoMedio = 1,
    @Datos_Medio = 'CBU:12345678';

-- CASO ERROR: Socio inexistente
EXEC Payment.Agr_Medio_Pago
    @Id_Persona = 999,
    @Id_TipoMedio = 1,
    @Datos_Medio = 'CBU:12345678';

-- CASO ERROR: TipoMedio inexistente
EXEC Payment.Agr_Medio_Pago
    @Id_Persona = 1,
    @Id_TipoMedio = 999,
    @Datos_Medio = 'CBU:12345678';

------------------------------------------- Para Tabla Jornada -------------------------------------------


CREATE OR ALTER PROCEDURE Jornada.Agr_Jornada
    @Fecha DATE,
    @Lluvia INT,
    @MM DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        -- Validar que la fecha no esté duplicada
        IF EXISTS (SELECT 1 FROM Jornada.Jornada WHERE Fecha = @Fecha)
        BEGIN
            PRINT('Ya existe una jornada con esa fecha')
            RAISERROR('.', 16, 1)
        END

        -- Validar rango de lluvia (0 o 1)
        IF @Lluvia NOT IN (0, 1)
        BEGIN
            PRINT('El valor de lluvia debe ser 0 (no llovió) o 1 (sí llovió)')
            RAISERROR('.', 16, 1)
        END

        -- Validar MM
        IF @MM < 0
        BEGIN
            PRINT('Los milímetros de lluvia no pueden ser negativos')
            RAISERROR('.', 16, 1)
        END

        -- Insertar jornada
        INSERT INTO Jornada.Jornada (Fecha, Lluvia, MM)
        VALUES (@Fecha, @Lluvia, @MM)
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Error al registrar la jornada', 16, 1)
        END
    END CATCH
END
GO

