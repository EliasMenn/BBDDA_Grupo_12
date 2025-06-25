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


CREATE OR ALTER PROCEDURE Person.Asignar_Rol
    @Id_Rol INT,
    @Nombre_Usuario NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NombreRol NVARCHAR(100);
    DECLARE @SQL NVARCHAR(MAX);
    
    -- Verificar si el rol existe
    IF NOT EXISTS (SELECT 1 FROM Person.Rol WHERE Id_Rol = @Id_Rol)
    BEGIN
        RAISERROR('El ID de rol no está registrado en el sistema', 16, 1);
        RETURN;
    END
    
    -- Obtener el nombre del rol
    SELECT @NombreRol = Nombre_Rol FROM Person.Rol WHERE Id_Rol = @Id_Rol;
    
    -- Verificar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM Person.Usuario WHERE Nombre_Usuario = @Nombre_Usuario)
    BEGIN
        RAISERROR('El nombre de usuario no está registrado', 16, 1);
        RETURN;
    END
    
    -- Asignar el rol al usuario - SQL DINAMICO(creo)
    SET @SQL = N'ALTER ROLE ' + QUOTENAME(@NombreRol) +  N' ADD MEMBER ' + QUOTENAME(@Nombre_Usuario) + N';';
    
    EXEC sp_executesql @SQL;
END;

