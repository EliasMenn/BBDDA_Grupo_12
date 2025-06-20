------------------------------------------------------------------
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
-- Creación de roles de base de datos
CREATE ROLE Jefe_Tesoreria;
CREATE ROLE Administrativo_Cobranzas;
CREATE ROLE Administrativo_Morosidad;
CREATE ROLE Administrativo_Facturacion;
CREATE ROLE Administrativo_Socio;
CREATE ROLE Socio_Web;
CREATE ROLE Presidente;
CREATE ROLE Vicepresidente;
CREATE ROLE Secretario;
CREATE ROLE Vocales;

-- INSERTAR LOS ROLES POSIBLES--
EXEC Person.Agr_Rol 
    @Id_Rol = 1,  
    @Nombre_Rol = 'Jefe de Tesoreria',         
    @Descripcion = 'Jefe_Tesoreria';

EXEC Person.Agr_Rol 
    @Id_Rol = 2,  
    @Nombre_Rol = 'Administrativo de Cobranzas', 
    @Descripcion = 'Administrativo_Cobranzas';

EXEC Person.Agr_Rol 
    @Id_Rol = 3,  
    @Nombre_Rol = 'Administrativo de Morosidad', 
    @Descripcion = 'Administrativo_Morosidad';

EXEC Person.Agr_Rol 
    @Id_Rol = 4,  
    @Nombre_Rol = 'Administrativo de Facturacion',
    @Descripcion = 'Administrativo_Facturacion';

EXEC Person.Agr_Rol 
    @Id_Rol = 5,  
    @Nombre_Rol = 'Administrativo de Socio',      
    @Descripcion = 'Administrativo_Socio';

EXEC Person.Agr_Rol 
    @Id_Rol = 6,  
    @Nombre_Rol = 'Socio Web',                    
    @Descripcion = 'Socio_Web';

EXEC Person.Agr_Rol 
    @Id_Rol = 7,  
    @Nombre_Rol = 'Presidente',                   
    @Descripcion = 'Presidente';

EXEC Person.Agr_Rol 
    @Id_Rol = 8,  
    @Nombre_Rol = 'Vicepresidente',               
    @Descripcion = 'Vicepresidente';

EXEC Person.Agr_Rol 
    @Id_Rol = 9,  
    @Nombre_Rol = 'Secretario',                   
    @Descripcion = 'Secretario';

EXEC Person.Agr_Rol 
    @Id_Rol = 10, 
    @Nombre_Rol = 'Vocales',                      
    @Descripcion = 'Vocales';

--Delete Person.Rol

select * from Person.Rol
-- Consulta para verificar los roles creados
/*
SELECT name AS NombreRol, type_desc AS Tipo
FROM sys.database_principals
WHERE type = 'R' AND name LIKE 'Rol_%'
ORDER BY name;
*/s

-------------------------------------------------- PARA ROL DE JEFE DE TESORERIA --------------------------------------------------
-- Permisos sobre esquema Payment (puede ver, insertar, eliminar y modoficar, pero no alterar la tabla)
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Payment TO Jefe_Tesoreria;
-----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------ PARA ROL DE JEFE DE ADMIINSTRADOR DE COBRANZAS ------------------------------------------
-- Permisos específicos para ver y modificar facturas
GRANT SELECT, UPDATE ON Payment.Factura TO Administrativo_Cobranzas

-- Permisos específicos para ver Detalles_Factura
GRANT SELECT ON Payment.Detalle_Factura TO Administrativo_Cobranzas

-- Permisos específicos para ver Morosidad
GRANT SELECT ON Payment.Morosidad TO Administrativo_Cobranzas

-- Permisos específicos para ver y insertar Pagos
GRANT SELECT, INSERT ON Payment.Pago TO Administrativo_Cobranzas

-- Permisos específicos para ver, insertar y modificar Medios de Pago
GRANT SELECT, INSERT, UPDATE ON Payment.Medio_Pago TO Rdministrativo_Cobranzas

-- Permisos específicos para ver y modificar Cuenta
GRANT SELECT, UPDATE ON Payment.Cuenta TO Administrativo_Cobranzas

-- Permisos específicos para ver Refrencia de Detalle
GRANT SELECT ON Payment.Referencia_Detalle TO Administrativo_Cobranzas
-----------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------- PARA ROL DE ADMIINSTRATIVO DE MOROSIDAD ---------------------------------------------
-- Permisos para gestión de morosidad
GRANT SELECT, UPDATE, INSERT, DELETE ON Payment.Morosidad TO Administrativo_Morosidad;

-- Permisos para ver Facturas
GRANT SELECT ON Payment.Factura TO Administrativo_Morosidad;

-- Permisos para ver Detalles de Factura
GRANT SELECT ON Payment.Detalle_Factura TO Administrativo_Morosidad;

