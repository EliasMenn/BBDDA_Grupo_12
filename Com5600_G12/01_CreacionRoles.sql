------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico 43316258
--Medina, Juan 46682620
--Mennella, Elias Damian 46357008
----------------------------------------------------------------
USE COM5600_G12
GO

--IMPLEMNTACION DEPENDIEDO POR TESORERIAS, ROLES Y SOCIOS
-- Eliminar roles existentes si es necesario
-- Creación de los 3 roles principales
CREATE ROLE Rol_Tesoreria;
CREATE ROLE Rol_Socios;
CREATE ROLE Rol_Autoridades;


-- Consulta para verificar los roles creados
SELECT name AS NombreRol, type_desc AS Tipo
FROM sys.database_principals
WHERE type = 'R' AND name LIKE 'Rol_%'
ORDER BY name;

-------------------------PARA ROL TESORERIA-------------------------
-- Permisos financieros completos
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Payment TO Rol_Tesoreria;
GRANT SELECT ON Person.Persona TO Rol_Tesoreria;
GRANT SELECT ON Person.Socio TO Rol_Tesoreria;

-- Restricciones importantes
DENY DELETE ON SCHEMA::Payment TO Rol_Tesoreria;
DENY ALTER ON SCHEMA::Payment TO Rol_Tesoreria;
DENY SELECT ON Payment.Cuenta(SaldoCuenta) TO Rol_Tesoreria;
DENY SELECT ON Payment.Pago(Monto) TO Rol_Tesoreria;

-------------------------PARA ROL SOCIOS-------------------------
-- Permisos básicos para socios
GRANT SELECT ON Person.Socio TO Rol_Socios;
GRANT SELECT ON Payment.Factura TO Rol_Socios;
GRANT SELECT ON Payment.Medio_Pago TO Rol_Socios;
GRANT SELECT ON Payment.Cuenta TO Rol_Socios;
GRANT INSERT ON Payment.Pago TO Rol_Socios;

-- Restricciones
DENY SELECT ON Person.Persona TO Rol_Socios;
DENY SELECT ON Payment.Morosidad TO Rol_Socios;
DENY SELECT ON SCHEMA::Groups TO Rol_Socios;

-------------------------PARA ROL AUTORIDADES-------------------------
-- Permisos amplios de administración
GRANT CONTROL ON DATABASE::COM5600_G12 TO Rol_Autoridades;

-- Permisos específicos adicionales
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Person TO Rol_Autoridades;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Payment TO Rol_Autoridades;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Activity TO Rol_Autoridades;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Groups TO Rol_Autoridades;

------PARA VER PERMISOS ASIGNADOS----
SELECT 
    r.name AS Rol,
    p.permission_name AS Permiso,
    p.state_desc AS Estado,
    SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(p.major_id) AS Objeto
FROM sys.database_permissions p
JOIN sys.database_principals r ON p.grantee_principal_id = r.principal_id
LEFT JOIN sys.objects o ON p.major_id = o.object_id
WHERE r.type = 'R' AND r.name LIKE 'Rol_%'
ORDER BY r.name, p.permission_name;

----------------------------------------------------------------------------------
-------------CREACION DE USUARIOS-------------------------------------------------

CREATE USER JuanUser FOR LOGIN JuanUser;
CREATE USER PedroUser FOR LOGIN PedroUser;
CREATE USER FedeUser FOR LOGIN FedeUser;

------------ASIGNAR ROLES A USUARIOS------------
ALTER ROLE Rol_Tesoreria ADD MEMBER JuanUser;
ALTER ROLE Rol_Socios ADD MEMBER PedroUser;
ALTER ROLE Rol_Autoridades ADD MEMBER FedeUser;

------En Caso de Borrar los roles--------------
/*
DROP ROLE Rol_Tesoreria;
DROP ROLE Rol_Socios;
DROP ROLE Rol_Autoridades;
*/

-- Para borrar usuarios primero quitar roles, no olvidarse ojo 
/*
ALTER ROLE Rol_Tesoreria DROP MEMBER JuanUser;
ALTER ROLE Rol_Socios DROP MEMBER PedroUser;
ALTER ROLE Rol_Autoridades DROP MEMBER AdminUser;

DROP USER JuanUser;
DROP USER PedroUser;
DROP USER FedeUser;
*/