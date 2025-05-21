
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

-- Para Tabla Socios --
-- (Se ignoran los casos de error relacionados a datos presentes en Persona) --

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
	@Id_Tutor = '1'
