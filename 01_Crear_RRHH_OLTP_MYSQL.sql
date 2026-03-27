-- ==========================================================
-- SCRIPT 01: Creacion de las tablas de la empresa (OLTP)
-- ==========================================================

DROP DATABASE IF EXISTS talentcorp_oltp;
CREATE DATABASE talentcorp_oltp;
USE talentcorp_oltp;

-- 1. Tabla para las Oficinas de la empresa
CREATE TABLE Oficinas (
    CodigoOficina VARCHAR(20) PRIMARY KEY,
    Ciudad VARCHAR(100) NOT NULL,
    Pais VARCHAR(100) NOT NULL,
    Region VARCHAR(100),
    CodigoPostal VARCHAR(20),
    Telefono VARCHAR(50),
    Direccion VARCHAR(255) NOT NULL
);

-- 2. Tabla para los Departamentos
CREATE TABLE Departamentos (
    DepartamentoID INT AUTO_INCREMENT PRIMARY KEY,
    NombreDepartamento VARCHAR(100) NOT NULL,
    Descripcion TEXT,
    CodigoOficina VARCHAR(20),
    CONSTRAINT fk_departamento_oficina FOREIGN KEY (CodigoOficina) 
        REFERENCES Oficinas(CodigoOficina) ON DELETE SET NULL
);

-- 3. Tabla para los Cargos (Puestos)
CREATE TABLE Puestos (
    PuestoID INT AUTO_INCREMENT PRIMARY KEY,
    NombrePuesto VARCHAR(100) NOT NULL,
    NivelSalarial ENUM('Junior', 'Mid-Level', 'Senior') NOT NULL,
    SalarioMinimo DECIMAL(12, 2) NOT NULL,
    SalarioMaximo DECIMAL(12, 2) NOT NULL,
    CONSTRAINT chk_salario CHECK (SalarioMaximo >= SalarioMinimo)
);

-- 4. Tabla principal de Empleados
CREATE TABLE Empleados (
    EmpleadoID INT AUTO_INCREMENT PRIMARY KEY,
    Identificacion VARCHAR(20) UNIQUE NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Genero ENUM('M', 'F', 'Otro') NOT NULL,
    EstadoCivil ENUM('Soltero/a', 'Casado/a', 'Divorciado/a', 'Viudo/a', 'Union Libre') NOT NULL,
    Email VARCHAR(150) UNIQUE NOT NULL,
    Telefono VARCHAR(50),
    FechaContratacion DATE NOT NULL,
    DepartamentoID INT,
    PuestoID INT,
    SalarioActual DECIMAL(12, 2) NOT NULL,
    EmpleadoJefeID INT,
    CodigoOficinaAsignada VARCHAR(20),
    CONSTRAINT fk_empleado_depto FOREIGN KEY (DepartamentoID) REFERENCES Departamentos(DepartamentoID),
    CONSTRAINT fk_empleado_puesto FOREIGN KEY (PuestoID) REFERENCES Puestos(PuestoID),
    CONSTRAINT fk_empleado_jefe FOREIGN KEY (EmpleadoJefeID) REFERENCES Empleados(EmpleadoID),
    CONSTRAINT fk_empleado_oficina FOREIGN KEY (CodigoOficinaAsignada) REFERENCES Oficinas(CodigoOficina)
);

-- 5. Tabla para registrar las faltas (Ausencias)
CREATE TABLE Ausencias (
    AusenciaID INT AUTO_INCREMENT PRIMARY KEY,
    EmpleadoID INT NOT NULL,
    TipoAusencia ENUM('Vacaciones', 'Enfermedad', 'Permiso Personal', 'Licencia Médica') NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL,
    DiasTotales INT GENERATED ALWAYS AS (DATEDIFF(FechaFin, FechaInicio) + 1) STORED,
    Justificada BOOLEAN DEFAULT FALSE,
    Comentarios TEXT,
    FechaRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ausencia_empleado FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID),
    CONSTRAINT chk_fechas_ausencia CHECK (FechaFin >= FechaInicio)
);

-- 6. Tabla para las notas de desempeño
CREATE TABLE EvaluacionesDesempeno (
    EvaluacionID INT AUTO_INCREMENT PRIMARY KEY,
    EmpleadoID INT NOT NULL,
    FechaEvaluacion DATE NOT NULL,
    Calificacion DECIMAL(3, 2) NOT NULL,
    EvaluadorID INT,
    Comentarios TEXT,
    FechaRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_evaluacion_empleado FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID),
    CONSTRAINT fk_evaluacion_evaluador FOREIGN KEY (EvaluadorID) REFERENCES Empleados(EmpleadoID),
    CONSTRAINT chk_calificacion CHECK (Calificacion BETWEEN 1.0 AND 5.0)
);

-- 7. Tabla para los cursos y capacitaciones
CREATE TABLE Capacitaciones (
    CapacitacionID INT AUTO_INCREMENT PRIMARY KEY,
    NombreCapacitacion VARCHAR(150) NOT NULL,
    Descripcion TEXT,
    Proveedor VARCHAR(150),
    Costo DECIMAL(12, 2) DEFAULT 0,
    FechaInicio DATE,
    FechaFin DATE,
    DuracionHoras INT,
    CONSTRAINT chk_fechas_capacitacion CHECK (FechaFin >= FechaInicio)
);

-- 8. Relacion entre empleados y sus cursos
CREATE TABLE EmpleadosCapacitaciones (
    EmpleadoID INT NOT NULL,
    CapacitacionID INT NOT NULL,
    CalificacionObtenida DECIMAL(5, 2),
    FechaCompletado DATE,
    Estado ENUM('Completada', 'En Curso', 'No Iniciada') DEFAULT 'En Curso',
    Comentarios TEXT,
    PRIMARY KEY (EmpleadoID, CapacitacionID),
    CONSTRAINT fk_rel_empleado FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID),
    CONSTRAINT fk_rel_capacitacion FOREIGN KEY (CapacitacionID) REFERENCES Capacitaciones(CapacitacionID)
);
