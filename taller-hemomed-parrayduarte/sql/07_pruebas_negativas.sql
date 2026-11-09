-- =========================================================================
-- SCRIPT 07: PRUEBAS NEGATIVAS (Tarea 11)
-- =========================================================================

-- Prueba 1: Intervalo < 56 días
SELECT '=== Prueba 11.1: Intervalo menor a 56 días ===' AS bloque;
INSERT INTO DONACION (volumen_ml, documento, codigo_profesional) 
VALUES (450, '1010123456', 'P003');

-- Prueba 2: Despacho de unidad vencida
SELECT '=== Prueba 11.2: Despacho de unidad vencida ===' AS bloque;
UPDATE UNIDAD SET id_estado = 3 WHERE numero_unidad = 7;

-- Prueba 3: Estado fuera de dominio
SELECT '=== Prueba 11.3: Inserción de estado inválido ===' AS bloque;
INSERT INTO UNIDAD (id_donacion, id_tipo, fecha_produccion, id_estado) 
VALUES (1, 1, CURRENT_DATE, 999);
