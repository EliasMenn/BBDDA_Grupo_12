--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico 43316258
--Medina, Juan 46682620
--Mennella, Elias Damian 46357008
----------------------------------------------------------------

-- Pruebas de Stored Procedures para la generacion de informes --

USE master

USE Com5600_G12
GO

-- Empezamos por generar las personas
EXEC Person.Agr_Persona
	@Nombre = 'Juan',
	@Apellido = 'Medina',
	@DNI = '1234567890',
	@Email = 'JuanMedina10@Gmail.com',
	@Fecha_Nacimiento = '10/10/2003',
	@Telefono_Contacto = '123456789'

EXEC Person.Agr_Persona
	@Nombre = 'Pedro',
	@Apellido = 'Melissari',
	@DNI = '0234567890',
	@Email = 'PedroMel@Gmail.com',
	@Fecha_Nacimiento = '9/10/2003',
	@Telefono_Contacto = '123456789'

EXEC Person.Agr_Persona
	@Nombre = 'Federico',
	@Apellido = 'Del Valle',
	@DNI = '0034567890',
	@Email = 'FedeDelValle10@Gmail.com',
	@Fecha_Nacimiento = '10/10/2003',
	@Telefono_Contacto = '123456789'

EXEC Person.Agr_Persona
	@Nombre = 'Elias',
	@Apellido = 'Mennella',
	@DNI = '0004567890',
	@Email = 'EliasMennella@Gmail.com',
	@Fecha_Nacimiento = '9/10/2003',
	@Telefono_Contacto = '123456789'

SELECT * FROM Person.Persona

-- Generamos las facturas para las personas

EXEC Payment.Agr_Factura
	@Id_Persona = 1,
	@Fecha_Vencimiento = '3/6/25',
	@Segundo_Vencimiento = '10/6/25',
	@Total = 100,
	@Estado_Factura = 'Vencida'

EXEC Payment.Agr_Factura
	@Id_Persona = 1,
	@Fecha_Vencimiento = '3/6/25',
	@Segundo_Vencimiento = '10/6/25',
	@Total = 1000,
	@Estado_Factura = 'Vencida'

EXEC Payment.Agr_Factura
	@Id_Persona = 1,
	@Fecha_Vencimiento = '3/6/25',
	@Segundo_Vencimiento = '10/6/25',
	@Total = 10,
	@Estado_Factura = 'Vencida'

EXEC Payment.Agr_Factura
	@Id_Persona = 2,
	@Fecha_Vencimiento = '3/6/25',
	@Segundo_Vencimiento = '10/6/25',
	@Total = 100,
	@Estado_Factura = 'Paga'

EXEC Payment.Agr_Factura
	@Id_Persona = 2,
	@Fecha_Vencimiento = '3/6/25',
	@Segundo_Vencimiento = '10/6/25',
	@Total = 1000,
	@Estado_Factura = 'Vencida'

EXEC Payment.Agr_Factura
	@Id_Persona = 2,
	@Fecha_Vencimiento = '3/6/25',
	@Segundo_Vencimiento = '10/6/25',
	@Total = 10,
	@Estado_Factura = 'Vencida'

EXEC Payment.Agr_Factura
	@Id_Persona = 3,
	@Fecha_Vencimiento = '3/6/25',
	@Segundo_Vencimiento = '10/6/25',
	@Total = 100,
	@Estado_Factura = 'Paga'

EXEC Payment.Agr_Factura
	@Id_Persona = 3,
	@Fecha_Vencimiento = '3/6/25',
	@Segundo_Vencimiento = '10/6/25',
	@Total = 1000,
	@Estado_Factura = 'Paga'

EXEC Payment.Agr_Factura
	@Id_Persona = 3,
	@Fecha_Vencimiento = '3/6/25',
	@Segundo_Vencimiento = '10/6/25',
	@Total = 10,
	@Estado_Factura = 'Paga'

EXEC Payment.Agr_Factura
	@Id_Persona = 4,
	@Fecha_Vencimiento = '3/6/25',
	@Segundo_Vencimiento = '10/6/25',
	@Total = 100,
	@Estado_Factura = 'Vencida'

EXEC Payment.Agr_Factura
	@Id_Persona = 4,
	@Fecha_Vencimiento = '3/6/25',
	@Segundo_Vencimiento = '10/6/25',
	@Total = 1000,
	@Estado_Factura = 'Vencida'

EXEC Payment.Agr_Factura
	@Id_Persona = 4,
	@Fecha_Vencimiento = '3/6/25',
	@Segundo_Vencimiento = '10/6/25',
	@Total = 10,
	@Estado_Factura = 'Vencida'

SELECT * FROM Payment.Factura

