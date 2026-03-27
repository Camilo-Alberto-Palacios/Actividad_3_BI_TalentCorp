-- ==========================================================
-- SCRIPT 00: Tabla para ver si las cargas funcionaron bien (Auditoria)
-- ==========================================================

USE talentcorp_dwh;

-- 1. Tabla para monitorear los procesos de carga
-- Requisito para cumplimiento de calidad de datos y auditoría de procesos.
CREATE TABLE IF NOT EXISTS Log_Cargas (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    FechaEjecucion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Procedimiento VARCHAR(100) NOT NULL,
    RegistrosCargados INT DEFAULT 0,
    Estado VARCHAR(20) DEFAULT 'EXITOSO', -- (EXITOSO, FALLIDO, EN CURSO)
    MensajeError TEXT
);

-- Ejemplo de uso (Opcional):
-- INSERT INTO Log_Cargas (Procedimiento, RegistrosCargados, Estado) 
-- VALUES ('Carga Dimensiones', 50, 'EXITOSO');
