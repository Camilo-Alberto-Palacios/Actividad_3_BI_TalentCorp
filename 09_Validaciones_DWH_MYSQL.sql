-- ==========================================================
-- SCRIPT 09: Validar que los datos esten bien cargados (Calidad)
-- ==========================================================

USE talentcorp_dwh;

-- 1. VALIDACIÓN DE COMPLETITUD (Ver si se pasaron todos los datos)
SELECT 
    'Empleados' AS Entidad,
    (SELECT COUNT(*) FROM talentcorp_oltp.Empleados) AS Origen,
    (SELECT COUNT(*) FROM talentcorp_dwh.Dim_Empleado WHERE EsActual = TRUE) AS Destino,
    CASE WHEN (SELECT COUNT(*) FROM talentcorp_oltp.Empleados) = (SELECT COUNT(*) FROM talentcorp_dwh.Dim_Empleado WHERE EsActual = TRUE) 
         THEN '✅ EXITOSO' ELSE '❌ DIFERENCIA' END AS Resultado
UNION ALL
SELECT 
    'Ausencias' AS Entidad,
    (SELECT COUNT(*) FROM talentcorp_oltp.Ausencias) AS Origen,
    (SELECT COUNT(*) FROM talentcorp_dwh.Fact_Ausencias) AS Destino,
    CASE WHEN (SELECT COUNT(*) FROM talentcorp_oltp.Ausencias) = (SELECT COUNT(*) FROM talentcorp_dwh.Fact_Ausencias) 
         THEN '✅ EXITOSO' ELSE '❌ DIFERENCIA' END AS Resultado
UNION ALL
SELECT 
    'Evaluaciones' AS Entidad,
    (SELECT COUNT(*) FROM talentcorp_oltp.EvaluacionesDesempeno) AS Origen,
    (SELECT COUNT(*) FROM talentcorp_dwh.Fact_Evaluaciones) AS Destino,
    CASE WHEN (SELECT COUNT(*) FROM talentcorp_oltp.EvaluacionesDesempeno) = (SELECT COUNT(*) FROM talentcorp_dwh.Fact_Evaluaciones) 
         THEN '✅ EXITOSO' ELSE '❌ DIFERENCIA' END AS Resultado;

TRUNCATE TABLE Auditoria_Calidad;

-- 2. Revisar errores comunes en las tablas
INSERT INTO Auditoria_Calidad (TablaOrigen, CampoOrigen, ValorErroneo, ReglaNegocioIncumpida, AccionTomada)
SELECT 'Dim_Empleado', 'SalarioActual', SalarioActual, 'Salario debe ser > 0', 'Revisar en OLTP' FROM Dim_Empleado WHERE SalarioActual <= 0
UNION ALL
SELECT 'Dim_Empleado', 'EmpleadoID', EmpleadoID, 'Solo un registro EsActual=TRUE por empleado', 'Corregir SCD' FROM Dim_Empleado WHERE EsActual = TRUE GROUP BY EmpleadoID HAVING COUNT(*) > 1
UNION ALL
SELECT 'Fact_Ausencias', 'EmpleadoKey', EmpleadoKey, 'EmpleadoKey huerfano', 'Revisar FK' FROM Fact_Ausencias WHERE EmpleadoKey NOT IN (SELECT EmpleadoKey FROM Dim_Empleado)
UNION ALL
SELECT 'Fact_Ausencias', 'TiempoKey', TiempoKey, 'TiempoKey huerfano', 'Cargar Dim_Tiempo' FROM Fact_Ausencias WHERE TiempoKey NOT IN (SELECT TiempoKey FROM Dim_Tiempo)
UNION ALL
SELECT 'Fact_Capacitaciones', 'CalificacionObtenida', CalificacionObtenida, 'Calificacion fuera de 0-100', 'Revisar Notas' FROM Fact_Capacitaciones WHERE CalificacionObtenida < 0 OR CalificacionObtenida > 100;

-- Ver resumen de fallos encontrados
SELECT ReglaNegocioIncumpida as Validacion, COUNT(*) as TotalHallazgos FROM Auditoria_Calidad GROUP BY ReglaNegocioIncumpida;
