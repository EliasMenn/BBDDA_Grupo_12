--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 12
--Melissari, Pedro 46912033
--Del Valle, Federico 43316258
--Medina, Juan 46682620
--Mennella, Elias Damian 46357008
----------------------------------------------------------------

-- Creación de Stored Procedures para la generacion de informes --

USE master

USE Com5600_G12
GO

IF SCHEMA_ID('Reporte') IS NULL
BEGIN
	EXEC('CREATE SCHEMA Reporte');
END

GO 

CREATE OR ALTER PROCEDURE Reporte.Morosos
	@FechaDesde DATE,
	@FechaHasta DATE
AS
	BEGIN
		WITH Morosos AS(
			SELECT p.Id_Persona, p.Apellido, p.Nombre, m.Id_Factura,
				FORMAT(m.Fecha_Bloqueo,'MMMM', 'es-ES') AS MesImpago, 
				COUNT(*) OVER (PARTITION BY p.Id_Persona) AS CantidadImpaga
			FROM Payment.Morosidad m
			JOIN Payment.Factura f ON f.Id_Factura = m.Id_Factura 
			JOIN Person.Persona p ON p.Id_Persona = f.Id_Persona
			WHERE Fecha_Bloqueo BETWEEN @FechaDesde AND @FechaHasta
		)
		SELECT DISTINCT 
			'Morosos Recurrentes' AS NombreReporte,
			 CONCAT(CONVERT(VARCHAR, @FechaDesde, 23), ' - ', CONVERT(VARCHAR, @FechaHasta, 23)) AS Periodo,
			 Id_Persona, Apellido, Nombre, Id_Factura, MesImpago,
			 DENSE_RANK() OVER (ORDER BY CantidadImpaga) AS Ranking
			 FROM Morosos
			 WHERE CantidadImpaga > 2
			 ORDER BY Ranking DESC
	END
GO
CREATE OR ALTER PROCEDURE Reporte.Ingresos
AS
	BEGIN 
	WITH TablaBase AS (
		SELECT  ac.Nombre, 
				DATEPART(MONTH, f.fecha_Emision) AS NumeroMes,
				FORMAT(f.fecha_Emision,'MMM') AS Mes,
				SUM(f.total) as Recaudado
		FROM Payment.Factura f
		JOIN Payment.Detalle_Factura df ON df.Id_Factura = f.Id_Factura
		JOIN Payment.Referencia_Detalle rf ON rf.Id_Detalle = df.Id_Detalle
		JOIN Activity.Actividad ac ON ac.Id_Actividad = rf.Referencia AND rf.Tipo_Referencia = 2
		WHERE LOWER(f.Estado_Factura) = 'pagada' AND DATEPART(YEAR, f.fecha_Emision) = DATEPART(YEAR, GETDATE()) 
		GROUP BY ac.Id_Actividad, ac.Nombre, FORMAT(f.fecha_Emision,'MMM'), DATEPART(MONTH, f.fecha_Emision)
		),
	TablaAcumulada AS (
		SELECT  Nombre,
				NumeroMes,
				Mes,
				SUM(Recaudado) OVER (PARTITION BY Nombre ORDER BY NumeroMes ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RecaudadoAcumulado
				FROM TablaBase
		)
		SELECT 
			Nombre,
			ISNULL([1], 0) AS Enero,
			ISNULL([2], 0) AS Febrero,
			ISNULL([3], 0) AS Marzo,
			ISNULL([4], 0) AS Abril,
			ISNULL([5], 0) AS Mayo,
			ISNULL([6], 0) AS Junio,
			ISNULL([7], 0) AS Julio,
			ISNULL([8], 0) AS Agosto,
			ISNULL([9], 0) AS Septiembre,
			ISNULL([10], 0) AS Octubre,
			ISNULL([11], 0) AS Noviembre,
			ISNULL([12], 0) AS Diciembre
		FROM TablaAcumulada
		PIVOT (
			SUM(RecaudadoAcumulado) FOR Mes IN ([1], [2], [3], [4], [5], [6], 
									 [7], [8], [9], [10], [11], [12])
		) AS TablaPivot

	END
GO

CREATE OR ALTER PROCEDURE Reporte.InasistenciasAct
AS
	BEGIN
		SELECT c.Nombre_Cat, a.Nombre_Act, COUNT(*) AS Ausentes_Categoria, SUM(COUNT(*)) OVER 
		(PARTITION BY a.Nombre_Act) AS Total_Ausencias_Actividad
		FROM Activity.Asistencia a
		JOIN Person.Socio s ON s.Id_Socio = a.Id_Socio
		JOIN Groups.Categoria c ON c.Id_Categoria = s.Id_Categoria 
		WHERE a.Asistencia IN ('A','J')
		GROUP BY c.Nombre_Cat, a.Nombre_Act
		ORDER BY 
			SUM(COUNT(*)) OVER (PARTITION BY a.Nombre_Act) DESC,
			COUNT(*) DESC
	END
GO

CREATE OR ALTER PROCEDURE Reporte.Inasistencias
AS
	BEGIN
		SELECT DISTINCT 
		p.Nombre, p.Apellido, 
		DATEDIFF(YEAR, p.Fecha_Nacimiento, GETDATE()) AS Edad,
		s.Id_Categoria, a.Nombre_Act
		FROM Activity.Asistencia a
		JOIN Person.Socio s ON s.Id_Socio = a.Id_Socio
		JOIN Person.Persona p ON p.Id_Persona = s.Id_Persona

	END
GO