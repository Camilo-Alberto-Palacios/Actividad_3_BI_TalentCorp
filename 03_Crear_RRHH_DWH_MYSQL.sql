-- ==========================================================
-- SCRIPT 03: Crear la base de datos del DWH
-- ==========================================================

DROP DATABASE IF EXISTS talentcorp_dwh;
CREATE DATABASE talentcorp_dwh;
USE talentcorp_dwh;

-- Tabla para registrar si las cargas del ETL funcionaron (Punto 3 - Monitoreo)
CREATE TABLE Auditoria_ETL (
    ID_Log INT AUTO_INCREMENT PRIMARY KEY,
    Fecha_Ejecucion DATETIME DEFAULT CURRENT_TIMESTAMP,
    Procedimiento VARCHAR(100),
    RegistrosCargados INT DEFAULT 0,
    Estado VARCHAR(20) -- 'Exitoso' o 'Error'
);

-- Tabla para guardar los errores de calidad de datos
CREATE TABLE Auditoria_Calidad (
    AuditoriaID INT AUTO_INCREMENT PRIMARY KEY,
    TablaOrigen VARCHAR(50),
    CampoOrigen VARCHAR(50),
    ValorErroneo TEXT,
    ReglaNegocioIncumpida VARCHAR(100),
    AccionTomada VARCHAR(100),
    FechaHallazgo TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
