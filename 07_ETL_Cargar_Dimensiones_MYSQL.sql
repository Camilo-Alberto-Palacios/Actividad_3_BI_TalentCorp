-- ==========================================================
-- SCRIPT 07: Pasar los datos a las Dimensiones del DWH
-- ==========================================================

USE talentcorp_dwh;

DELIMITER $$

DROP PROCEDURE IF EXISTS CargarDimensiones $$

CREATE PROCEDURE CargarDimensiones()
BEGIN
    -- Limpieza inicial para asegurar carga limpia en la prueba actual
    SET FOREIGN_KEY_CHECKS = 0;
    TRUNCATE TABLE Dim_Empleado;
    SET FOREIGN_KEY_CHECKS = 1;

    -- 1. Cargar datos de Oficinas
    INSERT INTO Dim_Oficina (CodigoOficina, Ciudad, Pais, Region)
    SELECT CodigoOficina, Ciudad, Pais, Region FROM talentcorp_oltp.Oficinas
    ON DUPLICATE KEY UPDATE Ciudad = VALUES(Ciudad), Pais = VALUES(Pais), Region = VALUES(Region);

    -- 2. Cargar datos de Departamentos
    INSERT INTO Dim_Departamento (DepartamentoID, NombreDepartamento, Descripcion)
    SELECT DepartamentoID, NombreDepartamento, Descripcion FROM talentcorp_oltp.Departamentos
    ON DUPLICATE KEY UPDATE NombreDepartamento = VALUES(NombreDepartamento), Descripcion = VALUES(Descripcion);

    -- 3. Cargar datos de Puestos
    INSERT INTO Dim_Puesto (PuestoID, NombrePuesto, NivelSalarial)
    SELECT PuestoID, NombrePuesto, NivelSalarial FROM talentcorp_oltp.Puestos
    ON DUPLICATE KEY UPDATE NombrePuesto = VALUES(NombrePuesto), NivelSalarial = VALUES(NivelSalarial);

    -- 4. Cargar datos de Empleados (Historico)
    -- Inactivar antiguos
    UPDATE Dim_Empleado de
    JOIN talentcorp_oltp.Empleados e ON de.EmpleadoID = e.EmpleadoID
    JOIN talentcorp_oltp.Puestos p ON e.PuestoID = p.PuestoID
    JOIN talentcorp_oltp.Departamentos d ON e.DepartamentoID = d.DepartamentoID
    JOIN talentcorp_oltp.Oficinas o ON e.CodigoOficinaAsignada = o.CodigoOficina
    SET de.EsActual = FALSE, de.FechaFinValidez = NOW()
    WHERE de.EsActual = TRUE AND (de.SalarioActual <> e.SalarioActual OR de.NombrePuesto <> p.NombrePuesto OR de.NombreDepartamento <> d.NombreDepartamento);

    -- Insertar nuevos/cambios
    INSERT INTO Dim_Empleado (EmpleadoID, Identificacion, NombreCompleto, Email, Genero, FechaContratacion, NombrePuesto, NombreDepartamento, SalarioActual, CiudadOficina, FechaInicioValidez, EsActual)
    SELECT e.EmpleadoID, e.Identificacion, CONCAT(e.Nombre, ' ', e.Apellidos), e.Email, e.Genero, e.FechaContratacion, p.NombrePuesto, d.NombreDepartamento, e.SalarioActual, o.Ciudad, e.FechaContratacion, TRUE
    FROM talentcorp_oltp.Empleados e
    JOIN talentcorp_oltp.Puestos p ON e.PuestoID = p.PuestoID
    JOIN talentcorp_oltp.Departamentos d ON e.DepartamentoID = d.DepartamentoID
    JOIN talentcorp_oltp.Oficinas o ON e.CodigoOficinaAsignada = o.CodigoOficina
    LEFT JOIN Dim_Empleado de ON e.EmpleadoID = de.EmpleadoID AND de.EsActual = TRUE
    WHERE de.EmpleadoID IS NULL;

    -- Registrar que la carga de dimensiones funciono
    INSERT INTO Auditoria_ETL (Procedimiento, Estado, RegistrosCargados)
    VALUES ('Carga de Dimensiones', 'Exitoso', (SELECT COUNT(*) FROM Dim_Empleado WHERE EsActual = TRUE));
END $$

DELIMITER ;

CALL CargarDimensiones();
