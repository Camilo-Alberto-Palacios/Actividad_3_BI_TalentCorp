-- ==========================================================
-- SCRIPT 02: Poblar las tablas con datos de prueba
-- ==========================================================

USE talentcorp_oltp;

-- Limpieza previa de tablas (en orden inverso de dependencias)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE EmpleadosCapacitaciones;
TRUNCATE TABLE EvaluacionesDesempeno;
TRUNCATE TABLE Ausencias;
TRUNCATE TABLE Empleados;
TRUNCATE TABLE Puestos;
TRUNCATE TABLE Departamentos;
TRUNCATE TABLE Oficinas;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Agregamos las oficinas principales
INSERT INTO Oficinas (CodigoOficina, Ciudad, Pais, Region, CodigoPostal, Telefono, Direccion) VALUES
('MAD-CENTRO', 'Madrid', 'España', 'Comunidad de Madrid', '28001', '+34 912 345 678', 'Calle Mayor 10'),
('BOG-NORTE', 'Bogotá', 'Colombia', 'Cundinamarca', '110111', '+57 601 765 432', 'Carrera 7 # 100-20'),
('MEX-SUR', 'Ciudad de México', 'México', 'CDMX', '01000', '+52 555 123 456', 'Insurgentes Sur 1500'),
('LIMA-MIRA', 'Lima', 'Perú', 'Lima Metropolitana', '15047', '+51 1 987 654', 'Av. Jose Larco 400'),
('SCL-PROV', 'Santiago', 'Chile', 'Región Metropolitana', '7500000', '+56 2 234 567', 'Providencia 1234');

-- 2. Agregamos los departamentos que pide el caso
INSERT INTO Departamentos (NombreDepartamento, Descripcion, CodigoOficina) VALUES
('Recursos Humanos', 'Gestión del talento y bienestar laboral', 'MAD-CENTRO'),
('Tecnología', 'Desarrollo de software e infraestructura IT', 'BOG-NORTE'),
('Ventas', 'Comercialización de servicios globales', 'MEX-SUR'),
('Finanzas', 'Contabilidad, tesorería y presupuesto', 'LIMA-MIRA'),
('Marketing', 'Publicidad, branding y redes sociales', 'SCL-PROV');

-- 3. Poblar Puestos de Trabajo
INSERT INTO Puestos (NombrePuesto, NivelSalarial, SalarioMinimo, SalarioMaximo) VALUES
('Gerente de RRHH', 'Senior', 5000, 8000),
('Analista de RRHH', 'Mid-Level', 2500, 4000),
('Arquitecto de SW', 'Senior', 6000, 10000),
('Desarrollador Fullstack', 'Mid-Level', 3000, 5500),
('Junior Developer', 'Junior', 1500, 2500),
('Director Comercial', 'Senior', 5500, 9000),
('Ejecutivo de Ventas', 'Mid-Level', 2000, 3500),
('Director Financiero', 'Senior', 5500, 9000),
('Contador Senior', 'Senior', 4000, 6000),
('Director de Marketing', 'Senior', 5000, 8500);

-- 4. Agregamos los 5 empleados que somos nosotros (Jefes)
INSERT IGNORE INTO Empleados (Identificacion, Nombre, Apellidos, FechaNacimiento, Genero, EstadoCivil, Email, Telefono, FechaContratacion, DepartamentoID, PuestoID, SalarioActual, EmpleadoJefeID, CodigoOficinaAsignada) VALUES
('ID001', 'Camilo', 'Palacios', '1985-05-15', 'M', 'Casado/a', 'cpalacios@talentcorp.com', '3001234567', '2015-01-10', 2, 3, 7500, NULL, 'BOG-NORTE'),
('ID002', 'Ana', 'García', '1988-03-20', 'F', 'Soltero/a', 'agarcia@talentcorp.com', '3101234567', '2016-02-15', 1, 1, 6500, NULL, 'MAD-CENTRO'),
('ID003', 'Luis', 'Hernandez', '1982-11-25', 'M', 'Casado/a', 'lhernandez@talentcorp.com', '3201234567', '2014-06-01', 3, 6, 7000, NULL, 'MEX-SUR'),
('ID004', 'Maria', 'Rodriguez', '1987-07-30', 'F', 'Soltero/a', 'mrodriguez@talentcorp.com', '3301234567', '2017-09-20', 4, 8, 6800, NULL, 'LIMA-MIRA'),
('ID005', 'Javier', 'Soto', '1990-12-10', 'M', 'Casado/a', 'jsoto@talentcorp.com', '3401234567', '2018-03-05', 5, 10, 6200, NULL, 'SCL-PROV');

