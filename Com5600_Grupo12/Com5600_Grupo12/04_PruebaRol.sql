------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico 43316258
--Medina, Juan 46682620
--Mennella, Elias Damian 46357008
----------------------------------------------------------------
/*
Se creara un login con un rol diferente a tesoreria e intentaremos ejecutar SP relacionados a tesoreria
*/

CREATE LOGIN LoginPrueba WITH PASSWORD = 'ContraseñaPrueba'


USE master

USE Com5600_G12
GO

CREATE USER UsuarioPrueba FOR LOGIN LoginPrueba

ALTER ROLE Administrativo_Morosidad ADD MEMBER UsuarioPrueba

SELECT
    r.name AS Rol,
    m.name AS Usuario
FROM
    sys.database_role_members drm
    JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals m ON drm.member_principal_id = m.principal_id
ORDER BY
    r.name, m.name;

/* 
Tras Asegurar que el user fuese creado y el rol asignado de manera satisfactoria, testeamos los permisos
utilizamos el EXECUTE AS pero se puede cerrar la sesion de db_owner para probar
*/


--Creamos la persona y la factura antes de entrar al modo prueba de usuario
DBCC CHECKIDENT ('Person.Persona', RESEED, 0);

EXEC Person.Agr_Persona
	@Nombre = 'Pedro',
	@Apellido = 'Melissari',
	@DNI = '46912033',
	@Email = 'pedromelissari@mail.com',
	@Fecha_Nacimiento = '2005-07-22',
	@Telefono_Contacto = '1111222233';
SELECT * FROM Person.Persona

DBCC CHECKIDENT ('Payment.Factura', RESEED, 0);

EXEC Payment.Agr_Factura
	@Id_Persona = 1,
	@Fecha_Vencimiento = '2025-10-3',
	@Segundo_Vencimiento = '2025-10-10',
	@Total = 100.00,
	@Estado_Factura = 'Pagada'
SELECT * FROM Payment.Factura

EXECUTE AS USER = 'UsuarioPrueba'

SELECT * FROM Person.Socio 
-- No se tiene permiso para ver la tabla de socios

DECLARE @IdPersona INT;
EXEC @IdPersona = Person.Agr_Persona
	@Nombre = 'Pedro',
	@Apellido = 'Melissari',
	@DNI = '46912033',
	@Email = 'pedromelissari@mail.com',
	@Fecha_Nacimiento = '2005-07-22',
	@Telefono_Contacto = '1111222233';
-- No se puede insertar personas con este rol

EXEC Jornada.Modificar_Jornada
    @Fecha = '2099-01-01',
    @Lluvia = 1;
-- No podemos modificar una jornada

DROP DATABASE COM5600_G12
-- No podemos borrar la BD

-- Ahora las cosas que podemos hacer

--Agregar un moroso
EXEC Payment.Agr_Morosidad
	 @Id_Factura = 1,
	 @Segundo_Vencimiento = '2025-10-10',
	 @Recargo = 100.00,
	 @Bloqueado = 0,
	 @Fecha_Bloqueo = '2025-10-17'
SELECT * FROM Payment.Morosidad

--Modificar un moroso
EXEC Payment.Modificar_Morosidad
	 @Id_Factura = 1,
	 @Segundo_Vencimiento = '2025-10-10',
	 @Recargo = 500.00,
	 @Bloqueado = 1,
	 @Fecha_Bloqueo = '2025-10-17'
SELECT * FROM Payment.Morosidad

--Borrar un moroso
EXEC Payment.Borrar_Moroso
	@Id_Factura = 1
SELECT * FROM Payment.Morosidad

REVERT

--Terminamos el testing y limpiamos todo

EXEC Payment.Borrar_Factura
	@Id_Factura = 1

EXEC Person.Borrar_Persona
	@Id_Persona = 1

DROP USER UsuarioPrueba
DROP LOGIN LoginPrueba