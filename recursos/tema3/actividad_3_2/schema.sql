-- Esquema de la Actividad 3.2 — sistema de reservas de una biblioteca de barrio.
-- Ejecútalo contra la base de datos PostgreSQL creada en el Paso 1, por ejemplo:
--   psql -h <endpoint-rds> -U <usuario> -d <nombre-bd> -f schema.sql

CREATE TABLE IF NOT EXISTS libros (
    id          SERIAL PRIMARY KEY,
    titulo      VARCHAR(200) NOT NULL,
    autor       VARCHAR(150) NOT NULL,
    disponible  BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO libros (titulo, autor, disponible) VALUES
    ('Cien años de soledad',        'Gabriel García Márquez', TRUE),
    ('La sombra del viento',        'Carlos Ruiz Zafón',      FALSE),
    ('1984',                        'George Orwell',          TRUE),
    ('El nombre del viento',        'Patrick Rothfuss',       TRUE),
    ('Rayuela',                     'Julio Cortázar',         FALSE);