-- Agregamos mas empleados humanos para que la base se vea real
INSERT IGNORE INTO Empleados (Identificacion, Nombre, Apellidos, FechaNacimiento, Genero, EstadoCivil, Email, Telefono, FechaContratacion, DepartamentoID, PuestoID, SalarioActual, EmpleadoJefeID, CodigoOficinaAsignada)
SELECT 
    CONCAT('ID', LPAD(seq, 3, '0')), 
    ELT((seq % 10) + 1, 'Juan', 'Pedro', 'Maria', 'Lucia', 'Carlos', 'Elena', 'Diego', 'Sofia', 'Roberto', 'Paula'), 
    ELT((seq % 10) + 1, 'García', 'Rodríguez', 'López', 'Martínez', 'Sánchez', 'Pérez', 'Gómez', 'Martín', 'Jiménez', 'Ruiz'), 
    '1995-01-01', CASE WHEN (seq % 10) IN (2, 3, 7) THEN 'F' ELSE 'M' END, 'Soltero/a',
    CONCAT('emp', seq, '@talentcorp.com'), '5550000', '2022-01-01', 
    (seq % 5) + 1, (seq % 10) + 1, 3000 + (seq * 10), (seq % 5) + 1,
    CASE seq % 5 WHEN 0 THEN 'MAD-CENTRO' WHEN 1 THEN 'BOG-NORTE' WHEN 2 THEN 'MEX-SUR' WHEN 3 THEN 'LIMA-MIRA' ELSE 'SCL-PROV' END
FROM (
    SELECT (a.N + b.N * 10 + 6) as seq
    FROM (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a
    CROSS JOIN (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) b
) t LIMIT 45;

-- 5. Agregamos las faltas (Ausencias) para el analisis
INSERT IGNORE INTO Ausencias (EmpleadoID, TipoAusencia, FechaInicio, FechaFin, Justificada, Comentarios)
SELECT 
    (seq % 50) + 1, 
    CASE seq % 4 WHEN 0 THEN 'Vacaciones' WHEN 1 THEN 'Enfermedad' WHEN 2 THEN 'Permiso Personal' ELSE 'Licencia Médica' END,
    DATE_ADD('2023-01-01', INTERVAL seq DAY),
    DATE_ADD('2023-01-01', INTERVAL (seq + 1 + (CASE WHEN (seq % 50) + 1 <= 5 THEN (seq % 10) ELSE (seq % 4) END)) DAY),
    (seq % 2 = 0), 'Carga masiva automatica'
FROM (
    SELECT (a.N + b.N * 10) as seq FROM (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a
    CROSS JOIN (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b
) t LIMIT 150; -- Increased limit for more variety

-- 6. Agregamos las notas de desempeño (Evaluaciones)
INSERT IGNORE INTO EvaluacionesDesempeno (EmpleadoID, FechaEvaluacion, Calificacion, EvaluadorID, Comentarios)
SELECT EmpleadoID, '2023-12-15', 3.0 + (EmpleadoID % 20 / 10.0), EmpleadoJefeID, 'Evaluacion sistematica'
FROM Empleados LIMIT 50;

INSERT IGNORE INTO EvaluacionesDesempeno (EmpleadoID, FechaEvaluacion, Calificacion, EvaluadorID, Comentarios)
SELECT (seq % 50) + 1, '2024-06-30', 4.5, 1, 'Refuerzo semestral'
FROM (SELECT (a.N + b.N * 10) as seq FROM (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a CROSS JOIN (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2) b) t LIMIT 30;

-- 7. Agregamos los cursos que ha hecho la gente
INSERT IGNORE INTO Capacitaciones (NombreCapacitacion, Descripcion, Proveedor, Costo, FechaInicio, FechaFin, DuracionHoras) VALUES
('Liderazgo Estratégico', 'Curso para mandos superiores', 'Harvard Mentor', 1200, '2023-05-01', '2023-05-15', 40),
('Excel Avanzado', 'Analisis de datos intensivo', 'Sena', 0, '2023-06-10', '2023-07-10', 60),
('Power BI para Negocios', 'Visualizacion de KPIs', 'Microsoft', 500, '2023-08-01', '2023-08-30', 48),
('Python Fundamentals', 'Introduccion a automatizacion', 'Coursera', 200, '2023-09-01', '2023-10-15', 80),
('Marketing Digital', 'Estrategias RRSS', 'Google Ads Academy', 0, '2023-11-01', '2023-11-30', 30);

-- 8. Poblar Empleados_Capacitaciones (Mínimo 60)
INSERT IGNORE INTO EmpleadosCapacitaciones (EmpleadoID, CapacitacionID, CalificacionObtenida, FechaCompletado, Estado, Comentarios)
SELECT (seq % 50) + 1, (seq % 5) + 1, 70 + (seq % 30), '2023-12-01', 'Completada', 'Certificado obtenido'
FROM (SELECT (a.N + b.N * 10) as seq FROM (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a CROSS JOIN (SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) b) t LIMIT 65;
