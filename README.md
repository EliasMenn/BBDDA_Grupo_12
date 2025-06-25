# Trabajo Práctico - Bases de Datos Aplicadas

## Link al repositorio

https://github.com/EliasMenn/BBDDA_Grupo_12

## Descripción

Este repositorio contiene el desarrollo del Trabajo Práctico de la materia Bases de Datos Aplicadas. El objetivo es modelar e implementar una base de datos para la institución Sol Norte, digitalizando los procesos de inscripción de socios, actividades deportivas, facturación, morosidad y pagos.

## Contenido del repositorio

- **/documentacion**: DER en formato dbdiagram y PNG, documento de configuración de SQL Server.
- **/scripts**:
  - `00_CreacionTablasYEstructuras.sql`: creación de tablas y esquemas.
  - `01_CreacionSPParaAgregado.sql`: procedimientos de agregación.
  - `01_CreacionSPParaBorrado.sql`: procedimientos de borrado.
  - `01_CreacionSPParaModificado.sql`: procedimientos de modificación.
  - `01_PruebasSPABM.sql`: scripts de prueba para evaluar el funcionamiento de los SPs.
  - `02_SPImportacion.sql`: procedimientos para la importación de los archivos.
  - `02_PruebasImportacion.sql`: scripts de prueba para los SP de importación.
  - `03_CreacionReportes.sql`: procedimientos para la creación de reportes.
  - `03_PruebaReportes.sql`: scripts de prueba para los SP de creación de reportes.
  - `04_CreacionRoles.sql`: scripts para la creación de roles.
  - `04_SPParaAsignarRol.sql`: procedimientos para la asignación de roles.
  - `04_SPEncriptado.sql`: procedimientos para el encriptado de datos.

## Procedimientos almacenados

Se implementaron procedimientos en los siguientes esquemas:

- `Person`: alta, modificación y baja de personas, socios, tutores y usuarios.
- `Groups`: manejo de grupo familiar y miembros.
- `Activity`: actividades, horarios e inscripciones.
- `Payment`: facturación, pagos, morosidad y medios de pago.
- `Jornada`: registro y actualización de jornadas.

## Requisitos técnicos

- SQL Server 2022
- SSMS
- Configuraciones documentadas en `ConfiguracionDBMS.docx`

## Integrantes - Grupo 12

- DEL VALLE, FEDERICO (43316258), Nick: Federico Del Valle
- MEDINA, JUAN IGNACIO (46682620), Nick: JuanMedina613
- MELISSARI, LUIS PEDRO JOSE (46912033), Nick: FuturoIngPedro
- MENNELLA, ELIAS DAMIAN (46357008), Nick: EliasMenn

## Actualización DER 20/06/2025
- Se modificó el campo de Id_Socio, paso de ser INT a tipo VARCHAR(20)
- Se agregaron campos de encriptado a las tablas Persona, Socio y Usuario
- Se agregaron las tablas de Asistencia y Costo_Actividad_Extra
