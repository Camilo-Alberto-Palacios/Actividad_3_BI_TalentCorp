-- ==========================================================
-- SCRIPT 04: Crear las Dimensiones del cubo (Modelo Estrella)
-- ==========================================================

USE talentcorp_dwh;

-- 1. Dimension para el tiempo (Fechas)
CREATE TABLE IF NOT EXISTS Dim_Tiempo (
    TiempoKey INT PRIMARY KEY,
    Fecha DATE NOT NULL,
    Anio INT NOT NULL,
    Trimestre INT NOT NULL,
    Mes INT NOT NULL,
    NombreMes VARCHAR(20) NOT NULL,
    SemanaAnio INT NOT NULL,
    Dia INT NOT NULL,
    NombreDia VARCHAR(20) NOT NULL,
    EsFinDeSemana INT NOT NULL
);

-- 2. Dimension para las oficinas
CREATE TABLE IF NOT EXISTS Dim_Oficina (
    OficinaKey INT AUTO_INCREMENT PRIMARY KEY,
    CodigoOficina VARCHAR(20) UNIQUE NOT NULL,
    Ciudad VARCHAR(100),
    Pais VARCHAR(100),
    Region VARCHAR(100)
);

-- 3. Dimension para los departamentos
CREATE TABLE IF NOT EXISTS Dim_Departamento (
    DepartamentoKey INT AUTO_INCREMENT PRIMARY KEY,
    DepartamentoID INT UNIQUE NOT NULL,
    NombreDepartamento VARCHAR(100),
    Descripcion TEXT
);

-- 4. Dimension para los puestos
CREATE TABLE IF NOT EXISTS Dim_Puesto (
    PuestoKey INT AUTO_INCREMENT PRIMARY KEY,
    PuestoID INT UNIQUE NOT NULL,
    NombrePuesto VARCHAR(100),
    NivelSalarial VARCHAR(20)
);

-- 5. Dimension para los empleados
CREATE TABLE IF NOT EXISTS Dim_Empleado (
    EmpleadoKey INT AUTO_INCREMENT PRIMARY KEY,
    EmpleadoID INT NOT NULL,
    Identificacion VARCHAR(20) NOT NULL,
    NombreCompleto VARCHAR(255) NOT NULL,
    Email VARCHAR(150),
    Genero VARCHAR(20),
    FechaContratacion DATE,
    NombrePuesto VARCHAR(100),
    NombreDepartamento VARCHAR(100),
    SalarioActual DECIMAL(12, 2),
    CiudadOficina VARCHAR(100),
    FechaInicioValidez DATETIME NOT NULL,
    FechaFinValidez DATETIME DEFAULT '9999-12-31',
    EsActual INT DEFAULT 1,
    UltimaActualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Dimension para los tipos de faltas
CREATE TABLE IF NOT EXISTS Dim_TipoAusencia (
    TipoAusenciaKey INT AUTO_INCREMENT PRIMARY KEY,
    NombreTipoAusencia VARCHAR(50) UNIQUE NOT NULL
);

INSERT IGNORE INTO Dim_TipoAusencia (NombreTipoAusencia) VALUES 
('Vacaciones'), ('Enfermedad'), ('Permiso Personal'), ('Licencia Médica');
