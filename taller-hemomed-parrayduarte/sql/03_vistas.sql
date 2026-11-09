-- =========================================================================
-- SCRIPT 03: VISTAS (10 Vistas requeridas)
-- =========================================================================

-- Simples
CREATE VIEW v_unidades_disponibles AS
SELECT u.numero_unidad, tc.nombre AS componente, u.fecha_produccion, u.fecha_vencimiento
FROM UNIDAD u
JOIN TIPO_COMPONENTE tc ON u.id_tipo = tc.id_tipo
JOIN ESTADO e ON u.id_estado = e.id_estado
WHERE e.nombre_estado = 'disponible';

CREATE VIEW v_donantes_habilitados AS
SELECT d.* 
FROM DONANTE d
WHERE NOT EXISTS (
    SELECT 1 FROM DONACION dn 
    WHERE dn.documento = d.documento 
    AND (CURRENT_TIMESTAMP - dn.fecha_hora) < INTERVAL '56 days'
);

-- Combinación
CREATE VIEW v_trazabilidad AS
SELECT u.numero_unidad, tc.nombre AS componente, d.documento AS documento_donante, 
       d.nombre AS nombre_donante, dn.fecha_hora AS fecha_donacion, p.nombre AS profesional_proceso
FROM UNIDAD u
JOIN TIPO_COMPONENTE tc ON u.id_tipo = tc.id_tipo
JOIN DONACION dn ON u.id_donacion = dn.id_donacion
JOIN DONANTE d ON dn.documento = d.documento
JOIN PROFESIONAL p ON dn.codigo_profesional = p.codigo;

CREATE VIEW v_solicitud_detalle AS
SELECT s.numero_solicitud, s.fecha, i.nombre AS institucion, 
       tc.nombre AS componente, ds.cantidad_solicitada, ds.cantidad_despachada
FROM SOLICITUD s
JOIN INSTITUCION i ON s.NIT_institucion = i.NIT
JOIN DETALLE_SOLICITUD ds ON s.numero_solicitud = ds.numero_solicitud
JOIN TIPO_COMPONENTE tc ON ds.id_tipo = tc.id_tipo;

-- Agregación
CREATE VIEW v_stock_por_grupo AS
SELECT tc.nombre AS componente, d.grupo_sanguineo, d.rh, COUNT(u.numero_unidad) AS total_unidades
FROM UNIDAD u
JOIN TIPO_COMPONENTE tc ON u.id_tipo = tc.id_tipo
JOIN DONACION dn ON u.id_donacion = dn.id_donacion
JOIN DONANTE d ON dn.documento = d.documento
JOIN ESTADO e ON u.id_estado = e.id_estado
WHERE e.nombre_estado = 'disponible'
GROUP BY tc.nombre, d.grupo_sanguineo, d.rh;

CREATE VIEW v_donaciones_por_mes AS
SELECT TO_CHAR(fecha_hora, 'YYYY-MM') AS mes, COUNT(*) AS total_donaciones, SUM(volumen_ml) AS volumen_total
FROM DONACION
GROUP BY TO_CHAR(fecha_hora, 'YYYY-MM');

-- Control (Deben devolver 0 filas)
CREATE VIEW v_control_despachadas AS
SELECT ds.numero_solicitud, ds.id_tipo, ds.cantidad_despachada,
       (SELECT COUNT(*) FROM UNIDAD u 
        JOIN ESTADO e ON u.id_estado = e.id_estado 
        WHERE u.id_tipo = ds.id_tipo AND e.nombre_estado = 'despachada') AS real_despachadas
FROM DETALLE_SOLICITUD ds
WHERE ds.cantidad_despachada != (
    SELECT COUNT(*) FROM UNIDAD u 
    JOIN ESTADO e ON u.id_estado = e.id_estado 
    WHERE u.id_tipo = ds.id_tipo AND e.nombre_estado = 'despachada'
);

CREATE VIEW v_control_vencidas AS
SELECT u.numero_unidad, u.fecha_vencimiento, e.nombre_estado
FROM UNIDAD u
JOIN ESTADO e ON u.id_estado = e.id_estado
WHERE u.fecha_vencimiento < CURRENT_DATE AND e.nombre_estado = 'disponible';

-- Materializadas
CREATE MATERIALIZED VIEW mv_stock_actual AS
SELECT tc.nombre AS componente, COUNT(*) AS unidades_disponibles
FROM UNIDAD u
JOIN TIPO_COMPONENTE tc ON u.id_tipo = tc.id_tipo
JOIN ESTADO e ON u.id_estado = e.id_estado
WHERE e.nombre_estado = 'disponible'
GROUP BY tc.nombre;

CREATE MATERIALIZED VIEW mv_consumo_institucion AS
SELECT i.nombre AS institucion, tc.nombre AS componente, SUM(ds.cantidad_despachada) AS total_consumido
FROM INSTITUCION i
JOIN SOLICITUD s ON i.NIT = s.NIT_institucion
JOIN DETALLE_SOLICITUD ds ON s.numero_solicitud = ds.numero_solicitud
JOIN TIPO_COMPONENTE tc ON ds.id_tipo = tc.id_tipo
GROUP BY i.nombre, tc.nombre;
