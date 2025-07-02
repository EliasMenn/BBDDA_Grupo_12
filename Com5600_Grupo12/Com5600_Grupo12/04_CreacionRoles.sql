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
GO
-- INSERTAR LOS ROLES POSIBLES CON NOMBRES IDÉNTICOS A LOS ROLES DE BD
EXEC Person.Agr_Rol 
    @Id_Rol = 1,  
    @Nombre_Rol = 'Jefe_Tesoreria',         
    @Descripcion = 'Rol para jefes de tesorería';

EXEC Person.Agr_Rol 
    @Id_Rol = 2,  
    @Nombre_Rol = 'Administrativo_Cobranzas', 
    @Descripcion = 'Rol para administrativos de cobranzas';

EXEC Person.Agr_Rol 
    @Id_Rol = 3,  
    @Nombre_Rol = 'Administrativo_Morosidad', 
    @Descripcion = 'Rol para administrativos de morosidad';

EXEC Person.Agr_Rol 
    @Id_Rol = 4,  
    @Nombre_Rol = 'Administrativo_Facturacion',
    @Descripcion = 'Rol para administrativos de facturación';

EXEC Person.Agr_Rol 
    @Id_Rol = 5,  
    @Nombre_Rol = 'Administrativo_Socio',      
    @Descripcion = 'Rol para administrativos de socios';

EXEC Person.Agr_Rol 
    @Id_Rol = 6,  
    @Nombre_Rol = 'Socio_Web',                    
    @Descripcion = 'Rol para socios con acceso web';

EXEC Person.Agr_Rol 
    @Id_Rol = 7,  
    @Nombre_Rol = 'Presidente',                   
    @Descripcion = 'Rol para presidente';

EXEC Person.Agr_Rol 
    @Id_Rol = 8,  
    @Nombre_Rol = 'Vicepresidente',               
    @Descripcion = 'Rol para vicepresidente';

EXEC Person.Agr_Rol 
    @Id_Rol = 9,  
    @Nombre_Rol = 'Secretario',                   
    @Descripcion = 'Rol para secretario';

EXEC Person.Agr_Rol 
    @Id_Rol = 10, 
    @Nombre_Rol = 'Vocales',                      
    @Descripcion = 'Rol para vocales';

select * from Person.Rol

-- Consulta para verificar los roles creados
/*
SELECT name AS Nombre_Rol 
FROM sys.database_principals 
WHERE type = 'R' 
ORDER BY name;
*/


-------------------------------------------------- PARA ROL DE JEFE DE TESORERIA --------------------------------------------------
-- Permisos sobre esquema Payment (puede ver, insertar, eliminar y modoficar, pero no alterar la tabla)
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Payment TO Jefe_Tesoreria;
-----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------ PARA ROL DE JEFE DE ADMIINSTRADOR DE COBRANZAS ------------------------------------------
-- Permisos para modificar facturas
GRANT EXECUTE ON Payment.Modificar_Factura TO Administrativo_Cobranzas

-- Permisos específicos para ver facturas
GRANT SELECT ON Payment.Factura TO Administrativo_Cobranzas

-- Permisos específicos para ver Detalles_Factura
GRANT SELECT ON Payment.Detalle_Factura TO Administrativo_Cobranzas

-- Permisos específicos para ver Morosidad
GRANT SELECT ON Payment.Morosidad TO Administrativo_Cobranzas

-- Permisos específicos para ver y insertar Pagos
GRANT SELECT, INSERT ON Payment.Pago TO Administrativo_Cobranzas

-- Permisos específicos para ver, insertar y modificar Medios de Pago
GRANT EXECUTE ON Payment.Agr_TipoMedio TO Administrativo_Cobranzas
GRANT EXECUTE ON Payment.Modificar_TipoMedio TO Administrativo_Cobranzas

GRANT SELECT ON Payment.Medio_Pago TO Administrativo_Cobranzas

-- Permisos específicos para ver y modificar Cuenta
GRANT EXECUTE ON Payment.Modificar_Cuenta TO Administrativo_Cobranzas

GRANT SELECT ON Payment.Cuenta TO Administrativo_Cobranzas

-- Permisos específicos para ver Refrencia de Detalle
GRANT SELECT ON Payment.Referencia_Detalle TO Administrativo_Cobranzas
-----------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------- PARA ROL DE ADMIINSTRATIVO DE MOROSIDAD ---------------------------------------------
-- Permisos para gestion de morosidad
GRANT EXECUTE ON Payment.Agr_Morosidad TO Administrativo_Morosidad
GRANT EXECUTE ON Payment.Modificar_Morosidad TO Administrativo_Morosidad
GRANT EXECUTE ON Payment.Borrar_Moroso TO Administrativo_Morosidad

-- Permisos para gestión de morosidad
GRANT SELECT ON Payment.Morosidad TO Administrativo_Morosidad;

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
-- Permisos para insertar, modifcat y borrar detalles de Facturas
GRANT EXECUTE ON Payment.Agr_Detalle_Factura TO Administrativo_Facturacion
GRANT EXECUTE ON Payment.Modificar_Detalle_Factura TO Administrativo_Facturacion
GRANT EXECUTE ON Payment.Borrar_Detalle_Factura TO Administrativo_Facturacion

-- Permisos para ver detalles de factura
GRANT SELECT ON Payment.Detalle_Factura TO Administrativo_Facturacion;

-- Permisos para insertar, modifcat y borrar Facturas
GRANT EXECUTE ON Payment.Agr_Factura TO Administrativo_Facturacion
GRANT EXECUTE ON Payment.Modificar_Factura TO Administrativo_Facturacion
GRANT EXECUTE ON Payment.Borrar_Factura TO Administrativo_Facturacion

-- Permisos para ver, insertar y modificar Detalles de Factura
GRANT SELECT ON Payment.Factura TO Administrativo_Facturacion;

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
GRANT EXECUTE ON Person.Agr_Persona TO Administrativo_Socio
GRANT EXECUTE ON Person.Modificar_Persona TO Administrativo_Socio

GRANT SELECT ON Person.Persona TO Administrativo_Socio;

-- Permisos para ver, insertar y modificar tutores
GRANT EXECUTE ON Person.Agr_Tutor TO Administrativo_Socio
GRANT EXECUTE ON Person.Modificar_Tutor TO Administrativo_Socio

GRANT SELECT ON Person.Tutor TO Administrativo_Socio;

-- Permisos para ver, insertar y modificar socios
GRANT EXECUTE ON Person.Agr_Socio TO Administrativo_Socio
GRANT EXECUTE ON Person.Modificar_Socio TO Administrativo_Socio

GRANT SELECT ON Person.Socio TO Administrativo_Socio;

-- Permisos para ver, insertar y modificar grupos familiares
GRANT EXECUTE ON Groups.Agr_Grupo_Familiar TO Administrativo_Socio
GRANT EXECUTE ON Groups.Modificar_Grupo_Familiar TO Administrativo_Socio

GRANT SELECT ON Groups.Grupo_Familiar TO Administrativo_Socio;

-- Permisos para ver, insertar y modificar miembros de familias
GRANT EXECUTE ON Groups.Agr_Miembro_Familia TO Administrativo_Socio
GRANT EXECUTE ON Groups.Modificar_Miembro_Familia TO Administrativo_Socio

GRANT SELECT ON Groups.Miembro_Familia TO Administrativo_Socio;

-- Permisos para consultar categorías (no modifica)
GRANT SELECT ON Groups.Categoria TO Administrativo_Socio;
-----------------------------------------------------------------------------------------------------------------------------------
GO

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
DROP ROLE Jefe_Tesoreria
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
