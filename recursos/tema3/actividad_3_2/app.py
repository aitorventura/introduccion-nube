"""
Actividad 3.2 — aplicación mínima de la biblioteca de barrio.

Se conecta a PostgreSQL usando credenciales que llegan por variables de
entorno (DB_HOST, DB_NAME, DB_USER, DB_PASSWORD) — nunca escritas en este
fichero. En el escenario de la actividad, esas variables las resuelve el
script de arranque (arranque-app.sh) leyendo el secreto de Secrets Manager
en el momento de lanzar la instancia.
"""

import os

import psycopg2
from flask import Flask

app = Flask(__name__)


def get_connection():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        connect_timeout=5,
    )


@app.route("/")
def listar_libros():
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT titulo, autor, disponible FROM libros ORDER BY titulo;")
            filas = cur.fetchall()
    finally:
        conn.close()

    filas_html = "".join(
        f"<tr><td>{titulo}</td><td>{autor}</td><td>{'Sí' if disponible else 'No'}</td></tr>"
        for titulo, autor, disponible in filas
    )

    return f"""
    <html>
      <head><title>Biblioteca de barrio</title></head>
      <body>
        <h1>Catálogo de la biblioteca</h1>
        <table border="1" cellpadding="6">
          <tr><th>Título</th><th>Autor</th><th>Disponible</th></tr>
          {filas_html}
        </table>
      </body>
    </html>
    """


@app.route("/salud")
def salud():
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT 1;")
            cur.fetchone()
        conn.close()
        return "OK", 200
    except Exception as exc:  # noqa: BLE001 — queremos que /salud nunca reviente sin explicar por qué
        return f"ERROR: {exc}", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
