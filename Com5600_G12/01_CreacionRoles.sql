------------------------------------------------------------------
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico 43316258
--Medina, Juan 46682620
--Mennella, Elias Damian 46357008
----------------------------------------------------------------
USE [COM5600_G12];  -- Cambia al contexto de tu base de datos
GO

-- Creación de roles de base de datos
CREATE ROLE Rol_Jefe_Tesoreria;
CREATE ROLE Rol_Administrativo_Cobranzas;
CREATE ROLE Rol_Administrativo_Morosidad;
CREATE ROLE Rol_Administrativo_Facturacion;
CREATE ROLE Rol_Administrativo_Socio;
CREATE ROLE Rol_Socio_Web;
CREATE ROLE Rol_Presidente;
CREATE ROLE Rol_Vicepresidente;
CREATE ROLE Rol_Secretario;
CREATE ROLE Rol_Vocales;
GO

-- Consulta para verificar los roles creados
SELECT name AS NombreRol, type_desc AS Tipo
FROM sys.database_principals
WHERE type = 'R' AND name LIKE 'Rol_%'
ORDER BY name;

-------------------------PARA ROL DE TESORERIA-------------------------
-- Permisos sobre esquema Payment (operaciones financieras completas)
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Payment TO Rol_Jefe_Tesoreria;

-- Permisos sobre datos personales (solo lectura)
GRANT SELECT ON SCHEMA::Person TO Rol_Jefe_Tesoreria;

-- Permisos sobre grupos (solo lectura)
GRANT SELECT ON SCHEMA::Groups TO Rol_Jefe_Tesoreria;

-- Restricciones importantes
DENY DELETE ON SCHEMA::Payment TO Rol_Jefe_Tesoreria; -- Evitar borrado físico
DENY ALTER ON SCHEMA::Payment TO Rol_Jefe_Tesoreria; -- No puede modificar estructura

-- Restricción específica para columnas sensibles
DENY SELECT ON Payment.Cuenta(SaldoCuenta) TO Rol_Jefe_Tesoreria;
DENY SELECT ON Payment.Pago(Monto) TO Rol_Jefe_Tesoreria;



-------------------------PARA ROL DE ADMINISTRATIVO COBRANZAS------------------------
-- Permisos específicos para gestión de facturas
GRANT SELECT, INSERT, UPDATE ON Payment.Factura TO Rol_Administrativo_Cobranzas;
GRANT SELECT ON Payment.Detalle_Factura TO Rol_Administrativo_Cobranzas;
GRANT SELECT ON Payment.Morosidad TO Rol_Administrativo_Cobranzas;

-- Permisos sobre datos de personas (solo lectura)
GRANT SELECT ON Person.Persona TO Rol_Administrativo_Cobranzas;
GRANT SELECT ON Person.Socio TO Rol_Administrativo_Cobranzas;

-- Restricciones
DENY DELETE ON Payment.Factura TO Rol_Administrativo_Cobranzas;
DENY INSERT, UPDATE, DELETE ON Payment.Pago TO Rol_Administrativo_Cobranzas;



-------------------------PARA ROL DE ADMINISTRATIVO MOROCIDAD------------------------
-- Permisos para gestión de morosidad
GRANT SELECT, UPDATE ON Payment.Morosidad TO Rol_Administrativo_Morosidad;
GRANT SELECT ON Payment.Factura TO Rol_Administrativo_Morosidad;

-- Permisos relacionados
GRANT SELECT ON Person.Persona TO Rol_Administrativo_Morosidad;
GRANT SELECT ON Person.Socio TO Rol_Administrativo_Morosidad;

-- Restricciones
DENY INSERT, DELETE ON Payment.Morosidad TO Rol_Administrativo_Morosidad;



-------------------------PARA ROL DE ADMINISTRATIVO FACTURACION-------------------------
-- Permisos para facturación
GRANT SELECT, INSERT, UPDATE ON Payment.Factura TO Rol_Administrativo_Facturacion;
GRANT SELECT, INSERT, UPDATE ON Payment.Detalle_Factura TO Rol_Administrativo_Facturacion;

-- Permisos para consultar categorías
GRANT SELECT ON Groups.Categoria TO Rol_Administrativo_Facturacion;

