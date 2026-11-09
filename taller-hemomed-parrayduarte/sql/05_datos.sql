-- =========================================================================
-- SCRIPT 05: DATOS DE PRUEBA (SEED DATA)
-- =========================================================================

INSERT INTO ESTADO (id_estado, nombre_estado) VALUES 
(1, 'disponible'), (2, 'reservada'), (3, 'despachada'), (4, 'descartada'), (5, 'vencida');

INSERT INTO TIPO_COMPONENTE (id_tipo, nombre, dias_vigencia, temperatura_conservacion) VALUES
(1, 'Glóbulos rojos', 42, 4.00),
(2, 'Plasma', 365, -18.00),
(3, 'Plaquetas', 5, 22.00);

INSERT INTO INSTITUCION (NIT, nombre, ciudad, telefono) VALUES
('900123456-1', 'Hospital San Vicente Fundación', 'Medellín', '4441333'),
('890987654-2', 'Clínica Las Américas', 'Medellín', '3421000'),
('800111222-3', 'Hospital General de Medellín', 'Medellín', '3847300');

INSERT INTO PROFESIONAL (codigo, nombre, cargo, fecha_ingreso) VALUES
('P001', 'Dra. Martha Gómez', 'Directora Médica', '2015-01-10'),
('P002', 'Dr. Carlos Ruiz', 'Médico Supervisor', '2018-05-15'),
('P003', 'Ana María Pérez', 'Enfermera Jefe', '2021-03-20'),
('P004', 'Juan Esteban Gil', 'Bacteriólogo', '2023-07-01');

UPDATE PROFESIONAL SET codigo_jefe = 'P001' WHERE codigo IN ('P002');
UPDATE PROFESIONAL SET codigo_jefe = 'P002' WHERE codigo IN ('P003', 'P004');

INSERT INTO DONANTE (documento, nombre, fecha_nacimiento, grupo_sanguineo, rh, telefono) VALUES
('1010123456', 'Andrés Felipe Restrepo', '1995-05-12', 'O', '+', '3001112233'),
('1020345678', 'Lucía Henao Cardona', '1988-11-20', 'A', '-', '3102223344'),
('1030567890', 'Mateo Morales Londoño', '2000-02-15', 'B', '+', '3203334455'),
('1040789012', 'Sofía Arango Mesa', '1992-08-30', 'AB', '+', '3014445566'),
('1050901234', 'David Alejandro Ríos', '1975-12-05', 'O', '-', '3115556677'),
('1060123456', 'Valeria Cárdenas Gil', '1998-04-10', 'A', '+', '3126667788'),
('1070234567', 'Esteban Jaramillo', '2002-09-25', 'B', '-', '3137778899'),
('1080345678', 'Camila Andrea Osorio', '1990-06-18', 'AB', '-', '3148889900');

INSERT INTO DONACION (id_donacion, fecha_hora, volumen_ml, documento, codigo_profesional) VALUES
(1, '2026-01-10 08:30:00', 450.00, '1010123456', 'P003'),
(2, '2026-02-15 09:15:00', 480.00, '1020345678', 'P003'),
(3, '2026-03-20 10:00:00', 500.00, '1030567890', 'P004');

CALL sp_fraccionar(1);
CALL sp_fraccionar(2);
CALL sp_fraccionar(3);

INSERT INTO SOLICITUD (numero_solicitud, fecha, estado_solicitud, NIT_institucion) VALUES
(1, '2026-09-01', 'pendiente', '900123456-1'),
(2, '2026-09-05', 'pendiente', '890987654-2');

INSERT INTO DETALLE_SOLICITUD (numero_solicitud, id_tipo, cantidad_solicitada, cantidad_despachada) VALUES
(1, 1, 2, 0),
(1, 3, 4, 0),
(2, 2, 1, 0);
