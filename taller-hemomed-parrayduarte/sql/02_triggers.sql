-- =========================================================================
-- SCRIPT 02: DISPARADORES (TRIGGERS)
-- =========================================================================

-- Trigger 1: Validar donación
CREATE OR REPLACE FUNCTION fn_validar_donacion()
RETURNS TRIGGER AS $$
DECLARE
    v_fnac DATE;
    v_edad INT;
    v_ultima_fecha TIMESTAMP;
BEGIN
    SELECT fecha_nacimiento INTO v_fnac FROM DONANTE WHERE documento = NEW.documento;
    v_edad := EXTRACT(YEAR FROM AGE(NEW.fecha_hora, v_fnac));
    
    IF v_edad < 18 OR v_edad > 65 THEN
        RAISE EXCEPTION 'El donante debe tener entre 18 y 65 años. Edad actual: % años', v_edad;
    END IF;

    SELECT MAX(fecha_hora) INTO v_ultima_fecha FROM DONACION WHERE documento = NEW.documento;
    
    IF v_ultima_fecha IS NOT NULL AND (NEW.fecha_hora - v_ultima_fecha) < INTERVAL '56 days' THEN
        RAISE EXCEPTION 'No han transcurrido los 56 días obligatorios desde la última donación (Última: %).', v_ultima_fecha;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_01_validar_donacion
BEFORE INSERT ON DONACION
FOR EACH ROW EXECUTE FUNCTION fn_validar_donacion();

-- Trigger 2: Calcular fecha de vencimiento
CREATE OR REPLACE FUNCTION fn_calcular_vencimiento()
RETURNS TRIGGER AS $$
DECLARE
    v_dias INT;
BEGIN
    SELECT dias_vigencia INTO v_dias FROM TIPO_COMPONENTE WHERE id_tipo = NEW.id_tipo;
    NEW.fecha_vencimiento := NEW.fecha_produccion + v_dias;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_02_calcular_vencimiento
BEFORE INSERT OR UPDATE OF fecha_produccion, id_tipo ON UNIDAD
FOR EACH ROW EXECUTE FUNCTION fn_calcular_vencimiento();

-- Trigger 3: Histórico de cambios de estado
CREATE OR REPLACE FUNCTION fn_registrar_historial_estado()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') OR (OLD.id_estado IS DISTINCT FROM NEW.id_estado) THEN
        INSERT INTO HISTORIAL_ESTADO (numero_unidad, id_estado, codigo_profesional, fecha_hora)
        VALUES (NEW.numero_unidad, NEW.id_estado, COALESCE(current_setting('hemomed.current_prof', true), 'P001'), CURRENT_TIMESTAMP);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_03_historial_estado
AFTER INSERT OR UPDATE ON UNIDAD
FOR EACH ROW EXECUTE FUNCTION fn_registrar_historial_estado();

-- Trigger 4: Validar despacho
CREATE OR REPLACE FUNCTION fn_validar_despacho_unidad()
RETURNS TRIGGER AS $$
DECLARE
    v_nombre_estado VARCHAR;
BEGIN
    SELECT nombre_estado INTO v_nombre_estado FROM ESTADO WHERE id_estado = NEW.id_estado;
    
    IF v_nombre_estado = 'despachada' THEN
        IF NEW.fecha_vencimiento < CURRENT_DATE THEN
            RAISE EXCEPTION 'La unidad % venció el % y no se puede despachar.', NEW.numero_unidad, NEW.fecha_vencimiento;
        END IF;
        
        IF TG_OP = 'UPDATE' THEN
            DECLARE
                v_estado_viejo VARCHAR;
            BEGIN
                SELECT nombre_estado INTO v_estado_viejo FROM ESTADO WHERE id_estado = OLD.id_estado;
                IF v_estado_viejo IN ('despachada', 'descartada', 'vencida') THEN
                    RAISE EXCEPTION 'La unidad % ya se encontraba en estado "%" y no puede despacharse nuevamente.', NEW.numero_unidad, v_estado_viejo;
                END IF;
            END;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_04_validar_despacho
BEFORE UPDATE ON UNIDAD
FOR EACH ROW EXECUTE FUNCTION fn_validar_despacho_unidad();

-- Trigger 5: Mantener cantidad despachada
CREATE OR REPLACE FUNCTION fn_mantener_cantidad_despachada()
RETURNS TRIGGER AS $$
DECLARE
    v_estado_actual VARCHAR;
    v_estado_viejo VARCHAR;
BEGIN
    IF TG_OP = 'UPDATE' THEN
        SELECT nombre_estado INTO v_estado_actual FROM ESTADO WHERE id_estado = NEW.id_estado;
        SELECT nombre_estado INTO v_estado_viejo FROM ESTADO WHERE id_estado = OLD.id_estado;

        IF v_estado_viejo != 'despachada' AND v_estado_actual = 'despachada' THEN
            UPDATE DETALLE_SOLICITUD 
            SET cantidad_despachada = cantidad_despachada + 1
            WHERE id_tipo = NEW.id_tipo;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_05_actualizar_despachadas
AFTER UPDATE ON UNIDAD
FOR EACH ROW EXECUTE FUNCTION fn_mantener_cantidad_despachada();
