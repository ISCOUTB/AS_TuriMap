CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;          -- Coordenadas geoespaciales
CREATE EXTENSION IF NOT EXISTS pg_trgm;          -- Búsqueda de texto por trigrams

-- =============================================================
-- 1. USUARIOS
-- =============================================================
CREATE TABLE usuarios (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre          VARCHAR(120) NOT NULL,
    email           VARCHAR(255) UNIQUE NOT NULL,
    tipo            VARCHAR(20)  NOT NULL DEFAULT 'visitante'
                        CHECK (tipo IN ('estudiante','docente','visitante','admin')),
    institucion     VARCHAR(200),
    idioma          CHAR(2)      NOT NULL DEFAULT 'es'
                        CHECK (idioma IN ('es','en')),
    avatar_url      TEXT,
    activo          BOOLEAN      NOT NULL DEFAULT TRUE,
    creado_en       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    actualizado_en  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  usuarios             IS 'Usuarios registrados de la app TuriMap';
COMMENT ON COLUMN usuarios.tipo        IS 'Rol del usuario: estudiante, docente, visitante o admin';

-- ─────────────────────────────────────────────────────────────
-- 2. CATEGORÍAS DE PUNTOS DE RUTA
-- ─────────────────────────────────────────────────────────────
CREATE TABLE categorias_punto (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(80)  NOT NULL UNIQUE,
    icono_url   TEXT,
    color_hex   CHAR(7)      NOT NULL DEFAULT '#006B75'
);

INSERT INTO categorias_punto (nombre, icono_url, color_hex) VALUES
    ('Militar',            NULL, '#8B0000'),
    ('Religioso',          NULL, '#DAA520'),
    ('Histórico-Civil',    NULL, '#006B75'),
    ('Patrimonio UNESCO',  NULL, '#1A3C6E'),
    ('Comercial',          NULL, '#4A7C59');

-- ─────────────────────────────────────────────────────────────
-- 3. PUNTOS DE RUTA (lugares turísticos)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE puntos_ruta (
    id                  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo              VARCHAR(20) UNIQUE NOT NULL,   -- 'exp_1', 'exp_2'…
    nombre              VARCHAR(200) NOT NULL,
    descripcion_corta   TEXT         NOT NULL,
    descripcion_larga   TEXT,
    latitud             DOUBLE PRECISION NOT NULL,
    longitud            DOUBLE PRECISION NOT NULL,
    geolocalizacion     GEOGRAPHY(POINT, 4326)
                            GENERATED ALWAYS AS (
                                ST_SetSRID(ST_MakePoint(longitud, latitud), 4326)::geography
                            ) STORED,
    orden               SMALLINT     NOT NULL,
    categoria_id        INT          REFERENCES categorias_punto(id),
    imagen_principal_url TEXT,
    audio_url           TEXT,
    epoca_historica     VARCHAR(100),          -- 'Siglo XVII', 'Colonial'…
    anio_construccion   INT,
    patrimonio_unesco   BOOLEAN      NOT NULL DEFAULT FALSE,
    activo              BOOLEAN      NOT NULL DEFAULT TRUE,
    creado_en           TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Índice espacial para consultas "puntos cercanos"
CREATE INDEX idx_puntos_ruta_geo ON puntos_ruta USING GIST (geolocalizacion);
CREATE INDEX idx_puntos_ruta_orden ON puntos_ruta (orden);

-- ── SEED: 5 puntos del recorrido (datos del app actual) ──────
INSERT INTO puntos_ruta
    (codigo, nombre, descripcion_corta, descripcion_larga,
     latitud, longitud, orden, categoria_id,
     epoca_historica, anio_construccion, patrimonio_unesco)
VALUES
(
    'exp_1',
    'Puerta del Reloj',
    'Entrada principal a la ciudad amurallada. Construida en el siglo XVII, era el acceso al centro comercial.',
    'La Puerta del Reloj, originalmente llamada Boca del Puente, fue el principal acceso a '
    'la ciudad amurallada desde el exterior. Construida en el siglo XVII, comunicaba la ciudad '
    'con el barrio de Getsemaní a través de un puente levadizo. El reloj que le da su nombre '
    'actual fue añadido en 1888. Es el símbolo más reconocible de Cartagena de Indias y '
    'declarada Patrimonio de la Humanidad por la UNESCO en 1984.',
    10.4238, -75.5501, 1, 3,
    'Siglo XVII - Colonial', 1602, TRUE
),
(
    'exp_2',
    'Plaza de los Coches',
    'Antiguo mercado de esclavos, hoy plaza central rodeada de portales y el busto de Pedro de Heredia.',
    'La Plaza de los Coches fue durante la colonia el sitio donde se realizaban las transacciones '
    'de esclavos traídos de África. Su nombre actual proviene de los carruajes que esperaban '
    'pasajeros bajo sus portales en el siglo XIX. Hoy es un espacio cultural rodeado de '
    'restaurantes y tiendas típicas. Preside la plaza la estatua del fundador de Cartagena, '
    'Pedro de Heredia, erigida en 1533.',
    10.4234, -75.5493, 2, 3,
    'Siglo XVI - Colonial', 1533, TRUE
),
(
    'exp_3',
    'Catedral de Cartagena',
    'Iniciada en 1575, es uno de los templos más antiguos de América del Sur. Patrimonio arquitectónico.',
    'La Catedral Metropolitana de Santa Catalina de Alejandría es la iglesia madre de la '
    'Arquidiócesis de Cartagena. Su construcción comenzó en 1575 y fue parcialmente destruida '
    'por el corsario Francis Drake en 1586. Reconstruida y ampliada en varias etapas, '
    'su torre campanario es uno de los hitos visuales del centro histórico. En su interior '
    'reposan los restos del prócer de la independencia José Fernández Madrid.',
    10.4228, -75.5483, 3, 2,
    'Siglo XVI - Colonial', 1575, TRUE
),
(
    'exp_4',
    'Plaza de Bolívar',
    'Corazón histórico de Cartagena. Rodeada por la Catedral, el Palacio de la Inquisición y el Museo del Oro.',
    'La Plaza de Bolívar, antes llamada Plaza Mayor, es el corazón cívico e histórico de '
    'Cartagena. Está rodeada por edificios de gran valor patrimonial: la Catedral, el '
    'Palacio de la Inquisición (hoy Museo Histórico), el Palacio Municipal y el Museo del '
    'Oro Zenú del Banco de la República. En el centro se erige una estatua ecuestre del '
    'Libertador Simón Bolívar, donada por Venezuela en 1896.',
    10.4225, -75.5476, 4, 3,
    'Siglo XVI - Colonial', 1533, TRUE
),
(
    'exp_5',
    'Castillo San Felipe de Barajas',
    'Fortaleza militar más grande construida por los españoles en América. Declarada Patrimonio UNESCO.',
    'El Castillo San Felipe de Barajas es la fortificación militar española más grande '
    'construida en América. Ubicado sobre la colina de San Lázaro, fue iniciado en 1536 '
    'y ampliado significativamente por el ingeniero Antonio de Arévalo entre 1762 y 1769. '
    'Su sistema de túneles subterráneos permitía la comunicación entre distintos puntos '
    'de la fortaleza y facilitaba la distribución de alimentos, agua y municiones. '
    'Resistió exitosamente el ataque del almirante inglés Edward Vernon en 1741, '
    'la mayor batalla naval del siglo XVIII. Declarado Patrimonio de la Humanidad por la UNESCO en 1984.',
    10.4214, -75.5401, 5, 1,
    'Siglo XVI - Siglo XVIII', 1536, TRUE
);

-- =============================================================
-- 4. EXPERIENCIAS DE REALIDAD MIXTA (MR)
-- =============================================================
CREATE TABLE experiencias_mr (
    id                  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    punto_ruta_id       UUID        NOT NULL REFERENCES puntos_ruta(id) ON DELETE CASCADE,
    titulo              VARCHAR(200) NOT NULL,
    descripcion         TEXT,
    tipo                VARCHAR(30) NOT NULL
                            CHECK (tipo IN ('ar_overlay','3d_model','video_360',
                                            'imagen_historica','audio_guiado','quiz')),
    -- Contenido
    asset_url           TEXT,                  -- URL del modelo 3D / video / imagen
    asset_tipo          VARCHAR(20),           -- 'glb','usdz','mp4','jpg','mp3'
    thumbnail_url       TEXT,
    duracion_segundos   INT,
    -- AR específico
    marcador_tipo       VARCHAR(20)            -- 'gps','imagen','qr'
                            CHECK (marcador_tipo IN ('gps','imagen','qr')),
    marcador_url        TEXT,                  -- imagen del marcador si aplica
    radio_activacion_m  FLOAT DEFAULT 50.0,   -- metros desde el punto para activarse
    -- Estado
    disponible          BOOLEAN NOT NULL DEFAULT FALSE,
    version             VARCHAR(10) DEFAULT '1.0',
    creado_en           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON COLUMN experiencias_mr.tipo IS 'Tipo de experiencia: AR overlay, modelo 3D, video 360, imagen histórica, audio guiado, quiz';
COMMENT ON COLUMN experiencias_mr.radio_activacion_m IS 'Radio en metros dentro del cual la experiencia se activa automáticamente';

-- SEED: una experiencia MR por punto (placeholder - "Próximamente")
INSERT INTO experiencias_mr
    (punto_ruta_id, titulo, descripcion, tipo, disponible, version)
SELECT
    pr.id,
    'Experiencia AR: ' || pr.nombre,
    'Superposición histórica con fotografías de la fototeca UTB del siglo XIX y principios del XX.',
    'ar_overlay',
    FALSE,
    '0.1'
FROM puntos_ruta pr;

-- =============================================================
-- 5. FOTOTECA UTB
-- =============================================================
CREATE TABLE fototeca (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    titulo          VARCHAR(300) NOT NULL,
    descripcion     TEXT,
    autor           VARCHAR(200),
    fuente          VARCHAR(300),              -- 'Fototeca UTB', 'Archivo Histórico Cartagena'
    fecha_aprox     DATE,
    anio_aprox      INT,
    decada_aprox    CHAR(6),                  -- '1920s', '1940s'
    url_imagen      TEXT        NOT NULL,
    url_thumbnail   TEXT,
    formato         VARCHAR(10),              -- 'jpg','png','tif'
    ancho_px        INT,
    alto_px         INT,
    licencia        VARCHAR(50) DEFAULT 'UTB-educativo',
    tags            TEXT[],                   -- ['colonial','murallas','siglo XIX']
    punto_ruta_id   UUID        REFERENCES puntos_ruta(id),   -- lugar retratado
    creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_fototeca_punto ON fototeca (punto_ruta_id);
CREATE INDEX idx_fototeca_anio  ON fototeca (anio_aprox);
CREATE INDEX idx_fototeca_tags  ON fototeca USING GIN (tags);

-- SEED: fotografías históricas de ejemplo por punto
INSERT INTO fototeca
    (titulo, descripcion, fuente, anio_aprox, decada_aprox,
     url_imagen, url_thumbnail, licencia, tags, punto_ruta_id)
SELECT
    'Vista histórica: ' || pr.nombre,
    'Fotografía histórica del lugar a inicios del siglo XX. Colección Fototeca UTB.',
    'Fototeca UTB - Universidad Tecnológica de Bolívar',
    1920,
    '1920s',
    'https://fototeca.utb.edu.co/placeholder/' || pr.codigo || '_01.jpg',
    'https://fototeca.utb.edu.co/thumbnails/' || pr.codigo || '_01_thumb.jpg',
    'UTB-educativo',
    ARRAY['histórico', 'colonial', 'cartagena'],
    pr.id
FROM puntos_ruta pr;

-- =============================================================
-- 6. RUTAS TEMÁTICAS (colecciones de puntos)
-- =============================================================
CREATE TABLE rutas_tematicas (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre          VARCHAR(200) NOT NULL,
    descripcion     TEXT,
    dificultad      VARCHAR(20)  CHECK (dificultad IN ('facil','moderada','dificil')),
    distancia_km    FLOAT,
    duracion_min    INT,
    imagen_url      TEXT,
    activa          BOOLEAN      NOT NULL DEFAULT TRUE,
    creado_en       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE rutas_tematicas_puntos (
    ruta_id         UUID     NOT NULL REFERENCES rutas_tematicas(id) ON DELETE CASCADE,
    punto_id        UUID     NOT NULL REFERENCES puntos_ruta(id)     ON DELETE CASCADE,
    orden_en_ruta   SMALLINT NOT NULL,
    PRIMARY KEY (ruta_id, punto_id)
);

-- SEED: ruta principal del app
INSERT INTO rutas_tematicas (id, nombre, descripcion, dificultad, distancia_km, duracion_min)
VALUES (
    'a1b2c3d4-0000-0000-0000-000000000001',
    'Ruta Histórica Centro de Cartagena',
    'Recorrido por los 5 sitios más emblemáticos del centro histórico de Cartagena de Indias. '
    'Incluye experiencias de Realidad Mixta con contenido de la fototeca UTB.',
    'facil', 2.3, 90
);

INSERT INTO rutas_tematicas_puntos (ruta_id, punto_id, orden_en_ruta)
SELECT 'a1b2c3d4-0000-0000-0000-000000000001', pr.id, pr.orden
FROM puntos_ruta pr ORDER BY pr.orden;

-- =============================================================
-- 7. PROGRESO DEL USUARIO
-- =============================================================
CREATE TABLE progreso_usuario (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id      UUID        NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    punto_ruta_id   UUID        NOT NULL REFERENCES puntos_ruta(id),
    ruta_id         UUID        REFERENCES rutas_tematicas(id),
    visitado        BOOLEAN     NOT NULL DEFAULT FALSE,
    fecha_visita    TIMESTAMPTZ,
    mr_completado   BOOLEAN     NOT NULL DEFAULT FALSE,
    fecha_mr        TIMESTAMPTZ,
    puntos_xp       INT         NOT NULL DEFAULT 0,
    UNIQUE (usuario_id, punto_ruta_id)
);

CREATE INDEX idx_progreso_usuario ON progreso_usuario (usuario_id);

-- =============================================================
-- 8. SESIONES MR (telemetría para análisis UTB)
-- =============================================================
CREATE TABLE sesiones_mr (
    id                  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id          UUID        REFERENCES usuarios(id),
    experiencia_mr_id   UUID        NOT NULL REFERENCES experiencias_mr(id),
    inicio              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fin                 TIMESTAMPTZ,
    duracion_segundos   INT
                            GENERATED ALWAYS AS (
                                EXTRACT(EPOCH FROM (fin - inicio))::INT
                            ) STORED,
    completada          BOOLEAN     NOT NULL DEFAULT FALSE,
    lat_usuario         DOUBLE PRECISION,
    lon_usuario         DOUBLE PRECISION,
    dispositivo         VARCHAR(100),          -- 'Android 14 / Pixel 7'
    version_app         VARCHAR(10)
);

-- =============================================================
-- 9. CONTENIDO EDUCATIVO (narrativas para cada punto)
-- =============================================================
CREATE TABLE contenido_educativo (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    punto_ruta_id   UUID        NOT NULL REFERENCES puntos_ruta(id) ON DELETE CASCADE,
    idioma          CHAR(2)     NOT NULL DEFAULT 'es',
    nivel           VARCHAR(20) NOT NULL DEFAULT 'general'
                        CHECK (nivel IN ('infantil','general','universitario','experto')),
    titulo          VARCHAR(300) NOT NULL,
    cuerpo          TEXT         NOT NULL,
    fuentes         TEXT[],      -- ['Lemaitre (1983)','Archivo Histórico BNC']
    activo          BOOLEAN      NOT NULL DEFAULT TRUE,
    creado_en       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (punto_ruta_id, idioma, nivel)
);

-- SEED: contenido educativo nivel general en español
INSERT INTO contenido_educativo (punto_ruta_id, idioma, nivel, titulo, cuerpo, fuentes)
SELECT
    pr.id, 'es', 'general',
    'Historia de: ' || pr.nombre,
    pr.descripcion_larga,
    ARRAY['Fototeca UTB', 'Patrimonio Cultural de Cartagena']
FROM puntos_ruta pr;

-- =============================================================
-- 10. QUIZ / PREGUNTAS POR PUNTO
-- =============================================================
CREATE TABLE preguntas_quiz (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    punto_ruta_id   UUID        NOT NULL REFERENCES puntos_ruta(id) ON DELETE CASCADE,
    pregunta        TEXT         NOT NULL,
    opcion_a        VARCHAR(300) NOT NULL,
    opcion_b        VARCHAR(300) NOT NULL,
    opcion_c        VARCHAR(300),
    opcion_d        VARCHAR(300),
    respuesta_correcta CHAR(1)  NOT NULL CHECK (respuesta_correcta IN ('a','b','c','d')),
    explicacion     TEXT,
    puntos_xp       INT         NOT NULL DEFAULT 10,
    activa          BOOLEAN      NOT NULL DEFAULT TRUE
);

-- SEED: 1 pregunta por punto
INSERT INTO preguntas_quiz
    (punto_ruta_id, pregunta, opcion_a, opcion_b, opcion_c, opcion_d,
     respuesta_correcta, explicacion, puntos_xp)
VALUES
(
    (SELECT id FROM puntos_ruta WHERE codigo = 'exp_1'),
    '¿En qué siglo fue construida la Puerta del Reloj?',
    'Siglo XV', 'Siglo XVI', 'Siglo XVII', 'Siglo XVIII',
    'c',
    'La Puerta del Reloj fue construida en el siglo XVII como acceso principal a la ciudad amurallada.',
    10
),
(
    (SELECT id FROM puntos_ruta WHERE codigo = 'exp_2'),
    '¿Qué función tenía la Plaza de los Coches durante la colonia?',
    'Plaza de mercado de alimentos',
    'Mercado de esclavos',
    'Centro de gobierno',
    'Estadio de torneos',
    'b',
    'La Plaza de los Coches fue el principal mercado de esclavos de la ciudad colonial.',
    10
),
(
    (SELECT id FROM puntos_ruta WHERE codigo = 'exp_3'),
    '¿En qué año comenzó la construcción de la Catedral de Cartagena?',
    '1533', '1575', '1602', '1650',
    'b',
    'La construcción de la Catedral inició en 1575, aunque fue dañada por Drake en 1586.',
    10
),
(
    (SELECT id FROM puntos_ruta WHERE codigo = 'exp_4'),
    '¿Qué institución importante rodea la Plaza de Bolívar?',
    'Museo del Oro Zenú',
    'Castillo San Felipe',
    'Iglesia de San Pedro Claver',
    'Teatro Heredia',
    'a',
    'El Museo del Oro Zenú del Banco de la República se encuentra en la Plaza de Bolívar.',
    10
),
(
    (SELECT id FROM puntos_ruta WHERE codigo = 'exp_5'),
    '¿Contra quién resistió exitosamente el Castillo San Felipe en 1741?',
    'Francis Drake',
    'Edward Vernon',
    'Henry Morgan',
    'Walter Raleigh',
    'b',
    'El almirante inglés Edward Vernon atacó Cartagena en 1741 con la mayor flota del siglo XVIII y fue derrotado.',
    20
);

-- =============================================================
-- VISTAS ÚTILES
-- =============================================================

-- Vista completa del punto de ruta con su experiencia MR y categoría
CREATE VIEW v_puntos_completos AS
SELECT
    pr.id,
    pr.codigo,
    pr.nombre,
    pr.descripcion_corta,
    pr.descripcion_larga,
    pr.latitud,
    pr.longitud,
    pr.orden,
    pr.epoca_historica,
    pr.anio_construccion,
    pr.patrimonio_unesco,
    pr.imagen_principal_url,
    pr.audio_url,
    cp.nombre          AS categoria,
    cp.color_hex       AS categoria_color,
    mr.id              AS mr_id,
    mr.titulo          AS mr_titulo,
    mr.tipo            AS mr_tipo,
    mr.disponible      AS mr_disponible,
    mr.asset_url       AS mr_asset_url,
    mr.thumbnail_url   AS mr_thumbnail,
    mr.radio_activacion_m AS mr_radio_m,
    (SELECT COUNT(*) FROM fototeca f WHERE f.punto_ruta_id = pr.id) AS total_fotos
FROM puntos_ruta pr
LEFT JOIN categorias_punto  cp ON cp.id = pr.categoria_id
LEFT JOIN experiencias_mr   mr ON mr.punto_ruta_id = pr.id
WHERE pr.activo = TRUE
ORDER BY pr.orden;

-- Vista del progreso por usuario
CREATE VIEW v_progreso_ruta AS
SELECT
    u.id           AS usuario_id,
    u.nombre       AS usuario,
    rt.nombre      AS ruta,
    COUNT(pr.id)   AS total_puntos,
    COUNT(CASE WHEN pu.visitado    THEN 1 END) AS puntos_visitados,
    COUNT(CASE WHEN pu.mr_completado THEN 1 END) AS mr_completados,
    SUM(COALESCE(pu.puntos_xp, 0)) AS xp_total,
    ROUND(
        COUNT(CASE WHEN pu.visitado THEN 1 END)::numeric /
        NULLIF(COUNT(pr.id),0) * 100, 1
    ) AS pct_completado
FROM usuarios u
CROSS JOIN rutas_tematicas rt
JOIN rutas_tematicas_puntos rtp ON rtp.ruta_id = rt.id
JOIN puntos_ruta pr             ON pr.id = rtp.punto_id
LEFT JOIN progreso_usuario pu   ON pu.usuario_id = u.id
                                AND pu.punto_ruta_id = pr.id
GROUP BY u.id, u.nombre, rt.nombre;

-- =============================================================
-- FUNCIONES HELPER
-- =============================================================

-- Puntos cercanos a una coordenada GPS (para activar MR automáticamente)
CREATE OR REPLACE FUNCTION puntos_cercanos(
    p_lat   FLOAT,
    p_lng   FLOAT,
    p_radio INT DEFAULT 200    -- metros
)
RETURNS TABLE (
    id       UUID,
    codigo   VARCHAR,
    nombre   VARCHAR,
    distancia_m FLOAT,
    mr_disponible BOOLEAN
) LANGUAGE sql STABLE AS $$
    SELECT
        pr.id,
        pr.codigo,
        pr.nombre,
        ST_Distance(
            pr.geolocalizacion,
            ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
        ) AS distancia_m,
        COALESCE(mr.disponible, FALSE) AS mr_disponible
    FROM puntos_ruta pr
    LEFT JOIN experiencias_mr mr ON mr.punto_ruta_id = pr.id
    WHERE pr.activo = TRUE
      AND ST_DWithin(
            pr.geolocalizacion,
            ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
            p_radio
          )
    ORDER BY distancia_m;
$$;

-- Marcar punto como visitado y sumar XP
CREATE OR REPLACE FUNCTION registrar_visita(
    p_usuario_id    UUID,
    p_punto_id      UUID,
    p_mr_completado BOOLEAN DEFAULT FALSE
)
RETURNS progreso_usuario LANGUAGE plpgsql AS $$
DECLARE
    v_xp INT := 10;
    v_resultado progreso_usuario;
BEGIN
    IF p_mr_completado THEN v_xp := 25; END IF;

    INSERT INTO progreso_usuario
        (usuario_id, punto_ruta_id, visitado, fecha_visita,
         mr_completado, fecha_mr, puntos_xp)
    VALUES
        (p_usuario_id, p_punto_id, TRUE, NOW(),
         p_mr_completado,
         CASE WHEN p_mr_completado THEN NOW() END,
         v_xp)
    ON CONFLICT (usuario_id, punto_ruta_id) DO UPDATE
        SET visitado      = TRUE,
            fecha_visita  = COALESCE(progreso_usuario.fecha_visita, NOW()),
            mr_completado = progreso_usuario.mr_completado OR EXCLUDED.mr_completado,
            fecha_mr      = COALESCE(progreso_usuario.fecha_mr,
                                CASE WHEN p_mr_completado THEN NOW() END),
            puntos_xp     = GREATEST(progreso_usuario.puntos_xp, EXCLUDED.puntos_xp)
    RETURNING * INTO v_resultado;

    RETURN v_resultado;
END;
$$;

-- =============================================================
-- ÍNDICES ADICIONALES DE RENDIMIENTO
-- =============================================================
CREATE INDEX idx_sesiones_mr_usuario ON sesiones_mr (usuario_id);
CREATE INDEX idx_sesiones_mr_exp     ON sesiones_mr (experiencia_mr_id);
CREATE INDEX idx_contenido_punto     ON contenido_educativo (punto_ruta_id, idioma, nivel);

-- =============================================================
-- ROW LEVEL SECURITY (para Supabase)
-- =============================================================
ALTER TABLE usuarios           ENABLE ROW LEVEL SECURITY;
ALTER TABLE progreso_usuario   ENABLE ROW LEVEL SECURITY;
ALTER TABLE sesiones_mr        ENABLE ROW LEVEL SECURITY;

-- Usuarios solo ven su propio progreso
CREATE POLICY "usuario_ve_su_progreso"
    ON progreso_usuario FOR ALL
    USING (auth.uid() = usuario_id);

-- Usuarios solo ven sus propias sesiones
CREATE POLICY "usuario_ve_sus_sesiones"
    ON sesiones_mr FOR ALL
    USING (auth.uid() = usuario_id);

-- Tablas públicas (lectura para todos)
CREATE POLICY "lectura_publica_puntos"
    ON puntos_ruta FOR SELECT USING (activo = TRUE);

CREATE POLICY "lectura_publica_mr"
    ON experiencias_mr FOR SELECT USING (TRUE);

CREATE POLICY "lectura_publica_fototeca"
    ON fototeca FOR SELECT USING (TRUE);

CREATE POLICY "lectura_publica_contenido"
    ON contenido_educativo FOR SELECT USING (activo = TRUE);

CREATE POLICY "lectura_publica_quiz"
    ON preguntas_quiz FOR SELECT USING (activa = TRUE);

