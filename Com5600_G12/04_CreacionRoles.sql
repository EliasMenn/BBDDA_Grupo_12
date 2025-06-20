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
-- Creaci�n de roles de base de datos
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

-- INSERTAR LOS ROLES POSIBLES-- INSERTAR LOS ROLES POSIBLES CON NOMBRES DESCRIPTIVOS
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
SELECT name AS NombreRol, type_desc AS Tipo
FROM sys.database_principals
WHERE type = 'R' AND name LIKE 'Rol_%'
ORDER BY name;

-------------------------------------------------- PARA ROL DE JEFE DE TESORERIA --------------------------------------------------
-- Permisos sobre esquema Payment (puede ver, insertar, eliminar y modoficar, pero no alterar la tabla)
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Payment TO Rol_Jefe_Tesoreria;
-----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------ PARA ROL DE JEFE DE ADMIINSTRADOR DE COBRANZAS ------------------------------------------
-- Permisos espec�ficos para ver y modificar facturas
GRANT SELECT, UPDATE ON Payment.Factura TO Rol_Administrativo_Cobranzas

-- Permisos espec�ficos para ver Detalles_Factura
GRANT SELECT ON Payment.Detalle_Factura TO Rol_Administrativo_Cobranzas

-- Permisos espec�ficos para ver Morosidad
GRANT SELECT ON Payment.Morosidad TO Rol_Administrativo_Cobranzas

-- Permisos espec�ficos para ver y insertar Pagos
GRANT SELECT, INSERT ON Payment.Pago TO Rol_Administrativo_Cobranzas

-- Permisos espec�ficos para ver, insertar y modificar Medios de Pago
GRANT SELECT, INSERT, UPDATE ON Payment.Medio_Pago TO Rol_Administrativo_Cobranzas

-- Permisos espec�ficos para ver y modificar Cuenta
GRANT SELECT, UPDATE ON Payment.Cuenta TO Rol_Administrativo_Cobranzas

-- Permisos espec�ficos para ver Refrencia de Detalle
GRANT SELECT ON Payment.Referencia_Detalle TO Rol_Administrativo_Cobranzas
-----------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------- PARA ROL DE ADMIINSTRATIVO DE MOROSIDAD ---------------------------------------------
-- Permisos para gesti�n de morosidad
GRANT SELECT, UPDATE, INSERT, DELETE ON Payment.Morosidad TO Rol_Administrativo_Morosidad;

-- Permisos para ver Facturas
GRANT SELECT ON Payment.Factura TO Rol_Administrativo_Morosidad;

-- Permisos para ver Detalles de Factura
GRANT SELECT ON Payment.Detalle_Factura TO Rol_Administrativo_Morosidad;

-- Permisos para ver Cuenta
GRANT SELECT ON Payment.Cuenta TO Rol_Administrativo_Morosidad;

-- Permisos para ver Pagos
GRANT SELECT ON Payment.Pago TO Rol_Administrativo_Morosidad;
-----------------------------------------------------------------------------------------------------------------------------------


-------------------------------------------- PARA ROL DE ADMIINSTRATIVO DE FACTURACION --------------------------------------------
-- Permisos para ver, insertar, modifcat y borrar Facturas
GRANT SELECT, INSERT, UPDATE, DELETE ON Payment.Detalle_Factura TO Rol_Administrativo_Facturacion;

-- Permisos para ver, insertar y modificar Detalles de Factura
GRANT SELECT, INSERT, UPDATE ON Payment.Factura TO Rol_Administrativo_Facturacion;

-- Permisos para ver Referencia de Detalles
GRANT SELECT ON Payment.Referencia_Detalle TO Rol_Administrativo_Facturacion;

-- Permisos para ver Cuenta
GRANT SELECT ON Payment.Cuenta TO Rol_Administrativo_Facturacion;

-- Permisos para ver morosidad
GRANT SELECT ON Payment.Morosidad TO Rol_Administrativo_Facturacion;


-- Permisos para ver Pagos
GRANT SELECT ON Payment.Pago TO Rol_Administrativo_Facturacion;
-----------------------------------------------------------------------------------------------------------------------------------




------------------------------------------------PARA ROL DE ADMINISTRATIVO DE SOCIO------------------------------------------------
-- Permisos para ver, insertar y modificar personas
GRANT SELECT, INSERT, UPDATE ON Person.Persona TO Rol_Administrativo_Socio;

-- Permisos para ver, insertar y modificar tutores
GRANT SELECT, INSERT, UPDATE ON Person.Tutor TO Rol_Administrativo_Socio;

-- Permisos para ver, insertar y modificar socios
GRANT SELECT, INSERT, UPDATE ON Person.Socio TO Rol_Administrativo_Socio;

-- Permisos para ver, insertar y modificar grupos familiares
GRANT SELECT, INSERT, UPDATE ON Groups.Grupo_Familiar TO Rol_Administrativo_Socio;

-- Permisos para ver, insertar y modificar miembros de familias
GRANT SELECT, INSERT, UPDATE ON Groups.Miembro_Familia TO Rol_Administrativo_Socio;

-- Permisos para consultar categor�as (no modifica)
GRANT SELECT ON Groups.Categoria TO Rol_Administrativo_Socio;
-----------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------PARA ROL DE SOCIO WEB------------------------------------------------
--No deberia poder hacer nada en realidad, osea no es un empleado, es un socio, solo deberia ver su cuenta
GRANT SELECT ON Payment.ver_Cuenta TO Rol_Socio_Web; --le asignamos una vista

--SP para poder ver su tabla dependiendo de su Login a testear
CREATE OR ALTER PROCEDURE Payment.ver_Cuenta
	@Login NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT c.*
    FROM Payment.Cuenta c
    JOIN Person.Mapeo_UsuarioPersona m 
        ON c.Id_Persona = m.Id_Persona
    WHERE m.Login_Name = @Login;
END;
/*ESE SOCIO WEB PODRA VER SU CUENTA YA QUE LE DAMOS EL PERMISO DE USAR ESTE SP
Y NADA MAS */

---------------------------------------------------------- PARA ROL DE PRESIDENT ----------------------------------------------------------
-- Control total sobre la base de datos, si tu presidente te pide el control se lo das
GRANT CONTROL ON DATABASE::COM5600_G12 TO Rol_Presidente;
-----------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------- PARA ROL DE VICEPRESIDENTE ----------------------------------------------------------
-- Permisos amplios de consulta y actualizaci�n
GRANT CONTROL ON DATABASE::Com5600_G12 TO Rol_Presidente;
DENY DELETE ON DATABASE::Com5600_G12 TO Rol_Vicepresidente
-----------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------- PARA ROL DE SECRETARIO -------------------------
-- Lectura de esquemas completos
GRANT SELECT ON SCHEMA::Person TO Rol_Secretario;
GRANT SELECT ON SCHEMA::Groups TO Rol_Secretario;
GRANT SELECT ON SCHEMA::Activity TO Rol_Secretario;
-- (opcional) Informaci�n clim�tica / jornadas, por si se olvida que dio llovio
GRANT SELECT ON SCHEMA::Jornada TO Rol_Secretario;
-----------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------- PARA ROL DE VOCALES -------------------------
-- Permisos m�nimos de consulta (solo debe saber de las actividades )
GRANT SELECT ON SCHEMA::Activity TO Rol_Vocales;
-----------------------------------------------------------------------------------------------------------------------------------

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
