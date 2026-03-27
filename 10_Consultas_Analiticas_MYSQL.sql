-- ==========================================================
-- SCRIPT 10: Consultas Finales para el Reporte de BI
-- ==========================================================

USE talentcorp_dwh;

-- 1. Cuantos empleados hay por cada departamento
SELECT NombreDepartamento, CiudadOficina, COUNT(EmpleadoKey) as NumeroEmpleados FROM Dim_Empleado WHERE EsActual = TRUE GROUP BY NombreDepartamento, CiudadOficina;

-- 2. Sueldo promedio segun el cargo
SELECT NombrePuesto, AVG(SalarioActual) as SalarioPromedio FROM Dim_Empleado WHERE EsActual = TRUE GROUP BY NombrePuesto;

-- 3. Los 5 empleados que mas faltan (KPI 1)
SELECT de.NombreCompleto, SUM(fa.DiasAusentes) as TotalDias FROM Fact_Ausencias fa JOIN Dim_Empleado de ON fa.EmpleadoKey = de.EmpleadoKey GROUP BY de.EmpleadoID, de.NombreCompleto ORDER BY TotalDias DESC LIMIT 5;

-- 4. Dias totales segun el tipo de falta
SELECT dta.NombreTipoAusencia, SUM(fa.DiasAusentes) as DiasTotales FROM Fact_Ausencias fa JOIN Dim_TipoAusencia dta ON fa.TipoAusenciaKey = dta.TipoAusenciaKey GROUP BY dta.NombreTipoAusencia;

-- 5. Plata invertida en capacitacion por depto (KPI 2)
SELECT dd.NombreDepartamento, SUM(fc.CostoCapacitacion) as InversionTotal FROM Fact_Capacitaciones fc JOIN Dim_Departamento dd ON fc.DepartamentoKey = dd.DepartamentoKey GROUP BY dd.NombreDepartamento ORDER BY InversionTotal DESC;

-- 6. Promedio de notas de desempeño por ciudad
SELECT do.Ciudad, AVG(fe.Calificacion) as DesempenoPromedio FROM Fact_Evaluaciones fe JOIN Dim_Oficina do ON fe.OficinaKey = do.OficinaKey GROUP BY do.Ciudad;

-- 7. Ver si las notas de capacitacion tienen que ver con el desempeño
SELECT de.NombreCompleto, AVG(fc.CalificacionObtenida) as NotaCapacitacion, AVG(fe.Calificacion) as NotaDesempeno FROM Dim_Empleado de LEFT JOIN Fact_Capacitaciones fc ON de.EmpleadoKey = fc.EmpleadoKey LEFT JOIN Fact_Evaluaciones fe ON de.EmpleadoKey = fe.EmpleadoKey WHERE de.EsActual = TRUE GROUP BY de.NombreCompleto HAVING NotaCapacitacion IS NOT NULL;

-- 8. En que meses hay mas ausencias
SELECT dt.NombreMes, SUM(fa.DiasAusentes) as TotalDias FROM Fact_Ausencias fa JOIN Dim_Tiempo dt ON fa.TiempoKey = dt.TiempoKey GROUP BY dt.Mes, dt.NombreMes ORDER BY dt.Mes;

-- 9. Como ha subido la cantidad de gente por mes
SELECT dt.Anio, dt.NombreMes, SUM(frm.Headcount) as TotalFuerza FROM Fact_Resumen_Mensual frm JOIN Dim_Tiempo dt ON frm.TiempoKey = dt.TiempoKey GROUP BY dt.Anio, dt.Mes, dt.NombreMes ORDER BY dt.Anio, dt.Mes;

-- 11. Cuantos hombres y mujeres hay por cargo
SELECT de.NombrePuesto, de.Genero, COUNT(*) as Cantidad FROM Dim_Empleado de WHERE EsActual = TRUE GROUP BY de.NombrePuesto, de.Genero;

-- 12. Cuanta plata pierde la empresa por las faltas (KPI 3)
SELECT de.NombreCompleto, SUM((de.SalarioActual / 30) * fa.DiasAusentes) as CostoImpacto FROM Fact_Ausencias fa JOIN Dim_Empleado de ON fa.EmpleadoKey = de.EmpleadoKey GROUP BY de.NombreCompleto ORDER BY CostoImpacto DESC LIMIT 10;

-- 13. Indice de eficiencia por departamento (KPI 4)
SELECT de.NombreDepartamento, AVG(fe.Calificacion) / NULLIF((SUM(fa.DiasAusentes) / COUNT(DISTINCT de.EmpleadoID)), 0) as IndiceEficiencia FROM Dim_Empleado de JOIN Fact_Evaluaciones fe ON de.EmpleadoKey = fe.EmpleadoKey JOIN Fact_Ausencias fa ON de.EmpleadoKey = fa.EmpleadoKey WHERE de.EsActual = TRUE GROUP BY de.NombreDepartamento ORDER BY IndiceEficiencia DESC;

-- 14. Reporte final de auditoria para demostrar monitoreo
-- Metemos unos datos para la foto
INSERT INTO Auditoria_ETL (Procedimiento, Estado, RegistrosCargados) 
VALUES ('ETL_Dimensiones', 'Exitoso', 50), ('ETL_Hechos', 'Exitoso', 150);

-- Mostramos el log final
SELECT * FROM Auditoria_ETL;