-- Restricciones
DENY DELETE ON Payment.Factura TO Rol_Administrativo_Facturacion;
DENY DELETE ON Payment.Detalle_Factura TO Rol_Administrativo_Facturacion;



-------------------------PARA ROL DE ADMINISTRATIVO SOCIO-------------------------
-- Permisos para gestión de socios
GRANT SELECT, INSERT, UPDATE ON Person.Socio TO Rol_Administrativo_Socio;
GRANT SELECT, INSERT, UPDATE ON Person.Persona TO Rol_Administrativo_Socio;

-- Permisos para consultar categorías
GRANT SELECT ON Groups.Categoria TO Rol_Administrativo_Socio;

-- Restricciones
DENY DELETE ON Person.Socio TO Rol_Administrativo_Socio;
DENY DELETE ON Person.Persona TO Rol_Administrativo_Socio;



-------------------------PARA ROL DE SOCIO WEB-------------------------
-- Permisos mínimos para socios
GRANT SELECT ON Person.Socio TO Rol_Socio_Web;
GRANT SELECT ON Payment.Factura TO Rol_Socio_Web;
GRANT SELECT ON Payment.Medio_Pago TO Rol_Socio_Web;
GRANT SELECT ON Payment.Cuenta TO Rol_Socio_Web;
GRANT INSERT ON Payment.Pago TO Rol_Socio_Web;

-- Restricciones
DENY SELECT ON Person.Persona TO Rol_Socio_Web;
DENY SELECT ON Payment.Morosidad TO Rol_Socio_Web;



-------------------------PARA ROL DE PRESIDENT-------------------------
-- Control total sobre la base de datos
GRANT CONTROL ON DATABASE::COM5600_G12 TO Rol_Presidente;



-------------------------PARA ROL DE VICEPRESIDENTE-------------------------
-- Permisos amplios de consulta y actualización
GRANT SELECT, UPDATE ON SCHEMA::Payment TO Rol_Vicepresidente;
GRANT SELECT, UPDATE ON SCHEMA::Person TO Rol_Vicepresidente;
GRANT SELECT ON SCHEMA::Activity TO Rol_Vicepresidente;

-- Restricciones
DENY DELETE ON SCHEMA::Payment TO Rol_Vicepresidente;
DENY ALTER ON DATABASE::COM5600_G12 TO Rol_Vicepresidente;



-------------------------PARA ROL DE SECRETARIO-------------------------
-- Permisos de consulta básicos
GRANT SELECT ON SCHEMA::Person TO Rol_Secretario;
GRANT SELECT ON SCHEMA::Groups TO Rol_Secretario;

-- Restricciones
DENY INSERT, UPDATE, DELETE ON SCHEMA::Person TO Rol_Secretario;



----------------------PARA ROL DE VOCALES----------------------
-- Permisos mínimos de consulta (versión corregida)
GRANT SELECT ON SCHEMA::Activity TO Rol_Vocales;  -- Acceso a todo el esquema (solo lectura)
-- O si prefieres acceso solo a la tabla Asistencia:
GRANT SELECT ON Activity.Asistencia TO Rol_Vocales;  -- Sintaxis explícita con corchetes

-- Restricciones (versión corregida)
DENY INSERT, UPDATE, DELETE ON SCHEMA::Activity TO Rol_Vocales;




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
CREATE USER EliasUser FOR LOGIN EliasUser;

------------ASIGNAR ROLES A USUARIOS------------
ALTER ROLE Rol_Jefe_Tesoreria ADD MEMBER JuanUser;
ALTER ROLE Rol_Administrativo_Cobranzas ADD MEMBER PedroUser;
ALTER ROLE Rol_Administrativo_Morosidad ADD MEMBER FedeUser;
ALTER ROLE Rol_Administrativo_Facturacion ADD MEMBER EliasUser;

------En Caso dde Borrar los roles--------------
/*
DROP ROLE Rol_Jefe_Tesoreria;
DROP ROLE Rol_Administrativo_Cobranzas;
DROP ROLE Rol_Administrativo_Morosidad;
DROP ROLE Rol_Administrativo_Facturacion;
DROP ROLE Rol_Administrativo_Socio;
DROP ROLE Rol_Socio_Web;
DROP ROLE Rol_Presidente;
DROP ROLE Rol_Vicepresidente;
DROP ROLE Rol_Secretario;
DROP ROLE Rol_Vocales;
*/