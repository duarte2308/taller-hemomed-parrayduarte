-- =========================================================================
-- SCRIPT 06: CONSULTAS DE NEGOCIO (Tarea 10)
-- =========================================================================

-- 1. Unidades disponibles por tipo y grupo sanguíneo
SELECT tc.nombre AS componente, d.grupo_sanguineo, d.rh, COUNT(u.numero_unidad) AS disponibles
FROM UNIDAD u
JOIN TIPO_COMPONENTE tc ON u.id_tipo = tc.id_tipo
JOIN DONACION dn ON u.id_donacion = dn.id_donacion
JOIN DONANTE d ON dn.documento = d.documento
JOIN ESTADO e ON u.id_estado = e.id_estado
WHERE e.nombre_estado = 'disponible'
GROUP BY tc.nombre, d.grupo_sanguineo, d.rh;

-- 2. Trazabilidad de una unidad específica
SELECT u.numero_unidad, d.documento, d.nombre AS donante, p.nombre AS profesional, dn.fecha_hora
FROM UNIDAD u
JOIN DONACION dn ON u.id_donacion = dn.id_donacion
JOIN DONANTE d ON dn.documento = d.documento
JOIN PROFESIONAL p ON dn.codigo_profesional = p.codigo
WHERE u.numero_unidad = 1;

-- 3. Donantes habilitados para donar hoy
SELECT * FROM v_donantes_habilitados;

-- 4. Unidades que vencen en los próximos 7 días
SELECT numero_unidad, id_tipo, fecha_vencimiento
FROM UNIDAD
WHERE fecha_vencimiento BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days';

-- 5. Histórico de cambios de estado de una unidad
SELECT he.numero_unidad, e.nombre_estado, p.nombre AS profesional, he.fecha_hora
FROM HISTORIAL_ESTADO he
JOIN ESTADO e ON he.id_estado = e.id_estado
JOIN PROFESIONAL p ON he.codigo_profesional = p.codigo
WHERE he.numero_unidad = 1;

-- 6. Solicitudes pendientes y remanente por despachar
SELECT s.numero_solicitud, i.nombre AS institucion, tc.nombre AS componente, 
       ds.cantidad_solicitada, ds.cantidad_despachada, 
       (ds.cantidad_solicitada - ds.cantidad_despachada) AS faltante
FROM SOLICITUD s
JOIN INSTITUCION i ON s.NIT_institucion = i.NIT
JOIN DETALLE_SOLICITUD ds ON s.numero_solicitud = ds.numero_solicitud
JOIN TIPO_COMPONENTE tc ON ds.id_tipo = tc.id_tipo
WHERE s.estado_solicitud = 'pendiente';

-- 7. Donaciones recibidas por mes
SELECT * FROM v_donaciones_por_mes;

-- 8. Institución de mayor consumo
SELECT i.nombre AS institucion, tc.nombre AS componente, SUM(ds.cantidad_despachada) AS total_consumido
FROM INSTITUCION i
JOIN SOLICITUD s ON i.NIT = s.NIT_institucion
JOIN DETALLE_SOLICITUD ds ON s.numero_solicitud = ds.numero_solicitud
JOIN TIPO_COMPONENTE tc ON ds.id_tipo = tc.id_tipo
GROUP BY i.nombre, tc.nombre
ORDER BY total_consumido DESC LIMIT 1;

-- 9. Unidades descartadas por vencimiento en el último trimestre
SELECT COUNT(*) AS total_descartadas
FROM HISTORIAL_ESTADO he
JOIN ESTADO e ON he.id_estado = e.id_estado
WHERE e.nombre_estado = 'vencida' 
AND he.fecha_hora >= CURRENT_DATE - INTERVAL '3 months';

-- 10. Profesional con mayor cantidad de unidades procesadas
SELECT p.nombre, COUNT(u.numero_unidad) AS unidades_procesadas
FROM PROFESIONAL p
JOIN DONACION dn ON p.codigo = dn.codigo_profesional
JOIN UNIDAD u ON dn.id_donacion = u.id_donacion
GROUP BY p.nombre
ORDER BY unidades_procesadas DESC LIMIT 1;

-- Verificación de redundancia desnormalizada
SELECT * FROM v_control_despachadas;