-- Generamos la seccion de morosidad para las facturas (aquellas facturas que esten pagas figuraran como 0 el bloqueo, la fecha es un referente para cuando ocurriria si no se paga)

EXEC Payment.Agr_Morosidad
	@Id_Factura = 1,
	@Segundo_Vencimiento = '2025-06-17',
	@Recargo = 100.25,
	@Bloqueado = 1,
	@Fecha_Bloqueo = '2025-06-17'

EXEC Payment.Agr_Morosidad
	@Id_Factura = 2,
	@Segundo_Vencimiento = '2025-06-17',
	@Recargo = 100.25,
	@Bloqueado = 1,
	@Fecha_Bloqueo = '2025-06-17'

EXEC Payment.Agr_Morosidad
	@Id_Factura = 3,
	@Segundo_Vencimiento = '2025-06-17',
	@Recargo = 100.25,
	@Bloqueado = 1,
	@Fecha_Bloqueo = '2025-06-17'

EXEC Payment.Agr_Morosidad
	@Id_Factura = 4,
	@Segundo_Vencimiento = '2025-06-17',
	@Recargo = 100.25,
	@Bloqueado = 0,
	@Fecha_Bloqueo = '2025-06-17'

EXEC Payment.Agr_Morosidad
	@Id_Factura = 5,
	@Segundo_Vencimiento = '2025-06-17',
	@Recargo = 100.25,
	@Bloqueado = 1,
	@Fecha_Bloqueo = '2025-06-17'

EXEC Payment.Agr_Morosidad
	@Id_Factura = 6,
	@Segundo_Vencimiento = '2025-06-17',
	@Recargo = 100.25,
	@Bloqueado = 1,
	@Fecha_Bloqueo = '2025-06-17'

EXEC Payment.Agr_Morosidad
	@Id_Factura = 7,
	@Segundo_Vencimiento = '2025-06-17',
	@Recargo = 100.25,
	@Bloqueado = 0,
	@Fecha_Bloqueo = '2025-06-17'

EXEC Payment.Agr_Morosidad
	@Id_Factura = 8,
	@Segundo_Vencimiento = '2025-06-17',
	@Recargo = 100.25,
	@Bloqueado = 0,
	@Fecha_Bloqueo = '2025-06-17'

EXEC Payment.Agr_Morosidad
	@Id_Factura = 9,
	@Segundo_Vencimiento = '2025-06-17',
	@Recargo = 100.25,
	@Bloqueado = 0,
	@Fecha_Bloqueo = '2025-06-17'

	EXEC Payment.Agr_Morosidad
	@Id_Factura = 10,
	@Segundo_Vencimiento = '2025-06-17',
	@Recargo = 100.25,
	@Bloqueado = 1,
	@Fecha_Bloqueo = '2025-06-17'

EXEC Payment.Agr_Morosidad
	@Id_Factura = 11,
	@Segundo_Vencimiento = '2025-06-17',
	@Recargo = 100.25,
	@Bloqueado = 1,
	@Fecha_Bloqueo = '2025-06-17'

EXEC Payment.Agr_Morosidad
	@Id_Factura = 12,
	@Segundo_Vencimiento = '2025-06-17',
	@Recargo = 100.25,
	@Bloqueado = 1,
	@Fecha_Bloqueo = '2025-06-17'

SELECT * FROM Payment.Morosidad

-- Generamos el reporte de los morosos -- 

EXEC Reporte.Morosos
	@FechaDesde = '2025-6-1',
	@FechaHasta = '2025-6-28'

/*Se espera como salida, las personas 1, 2 y 4 ocupando la persona 1 el Ranking 1 en conjunto a la persona 4
por ultimo en el puesto 2 la persona 2, deberia haber 3 entradas para persona 1 y 4, la persona 2 debe tener solo 2*/

-- Generamos actividades --

EXEC Activity.Agr_Actividad
	@Nombre_Actividad = 'Natacion',
	@Desc_Act = 'Pileta interior',
	@Costo = 225.5


EXEC Activity.Agr_Actividad
	@Nombre_Actividad = 'Basquet',
	@Desc_Act = 'Clases de basquet',
	@Costo = 300

EXEC Activity.Agr_Actividad
	@Nombre_Actividad = 'TaekWondo',
	@Desc_Act = 'Clases de TaekWondo',
	@Costo = 300

SELECT * FROM Activity.Actividad
SELECT * FROM Payment.Referencia_Detalle

-- Generamos los detalles de la factura

EXEC Payment.Agr_Detalle_Factura
	@Id_Factura = 4,
	@Id_Detalle = 1,
	@Concepto = ' Cuota',
	@Monto = 3000,
	@Descuento_Familiar = 0,
	@Id_Familia = NULL,
	@Descuento_Act = 0,
	@Descuento_Lluvia = 0

