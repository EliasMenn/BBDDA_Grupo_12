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

CREATE OR ALTER PROCEDURE Asignar_Rol
    @IdUsuario INT,
    @IdCategoria INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @NombreRol NVARCHAR(50);
        DECLARE @NombreUsuario NVARCHAR(100);

        -- Determinar el rol según la categoría con IF
        IF @IdCategoria BETWEEN 1 AND 4
            SET @NombreRol = 'Rol_Tesoreria';
        ELSE IF @IdCategoria BETWEEN 5 AND 7
            SET @NombreRol = 'Rol_Socios';
        ELSE IF @IdCategoria BETWEEN 8 AND 10
            SET @NombreRol = 'Rol_Autoridades';
        ELSE
            SET @NombreRol = NULL;

        -- Obtener el nombre de usuario
        SELECT @NombreUsuario = Nombre_Usuario 
        FROM Person.Usuario 
        WHERE Id_Persona = @IdUsuario;
        
        -- Validaciones
        IF @NombreRol IS NULL
        BEGIN
            RAISERROR('La categoría especificada no tiene un rol asignado', 16, 1);
            RETURN;
        END
        
        IF @NombreUsuario IS NULL
        BEGIN
            RAISERROR('El usuario especificado no existe', 16, 1);
            RETURN;
        END
        
        -- Verificar que el rol existe
        IF NOT EXISTS (
            SELECT 1 
            FROM sys.database_principals 
            WHERE name = @NombreRol AND type = 'R'
        )
        BEGIN
            RAISERROR('El rol asignado para esta categoría no existe en la base de datos', 16, 1);
            RETURN;
        END
        
        -- Quitar al usuario de otros roles primero
        DECLARE @sql NVARCHAR(MAX) = '';
        
        SELECT @sql = @sql + 
            'ALTER ROLE ' + QUOTENAME(r.name) + 
            ' DROP MEMBER ' + QUOTENAME(@NombreUsuario) + ';'
        FROM sys.database_role_members rm
        JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
        JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
        WHERE m.name = @NombreUsuario;
        
        IF LEN(@sql) > 0
        BEGIN
            EXEC(@sql);
        END
        
        -- Asignar el nuevo rol
        SET @sql = 
            'ALTER ROLE ' + QUOTENAME(@NombreRol) + 
            ' ADD MEMBER ' + QUOTENAME(@NombreUsuario) + ';';
        
        EXEC(@sql);
        
        PRINT CONCAT('Usuario ID ', @IdUsuario, ' (', @NombreUsuario, 
                    ') asignado al rol ', @NombreRol, 
                    ' según categoría ', @IdCategoria);
    END TRY
    BEGIN CATCH
        PRINT 'Error al asignar rol por categoría: ' + ERROR_MESSAGE();
    END CATCH
END;
---FALTA PROBAR