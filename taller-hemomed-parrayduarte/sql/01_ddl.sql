-- =========================================================================
-- TALLER INTEGRADOR HEMOMED - SCRIPT 01: DDL (Tablas e Índices)
-- Motor: PostgreSQL
-- =========================================================================

CREATE TABLE DONANTE (
    documento VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    grupo_sanguineo VARCHAR(2) NOT NULL CHECK (grupo_sanguineo IN ('O', 'A', 'B', 'AB')),
    rh VARCHAR(1) NOT NULL CHECK (rh IN ('+', '-')),
    telefono VARCHAR(20)
);

CREATE TABLE PROFESIONAL (
    codigo VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cargo VARCHAR(100) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    codigo_jefe VARCHAR(20) REFERENCES PROFESIONAL(codigo) ON DELETE SET NULL
);

CREATE TABLE TIPO_COMPONENTE (
    id_tipo SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    dias_vigencia INTEGER NOT NULL CHECK (dias_vigencia > 0),
    temperatura_conservacion NUMERIC(5,2) NOT NULL
);

CREATE TABLE ESTADO (
    id_estado SERIAL PRIMARY KEY,
    nombre_estado VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE INSTITUCION (
    NIT VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    telefono VARCHAR(20)
);

CREATE TABLE DONACION (
    id_donacion SERIAL PRIMARY KEY,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    volumen_ml NUMERIC(8,2) NOT NULL CHECK (volumen_ml > 0),
    documento VARCHAR(20) NOT NULL REFERENCES DONANTE(documento) ON DELETE RESTRICT,
    codigo_profesional VARCHAR(20) NOT NULL REFERENCES PROFESIONAL(codigo) ON DELETE RESTRICT
);

CREATE TABLE SOLICITUD (
    numero_solicitud SERIAL PRIMARY KEY,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    estado_solicitud VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    NIT_institucion VARCHAR(20) NOT NULL REFERENCES INSTITUCION(NIT) ON DELETE RESTRICT
);

CREATE TABLE DETALLE_SOLICITUD (
    numero_solicitud INTEGER REFERENCES SOLICITUD(numero_solicitud) ON DELETE CASCADE,
    id_tipo INTEGER REFERENCES TIPO_COMPONENTE(id_tipo) ON DELETE RESTRICT,
    cantidad_solicitada INTEGER NOT NULL CHECK (cantidad_solicitada > 0),
    cantidad_despachada INTEGER NOT NULL DEFAULT 0 CHECK (cantidad_despachada >= 0),
    PRIMARY KEY (numero_solicitud, id_tipo)
);

CREATE TABLE UNIDAD (
    numero_unidad SERIAL PRIMARY KEY,
    id_donacion INTEGER NOT NULL REFERENCES DONACION(id_donacion) ON DELETE CASCADE,
    id_tipo INTEGER NOT NULL REFERENCES TIPO_COMPONENTE(id_tipo) ON DELETE RESTRICT,
    fecha_produccion DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_vencimiento DATE NOT NULL,
    id_estado INTEGER NOT NULL REFERENCES ESTADO(id_estado) ON DELETE RESTRICT
);

CREATE TABLE HISTORIAL_ESTADO (
    id_historial SERIAL PRIMARY KEY,
    numero_unidad INTEGER NOT NULL REFERENCES UNIDAD(numero_unidad) ON DELETE CASCADE,
    id_estado INTEGER NOT NULL REFERENCES ESTADO(id_estado) ON DELETE RESTRICT,
    codigo_profesional VARCHAR(20) NOT NULL REFERENCES PROFESIONAL(codigo) ON DELETE RESTRICT,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Índices optimizadores
CREATE INDEX idx_donacion_documento ON DONACION(documento);
CREATE INDEX idx_donacion_profesional ON DONACION(codigo_profesional);
CREATE INDEX idx_unidad_donacion ON UNIDAD(id_donacion);
CREATE INDEX idx_unidad_tipo ON UNIDAD(id_tipo);
CREATE INDEX idx_unidad_vencimiento ON UNIDAD(fecha_vencimiento);
CREATE INDEX idx_historial_unidad ON HISTORIAL_ESTADO(numero_unidad);
