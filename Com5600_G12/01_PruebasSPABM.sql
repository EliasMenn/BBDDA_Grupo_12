
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

--Agregar Personas --
--Caso Correcto -- 


EXEC Person.Agr_Persona
	@Nombre = 'Juan',
    @Apellido = 'Medina',
    @Email = 'Medina@CABJ.com',
    @Fecha_Nacimiento = '2011-6-26',
    @Telefono_Contacto = '1122334455',
	@DNI = '46682620'

SELECT * 
FROM Person.Persona

--Casos Erroneos --

EXEC Person.Agr_Persona --DNI Duplicado
	@Nombre = 'Juan',
	@Apellido = 'Medina',
    @Email = 'Medina@CABJ.com',
    @Fecha_Nacimiento = '2011-6-11',
    @Telefono_Contacto = '1122334455',
    @DNI = '46682620'

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
-- CASO CORRECTO: menor de edad con tutor válido
EXEC Person.Agr_Socio
	@Nombre = 'Juan',
    @Apellido = 'Medina',
    @Email = 'Medina@CABJ.com',
    @Fecha_Nacimiento = '2011-6-26',
    @Telefono_Contacto = '1122334455',
	@DNI = '46682620',
	@Telefono_Contacto_Emg = '1122334455',
	@Obra_Social ='N/A',
	@Nro_Socio_Obra = 'N/A',
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
	@Obra_Social = 'N/A',
	@Nro_Socio_Obra = '',
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
