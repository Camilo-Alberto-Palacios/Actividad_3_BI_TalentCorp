-- ==========================================================
-- SCRIPT 08: Pasar los datos a las tablas de Hechos del DWH
-- ==========================================================

USE talentcorp_dwh;

DELIMITER $$

DROP PROCEDURE IF EXISTS CargarHechos $$

CREATE PROCEDURE CargarHechos()
BEGIN
    TRUNCATE TABLE Fact_Ausencias;
    TRUNCATE TABLE Fact_Evaluaciones;
    TRUNCATE TABLE Fact_Capacitaciones;
    TRUNCATE TABLE Fact_Resumen_Mensual;

    -- Cargar hechos de Ausencias
    INSERT INTO Fact_Ausencias (EmpleadoKey, TiempoKey, TipoAusenciaKey, DepartamentoKey, Oficinakey, DiasAusentes, EsJustificada)
    SELECT de.EmpleadoKey, dt.TiempoKey, dta.TipoAusenciaKey, dd.DepartamentoKey, do.OficinaKey, a.DiasTotales, a.Justificada
    FROM talentcorp_oltp.Ausencias a
    JOIN Dim_Empleado de ON a.EmpleadoID = de.EmpleadoID AND a.FechaInicio BETWEEN de.FechaInicioValidez AND de.FechaFinValidez
    JOIN Dim_Tiempo dt ON a.FechaInicio = dt.Fecha
    JOIN Dim_TipoAusencia dta ON a.TipoAusencia = dta.NombreTipoAusencia
    JOIN talentcorp_oltp.Empleados e ON a.EmpleadoID = e.EmpleadoID
    JOIN Dim_Departamento dd ON e.DepartamentoID = dd.DepartamentoID
    JOIN Dim_Oficina do ON e.CodigoOficinaAsignada = do.CodigoOficina;

    -- Cargar hechos de Evaluaciones
    INSERT INTO Fact_Evaluaciones (EmpleadoKey, TiempoKey, DepartamentoKey, OficinaKey, Calificacion, Comentarios)
    SELECT de.EmpleadoKey, dt.TiempoKey, dd.DepartamentoKey, do.OficinaKey, ev.Calificacion, ev.Comentarios
    FROM talentcorp_oltp.EvaluacionesDesempeno ev
    JOIN Dim_Empleado de ON ev.EmpleadoID = de.EmpleadoID AND ev.FechaEvaluacion BETWEEN de.FechaInicioValidez AND de.FechaFinValidez
    JOIN Dim_Tiempo dt ON ev.FechaEvaluacion = dt.Fecha
    JOIN talentcorp_oltp.Empleados e ON ev.EmpleadoID = e.EmpleadoID
    JOIN Dim_Departamento dd ON e.DepartamentoID = dd.DepartamentoID
    JOIN Dim_Oficina do ON e.CodigoOficinaAsignada = do.CodigoOficina;

    -- Cargar hechos de Capacitaciones
    INSERT INTO Fact_Capacitaciones (EmpleadoKey, TiempoKey, DepartamentoKey, OficinaKey, CostoCapacitacion, CalificacionObtenida, DuracionHoras)
    SELECT de.EmpleadoKey, dt.TiempoKey, dd.DepartamentoKey, do.OficinaKey, c.Costo, ec.CalificacionObtenida, c.DuracionHoras
    FROM talentcorp_oltp.EmpleadosCapacitaciones ec
    JOIN talentcorp_oltp.Capacitaciones c ON ec.CapacitacionID = c.CapacitacionID
    JOIN Dim_Empleado de ON ec.EmpleadoID = de.EmpleadoID AND ec.FechaCompletado BETWEEN de.FechaInicioValidez AND de.FechaFinValidez
    JOIN Dim_Tiempo dt ON ec.FechaCompletado = dt.Fecha
    JOIN talentcorp_oltp.Empleados e ON ec.EmpleadoID = e.EmpleadoID
    JOIN Dim_Departamento dd ON e.DepartamentoID = dd.DepartamentoID
    JOIN Dim_Oficina do ON e.CodigoOficinaAsignada = do.CodigoOficina;

    -- 4. Cargar el resumen mensual (Se ajusto para que no falle si falta la fecha exacta)
    INSERT INTO Fact_Resumen_Mensual (TiempoKey, DepartamentoKey, OficinaKey, Headcount, TotalSalarios, SalarioPromedio)
    SELECT 
        (SELECT TiempoKey FROM Dim_Tiempo WHERE Fecha = CURRENT_DATE LIMIT 1),
        dd.DepartamentoKey, 
        do.OficinaKey, 
        COUNT(de.EmpleadoKey), 
        SUM(de.SalarioActual), 
        AVG(de.SalarioActual)
    FROM Dim_Empleado de
    JOIN Dim_Departamento dd ON de.NombreDepartamento = dd.NombreDepartamento
    JOIN Dim_Oficina do ON de.CiudadOficina = do.Ciudad
    WHERE de.EsActual = TRUE
    AND (SELECT COUNT(*) FROM Dim_Tiempo WHERE Fecha = CURRENT_DATE) > 0
    GROUP BY dd.DepartamentoKey, do.OficinaKey;

    -- Registrar que la carga de hechos funciono
    INSERT INTO Auditoria_ETL (Procedimiento, Estado, RegistrosCargados)
    VALUES ('Carga de Hechos', 'Exitoso', (SELECT COUNT(*) FROM Fact_Ausencias));
END $$

DELIMITER ;

CALL CargarHechos();
