-- ==========================================================
-- SCRIPT 06: Cargar la dimension de Tiempo (Fechas)
-- ==========================================================

USE talentcorp_dwh;

-- Procedimiento para llenar las fechas automaticamente
DELIMITER $$

DROP PROCEDURE IF EXISTS LlenarDimTiempo $$

CREATE PROCEDURE LlenarDimTiempo(IN fecha_inicio DATE, IN fecha_fin DATE)
BEGIN
    DECLARE fecha_actual DATE;
    SET fecha_actual = fecha_inicio;
    
    WHILE fecha_actual <= fecha_fin DO
        INSERT IGNORE INTO Dim_Tiempo (
            TiempoKey, Fecha, Anio, Trimestre, Mes, NombreMes, 
            SemanaAnio, Dia, NombreDia, EsFinDeSemana
        )
        VALUES (
            CAST(DATE_FORMAT(fecha_actual, '%Y%m%d') AS UNSIGNED),
            fecha_actual,
            YEAR(fecha_actual),
            QUARTER(fecha_actual),
            MONTH(fecha_actual),
            CASE MONTH(fecha_actual)
                WHEN 1 THEN 'Enero' WHEN 2 THEN 'Febrero' WHEN 3 THEN 'Marzo'
                WHEN 4 THEN 'Abril' WHEN 5 THEN 'Mayo' WHEN 6 THEN 'Junio'
                WHEN 7 THEN 'Julio' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Septiembre'
                WHEN 10 THEN 'Octubre' WHEN 11 THEN 'Noviembre' WHEN 12 THEN 'Diciembre'
            END,
            WEEKOFYEAR(fecha_actual),
            DAY(fecha_actual),
            CASE DAYOFWEEK(fecha_actual)
                WHEN 1 THEN 'Domingo' WHEN 2 THEN 'Lunes' WHEN 3 THEN 'Martes'
                WHEN 4 THEN 'Miércoles' WHEN 5 THEN 'Jueves' WHEN 6 THEN 'Viernes'
                WHEN 7 THEN 'Sábado'
            END,
            IF(DAYOFWEEK(fecha_actual) IN (1, 7), TRUE, FALSE)
        );
        SET fecha_actual = DATE_ADD(fecha_actual, INTERVAL 1 DAY);
    END WHILE;
END $$

DELIMITER ;

-- Ejecutar la carga desde 2022 hasta 2030
CALL LlenarDimTiempo('2022-01-01', '2030-12-31');

-- Auditoria simple
INSERT INTO Auditoria_ETL (Procedimiento, Estado, RegistrosCargados)
VALUES ('Carga de Fechas', 'Exitoso', (SELECT COUNT(*) FROM Dim_Tiempo));
