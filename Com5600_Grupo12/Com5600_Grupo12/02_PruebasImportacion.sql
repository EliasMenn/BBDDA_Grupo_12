USE master
GO

USE Com5600_G12
GO

---------------------------------------------------------------------------------------
------------------------------ AD HOC PARA IMPORTAR EXCEL -----------------------------

sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'AllowInProcess', 1;
    
EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'DynamicParameters', 1;

GO

---------------------------------------------------------------------------------------
----------------------------------- CATEGORÍAS ----------------------------------------

EXEC Groups.Importar_Categorias
    @RutaArchivo = N'C:\Users\Pedro Melissari\Desktop\Archivos BDD\Datos socios.xlsx',
    @NombreHoja = N'Tarifas',
    @RangoCeldas = N'B10:D13';

SELECT * FROM Groups.Categoria

--DELETE FROM Groups.Categoria
--DBCC CHECKIDENT ('Groups.Categoria', RESEED, 99);

---------------------------------------------------------------------------------------
------------------------------ RESPONSABLES DE PAGO -----------------------------------
EXEC Person.Importar_Responsables_Pago
	@RutaArchivo = 'C:\Users\Pedro Melissari\Desktop\Archivos BDD\Datos socios.xlsx',
	@NombreHoja = 'Responsables de Pago$'

SELECT * FROM Person.Persona
SELECT * FROM Person.Socio
SELECT * FROM Person.Tutor

/*
DELETE FROM Person.Socio

DELETE FROM Person.Tutor
DBCC CHECKIDENT ('Person.Tutor', RESEED, 0);

DELETE FROM Person.Persona
DBCC CHECKIDENT ('Person.Persona', RESEED, 0);
*/

---------------------------------------------------------------------------------------
------------------------------------ GRUPO FAMILIAR -----------------------------------
EXEC Groups.ImportarGrupoFamiliar
	@RutaArchivo = 'C:\Users\Pedro Melissari\Desktop\Archivos BDD\Datos socios.xlsx',
	@NombreHoja = 'Grupo Familiar$'

SELECT * FROM Groups.Grupo_Familiar
SELECT * FROM Groups.Miembro_Familia ORDER BY Id_Familia

--DELETE FROM Groups.Miembro_Familia
--DELETE FROM Groups.Grupo_Familiar

---------------------------------------------------------------------------------------
----------------------------------- ACTIVIDADES ---------------------------------------

EXEC Activity.Importar_Actividades
    @RutaArchivo = N'C:\Users\Pedro Melissari\Desktop\Archivos BDD\Datos socios.xlsx',
    @NombreHoja = N'Tarifas',
    @RangoCeldas = N'B1:D8';

UPDATE Activity.Actividad
SET Nombre = 'Ajedrez'
WHERE Nombre = 'Ajederez';

--DELETE FROM Activity.Actividad
SELECT * FROM Activity.Actividad

---------------------------------------------------------------------------------------
------------------------------ COSTO ACTIVIDAD EXTRA ----------------------------------

EXEC Activity.Importar_Costos_Actividad_Extra
    @RutaArchivo = 'C:\Users\Pedro Melissari\Desktop\Archivos BDD\Datos socios.xlsx',
    @NombreHoja = 'Tarifas',
    @RangoCeldas = 'B17:F22'

SELECT * FROM Activity.Costo_Actividad_Extra
--DELETE FROM Activity.Costo_Actividad_Extra

---------------------------------------------------------------------------------------
--------------------------- TIPOS DE MEDIO DE PAGO ------------------------------------

-- Visa
EXEC Payment.Agr_TipoMedio 
    @Nombre_Medio = 'Visa', 
    @Datos_Necesarios = 'número de tarjeta, código de seguridad, vencimiento';

-- MasterCard
EXEC Payment.Agr_TipoMedio 
    @Nombre_Medio = 'MasterCard', 
    @Datos_Necesarios = 'número de tarjeta, código de seguridad, vencimiento';

-- Tarjeta Naranja
EXEC Payment.Agr_TipoMedio 
    @Nombre_Medio = 'Tarjeta Naranja', 
    @Datos_Necesarios = 'número de tarjeta, código de seguridad, vencimiento';

-- Débito Automático (vía tarjeta de crédito)
EXEC Payment.Agr_TipoMedio 
    @Nombre_Medio = 'Débito Automático', 
    @Datos_Necesarios = 'número de tarjeta, vencimiento';

-- Pago Fácil
EXEC Payment.Agr_TipoMedio 
    @Nombre_Medio = 'Pago Fácil', 
    @Datos_Necesarios = 'DNI del titular';

-- Rapipago
EXEC Payment.Agr_TipoMedio 
    @Nombre_Medio = 'Rapipago', 
    @Datos_Necesarios = 'DNI del titular';

-- Transferencia Mercado Pago
EXEC Payment.Agr_TipoMedio 
    @Nombre_Medio = 'Transferencia Mercado Pago', 
    @Datos_Necesarios = 'email asociado a cuenta, alias o CVU';

SELECT * FROM Payment.TipoMedio
--DELETE FROM Payment.TipoMedio
--DELETE FROM Payment.Medio_Pago

---------------------------------------------------------------------------------------
------------------------------------- ASISTENCIAS -------------------------------------

EXEC Activity.Importar_Asistencia
    @RutaArchivo = 'C:\Users\Pedro Melissari\Desktop\Archivos BDD\Datos socios.xlsx',
    @NombreHoja = 'presentismo_actividades$'

SELECT * FROM Activity.Asistencia
--DELETE FROM Activity.Asistencia

--SELECT Nombre FROM Activity.Actividad

---------------------------------------------------------------------------------------
------------------------------------- PAGOS -------------------------------------------

EXEC Payment.Importar_Pagos
    @RutaArchivo = 'C:\Users\Pedro Melissari\Desktop\Archivos BDD\Datos socios.xlsx',
    @NombreHoja = 'pago cuotas$'

SELECT * FROM Payment.Pago ORDER BY Responsable_Original
--DELETE FROM Payment.Pago
