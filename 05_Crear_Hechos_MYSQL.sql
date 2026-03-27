-- ==========================================================
-- SCRIPT 05: Crear las tablas de Hechos (Fact Tables)
-- ==========================================================

USE talentcorp_dwh;

-- 1. Hechos de las Ausencias
CREATE TABLE Fact_Ausencias (
    AusenciaKey INT AUTO_INCREMENT PRIMARY KEY,
    EmpleadoKey INT NOT NULL,
    TiempoKey INT NOT NULL,
    TipoAusenciaKey INT NOT NULL,
    DepartamentoKey INT NOT NULL,
    OficinaKey INT NOT NULL,
    DiasAusentes INT NOT NULL,
    EsJustificada BOOLEAN,
    FOREIGN KEY (EmpleadoKey) REFERENCES Dim_Empleado(EmpleadoKey),
    FOREIGN KEY (TiempoKey) REFERENCES Dim_Tiempo(TiempoKey),
    FOREIGN KEY (TipoAusenciaKey) REFERENCES Dim_TipoAusencia(TipoAusenciaKey),
    FOREIGN KEY (DepartamentoKey) REFERENCES Dim_Departamento(DepartamentoKey),
    FOREIGN KEY (OficinaKey) REFERENCES Dim_Oficina(OficinaKey)
);

-- 2. Hechos de las Evaluaciones
CREATE TABLE Fact_Evaluaciones (
    EvaluacionKey INT AUTO_INCREMENT PRIMARY KEY,
    EmpleadoKey INT NOT NULL,
    TiempoKey INT NOT NULL,
    DepartamentoKey INT NOT NULL,
    OficinaKey INT NOT NULL,
    Calificacion DECIMAL(3, 2) NOT NULL,
    Comentarios TEXT,
    FOREIGN KEY (EmpleadoKey) REFERENCES Dim_Empleado(EmpleadoKey),
    FOREIGN KEY (TiempoKey) REFERENCES Dim_Tiempo(TiempoKey),
    FOREIGN KEY (DepartamentoKey) REFERENCES Dim_Departamento(DepartamentoKey),
    FOREIGN KEY (OficinaKey) REFERENCES Dim_Oficina(OficinaKey)
);

-- 3. Hechos de las Capacitaciones
CREATE TABLE Fact_Capacitaciones (
    CapacitacionKey INT AUTO_INCREMENT PRIMARY KEY,
    EmpleadoKey INT NOT NULL,
    TiempoKey INT NOT NULL,
    DepartamentoKey INT NOT NULL,
    OficinaKey INT NOT NULL,
    CostoCapacitacion DECIMAL(12, 2) DEFAULT 0,
    CalificacionObtenida DECIMAL(5, 2),
    DuracionHoras INT,
    FOREIGN KEY (EmpleadoKey) REFERENCES Dim_Empleado(EmpleadoKey),
    FOREIGN KEY (TiempoKey) REFERENCES Dim_Tiempo(TiempoKey),
    FOREIGN KEY (DepartamentoKey) REFERENCES Dim_Departamento(DepartamentoKey),
    FOREIGN KEY (OficinaKey) REFERENCES Dim_Oficina(OficinaKey)
);

-- 4. Tabla de resumen mensual (Agregada)
CREATE TABLE Fact_Resumen_Mensual (
    ResumenKey INT AUTO_INCREMENT PRIMARY KEY,
    TiempoKey INT NOT NULL,
    DepartamentoKey INT NOT NULL,
    OficinaKey INT NOT NULL,
    Headcount INT NOT NULL,
    TotalSalarios DECIMAL(15, 2) NOT NULL,
    SalarioPromedio DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (TiempoKey) REFERENCES Dim_Tiempo(TiempoKey),
    FOREIGN KEY (DepartamentoKey) REFERENCES Dim_Departamento(DepartamentoKey),
    FOREIGN KEY (OficinaKey) REFERENCES Dim_Oficina(OficinaKey)
);
