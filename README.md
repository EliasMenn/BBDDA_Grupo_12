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

- DEL VALLE, FEDERICO (43316258)
- MEDINA, JUAN IGNACIO (46682620)
- MELISSARI, LUIS PEDRO JOSE (46912033)
- MENNELLA, ELIAS DAMIAN (46357008)