-- Permisos para ver Cuenta
GRANT SELECT ON Payment.Cuenta TO Administrativo_Morosidad;

-- Permisos para ver Pagos
GRANT SELECT ON Payment.Pago TO Administrativo_Morosidad;
-----------------------------------------------------------------------------------------------------------------------------------


-------------------------------------------- PARA ROL DE ADMIINSTRATIVO DE FACTURACION --------------------------------------------
-- Permisos para ver, insertar, modifcat y borrar Facturas
GRANT SELECT, INSERT, UPDATE, DELETE ON Payment.Detalle_Factura TO Administrativo_Facturacion;

-- Permisos para ver, insertar y modificar Detalles de Factura
GRANT SELECT, INSERT, UPDATE ON Payment.Factura TO Administrativo_Facturacion;

-- Permisos para ver Referencia de Detalles
GRANT SELECT ON Payment.Referencia_Detalle TO Administrativo_Facturacion;

-- Permisos para ver Cuenta
GRANT SELECT ON Payment.Cuenta TO Administrativo_Facturacion;

-- Permisos para ver morosidad
GRANT SELECT ON Payment.Morosidad TO Administrativo_Facturacion;


-- Permisos para ver Pagos
GRANT SELECT ON Payment.Pago TO Administrativo_Facturacion;
-----------------------------------------------------------------------------------------------------------------------------------




------------------------------------------------PARA ROL DE ADMINISTRATIVO DE SOCIO------------------------------------------------
-- Permisos para ver, insertar y modificar personas
GRANT SELECT, INSERT, UPDATE ON Person.Persona TO Administrativo_Socio;

-- Permisos para ver, insertar y modificar tutores
GRANT SELECT, INSERT, UPDATE ON Person.Tutor TO Administrativo_Socio;

-- Permisos para ver, insertar y modificar socios
GRANT SELECT, INSERT, UPDATE ON Person.Socio TO Administrativo_Socio;

-- Permisos para ver, insertar y modificar grupos familiares
GRANT SELECT, INSERT, UPDATE ON Groups.Grupo_Familiar TO Administrativo_Socio;

-- Permisos para ver, insertar y modificar miembros de familias
GRANT SELECT, INSERT, UPDATE ON Groups.Miembro_Familia TO Administrativo_Socio;

-- Permisos para consultar categorías (no modifica)
GRANT SELECT ON Groups.Categoria TO Administrativo_Socio;
-----------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------PARA ROL DE SOCIO WEB------------------------------------------------
--No deberia poder hacer nada en realidad, osea no es un empleado, es un socio, solo deberia ver su cuenta
CREATE OR ALTER VIEW Payment.verCuenta
AS
SELECT
    c.Id_Persona,
    c.SaldoCuenta,
    u.Nombre_Usuario
FROM Payment.Cuenta c
JOIN Person.Usuario u ON c.Id_Persona = u.Id_Persona;
GO

GRANT SELECT ON Payment.verCuenta TO Socio_Web;
/*ESE SOCIO WEB PODRA VER SU CUENTA YA QUE LE DAMOS EL PERMISO DE USAR ESTE SP
Y NADA MAS */

---------------------------------------------------------- PARA ROL DE PRESIDENT ----------------------------------------------------------
-- Control total sobre la base de datos, si tu presidente te pide el control se lo das
GRANT CONTROL ON DATABASE::COM5600_G12 TO Presidente;
-----------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------- PARA ROL DE VICEPRESIDENTE ----------------------------------------------------------
-- Permisos amplios de consulta y actualización
GRANT CONTROL ON DATABASE::Com5600_G12 TO Presidente;
DENY DELETE ON DATABASE::Com5600_G12 TO Vicepresidente
-----------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------- PARA ROL DE SECRETARIO -------------------------
-- Lectura de esquemas completos
GRANT SELECT ON SCHEMA::Person TO Secretario;
GRANT SELECT ON SCHEMA::Groups TO Secretario;
GRANT SELECT ON SCHEMA::Activity TO Secretario;
-- (opcional) Información climática / jornadas, por si se olvida que dio llovio
GRANT SELECT ON SCHEMA::Jornada TO Secretario;
-----------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------- PARA ROL DE VOCALES -------------------------
-- Permisos mínimos de consulta (solo debe saber de las actividades )
GRANT SELECT ON SCHEMA::Activity TO Vocales;
-----------------------------------------------------------------------------------------------------------------------------------

------En Caso dde Borrar los roles--------------
/*
DROP ROLE Jefe_Tesoreria;
DROP ROLE Administrativo_Cobranzas;
DROP ROLE Administrativo_Morosidad;
DROP ROLE Administrativo_Facturacion;
DROP ROLE Administrativo_Socio;
DROP ROLE Socio_Web;
DROP ROLE Presidente;
DROP ROLE Vicepresidente;
DROP ROLE Secretario;
DROP ROLE Vocales;
*/