EXEC Payment.Agr_Detalle_Factura
	@Id_Factura = 7,
	@Id_Detalle = 1,
	@Concepto = 'Cuota',
	@Monto = 300,
	@Descuento_Familiar = 0,
	@Id_Familia = NULL,
	@Descuento_Act = 0,
	@Descuento_Lluvia = 0

EXEC Payment.Agr_Detalle_Factura
	@Id_Factura = 8,
	@Id_Detalle = 2,
	@Concepto = 'Cuota',
	@Monto = 300,
	@Descuento_Familiar = 0,
	@Id_Familia = NULL,
	@Descuento_Act = 0,
	@Descuento_Lluvia = 0

EXEC Payment.Agr_Detalle_Factura
	@Id_Factura = 9,
	@Id_Detalle = 3,
	@Concepto = 'Cuota',
	@Monto = 300,
	@Descuento_Familiar = 0,
	@Id_Familia = NULL,
	@Descuento_Act = 0,
	@Descuento_Lluvia = 0

SELECT * FROM Payment.Detalle_Factura

-- Generamos el reporte de ganancias

EXEC Reporte.Ingresos

-- Agregamos Categorias

EXEC Groups.Agr_Categoria
	@Nombre_Cat = 'Cat Generica',
	@Edad_Min = 5,
	@Edad_Max = 90,
	@Descr = 'Una Categoria Generica',
	@Costo = 1000

EXEC Groups.Agr_Categoria
	@Nombre_Cat = 'Mas De Cien',
	@Edad_Min = 100,
	@Edad_Max = 999,
	@Descr = 'Una Categoria Generica',
	@Costo = 1000

SELECT * FROM Groups.Categoria

--Agregamos Socios

EXEC Person.Agr_Socio
	@NroSocio = 'SN-1234',
	@Nombre = 'Juan',
	@Apellido = 'Medina',
	@DNI = '1234567890',
	@Email = 'JuanMedina10@Gmail.com',
	@Fecha_Nacimiento = '10/10/2003',
	@Telefono_Contacto = '123456789',
	@Telefono_Contacto_Emg = '11111111',
	@Obra_Social = 'Medicus',
	@Nro_Socio_Obra = '1234',
	@Id_Tutor = NULL

EXEC Person.Agr_Socio
	@NroSocio = 'SN-1235',
	@Nombre = 'Pedro',
	@Apellido = 'Melissari',
	@DNI = '0234567890',
	@Email = 'JuanMedina10@Gmail.com',
	@Fecha_Nacimiento = '10/10/2003',
	@Telefono_Contacto = '123456789',
	@Telefono_Contacto_Emg = '11111111',
	@Obra_Social = 'Medicus',
	@Nro_Socio_Obra = '1234',
	@Id_Tutor = NULL

EXEC Person.Agr_Socio
	@NroSocio = 'SN-1236',
	@Nombre = 'Jose',
	@Apellido = 'Escalada',
	@DNI = '000000001',
	@Email = 'JuanMedina10@Gmail.com',
	@Fecha_Nacimiento = '10/10/1903',
	@Telefono_Contacto = '123456789',
	@Telefono_Contacto_Emg = '11111111',
	@Obra_Social = 'Medicus',
	@Nro_Socio_Obra = '1234',
	@Id_Tutor = NULL

SELECT * FROM Person.Socio

-- Agregamos la asistencia de los socios

EXEC Activity.Agr_Asistencia
	@Id_Socio = 'SN-1234',
	@Actividad = 'Natacion',
	@Fecha = '2025/06/17',
	@Asistencia = 'A',
	@Profesor = 'Nacho'

EXEC Activity.Agr_Asistencia
	@Id_Socio = 'SN-1235',
	@Actividad = 'Natacion',
	@Fecha = '2025/06/17',
	@Asistencia = 'A',
	@Profesor = 'Nacho'

EXEC Activity.Agr_Asistencia
	@Id_Socio = 'SN-1236',
	@Actividad = 'Natacion',
	@Fecha = '2025/06/17',
	@Asistencia = 'A',
	@Profesor = 'Nacho'

EXEC Activity.Agr_Asistencia
	@Id_Socio = 'SN-1236',
	@Actividad = 'Basquet',
	@Fecha = '2025/06/17',
	@Asistencia = 'A',
	@Profesor = 'Nacho'

SELECT * FROM Activity.Asistencia

-- Generamos el informe de inasistencias --

EXEC Reporte.InasistenciasAct
EXEC Reporte.Inasistencias
