-- =========================================================================
-- SCRIPT 04: PROCEDIMIENTOS Y FUNCIÓN
-- =========================================================================

CREATE OR REPLACE PROCEDURE sp_registrar_donacion(p_json_input JSON)
LANGUAGE plpgsql AS $$
DECLARE
    v_doc VARCHAR; v_vol NUMERIC; v_prof VARCHAR;
BEGIN
    v_doc := p_json_input->>'documento';
    v_vol := (p_json_input->>'volumen_ml')::NUMERIC;
    v_prof := p_json_input->>'codigo_profesional';

    INSERT INTO DONACION (volumen_ml, documento, codigo_profesional)
    VALUES (v_vol, v_doc, v_prof);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_fraccionar(p_id_donacion INT)
LANGUAGE plpgsql AS $$
DECLARE
    r_tipo RECORD;
    v_estado_disp INT;
BEGIN
    SELECT id_estado INTO v_estado_disp FROM ESTADO WHERE nombre_estado = 'disponible';
    
    FOR r_tipo IN SELECT id_tipo FROM TIPO_COMPONENTE LOOP
        INSERT INTO UNIDAD (id_donacion, id_tipo, fecha_produccion, id_estado)
        VALUES (p_id_donacion, r_tipo.id_tipo, CURRENT_DATE, v_estado_disp);
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_atender_solicitud(p_solicitud INT)
LANGUAGE plpgsql AS $$
DECLARE
    r_det RECORD;
    v_estado_disp INT;
    v_estado_desp INT;
    v_uni RECORD;
    v_cant_por_asignar INT;
BEGIN
    SELECT id_estado INTO v_estado_disp FROM ESTADO WHERE nombre_estado = 'disponible';
    SELECT id_estado INTO v_estado_desp FROM ESTADO WHERE nombre_estado = 'despachada';

    FOR r_det IN SELECT id_tipo, cantidad_solicitada, cantidad_despachada FROM DETALLE_SOLICITUD WHERE numero_solicitud = p_solicitud LOOP
        v_cant_por_asignar := r_det.cantidad_solicitada - r_det.cantidad_despachada;
        
        FOR v_uni IN SELECT numero_unidad FROM UNIDAD WHERE id_tipo = r_det.id_tipo AND id_estado = v_estado_disp ORDER BY fecha_vencimiento ASC LIMIT v_cant_por_asignar LOOP
            UPDATE UNIDAD SET id_estado = v_estado_desp WHERE numero_unidad = v_uni.numero_unidad;
        END LOOP;
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_resumen_stock(INOUT p_total_disponibles INT, INOUT p_total_vencidas INT)
LANGUAGE plpgsql AS $$
BEGIN
    SELECT COUNT(*) INTO p_total_disponibles FROM UNIDAD u JOIN ESTADO e ON u.id_estado = e.id_estado WHERE e.nombre_estado = 'disponible';
    SELECT COUNT(*) INTO p_total_vencidas FROM UNIDAD u JOIN ESTADO e ON u.id_estado = e.id_estado WHERE e.nombre_estado = 'vencida' OR u.fecha_vencimiento < CURRENT_DATE;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_descartar_vencidos()
LANGUAGE plpgsql AS $$
DECLARE
    v_estado_vencida INT;
    v_estado_disp INT;
BEGIN
    SELECT id_estado INTO v_estado_vencida FROM ESTADO WHERE nombre_estado = 'vencida';
    SELECT id_estado INTO v_estado_disp FROM ESTADO WHERE nombre_estado = 'disponible';

    UPDATE UNIDAD 
    SET id_estado = v_estado_vencida 
    WHERE fecha_vencimiento < CURRENT_DATE AND id_estado = v_estado_disp;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_recalcular_despachadas()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE DETALLE_SOLICITUD ds
    SET cantidad_despachada = (
        SELECT COUNT(*) 
        FROM UNIDAD u 
        JOIN ESTADO e ON u.id_estado = e.id_estado 
        WHERE u.id_tipo = ds.id_tipo AND e.nombre_estado = 'despachada'
    );
END;
$$;

CREATE OR REPLACE FUNCTION fn_dias_para_vencer(p_numero_unidad INT)
RETURNS INT AS $$
DECLARE
    v_dias INT;
BEGIN
    SELECT (fecha_vencimiento - CURRENT_DATE) INTO v_dias FROM UNIDAD WHERE numero_unidad = p_numero_unidad;
    RETURN v_dias;
END;
$$ LANGUAGE plpgsql;
