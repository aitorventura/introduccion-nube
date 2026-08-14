-- Esquema de la Actividad 3.3 — aplicación de reseñas de restaurantes locales.
-- Ejecútalo contra la base de datos PostgreSQL creada en el Paso 1, por ejemplo:
--   psql -h <endpoint-rds> -U <usuario> -d <nombre-bd> -f schema.sql

CREATE TABLE IF NOT EXISTS resenas (
    id           SERIAL PRIMARY KEY,
    restaurante  VARCHAR(150) NOT NULL,
    comentario   TEXT NOT NULL,
    puntuacion   SMALLINT NOT NULL CHECK (puntuacion BETWEEN 1 AND 5),
    fecha        DATE NOT NULL DEFAULT CURRENT_DATE
);

INSERT INTO resenas (restaurante, comentario, puntuacion, fecha) VALUES
    ('Taberna El Rincón',    'Raciones generosas y trato cercano, repetiremos seguro.',        5, '2026-05-02'),
    ('Sushi Kaze',           'Buen pescado pero el servicio fue muy lento un sábado noche.',    3, '2026-05-10'),
    ('Pizzería Napoli',      'La mejor masa de la zona, precio un poco alto para el barrio.',   4, '2026-05-15'),
    ('Café Luna',            'Ambiente agradable para desayunar, café flojo.',                  3, '2026-05-20'),
    ('Asador Los Arcos',     'Carne excelente, reserva imprescindible los fines de semana.',    5, '2026-05-28');
