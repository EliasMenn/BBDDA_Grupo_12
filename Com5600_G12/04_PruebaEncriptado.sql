--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico 43316258
--Medina, Juan 46682620
--Mennella, Elias Damian 46357008
----------------------------------------------------------------

USE master

USE Com5600_G12
GO

--PARA CASOS DE ENCRIPTADOS 
EXEC Person.Agr_Persona
	@Nombre = 'Juan',
	@Apellido = 'Medina',
	@DNI = '1234567890',
	@Email = 'JuanMedina10@Gmail.com',
	@Fecha_Nacimiento = '10/10/2003',
	@Telefono_Contacto = '123456789'

EXEC Groups.Agr_Categoria
	@Nombre_Cat = 'Cat Generica',
	@Edad_Min = 5,
	@Edad_Max = 90,
	@Descr = 'Una Categoria Generica',
	@Costo = 1000

	EXEC Person.Agr_Socio
	@NroSocio = 'SN-1234',
	@Nombre = 'Juan',
	@Apellido = 'Medina',
	@DNI = '1234567890',
	@Email = 'JuanMedina10@Gmail.com',
	@Fecha_Nacimiento = '10/10/2003',
	@Telefono_Contacto = '123456789',
	@Telefono_Contacto_Emg= '11111111',
	@Obra_Social = 'Medicus',
	@Nro_Socio_Obra = '1234',
	@Id_Tutor = NULL

EXEC Person.Agr_Usuario
	@Id_Rol= 2,
	@Id_Persona= 1,
	@Nombre_Usuario='FyJ123%',
	@Contrasenia = 'lascabrassolindas2131'


EXEC Person.Encriptar_Empleado 
	@id_Persona = 1


select * from Person.Persona p
JOIN Person.Socio s ON s.Id_Persona = p.Id_Persona
JOIN Person.Usuario u ON u.Id_Persona = p.Id_Persona

EXEC Person.Desencriptar_Empleado 
	@id_Persona = 1

select * from Person.Persona p
JOIN Person.Socio s ON s.Id_Persona = p.Id_Persona
JOIN Person.Usuario u ON u.Id_Persona = p.Id_Persona
