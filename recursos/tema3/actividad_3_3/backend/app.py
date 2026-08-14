"""
Actividad 3.3 — backend de la aplicación de reseñas de restaurantes locales.

Igual que en la Actividad 3.2, las credenciales de conexión llegan por
variables de entorno (DB_HOST, DB_NAME, DB_USER, DB_PASSWORD), resueltas en
el arranque desde Secrets Manager — nunca escritas en este fichero.

flask-cors es necesario porque el front vive en un bucket S3 (un origen) y
este backend vive en una instancia EC2 (otro origen distinto): sin CORS
habilitado, el navegador bloquearía las peticiones fetch() del front.
"""

import os

import psycopg2
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)


def get_connection():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        connect_timeout=5,
    )


def obtener_resenas():
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT restaurante, comentario, puntuacion, fecha "
                "FROM resenas ORDER BY fecha DESC;"
            )
            filas = cur.fetchall()
    finally:
        conn.close()
    return filas


@app.route("/")
def index():
    filas = obtener_resenas()
    filas_html = "".join(
        f"<tr><td>{restaurante}</td><td>{comentario}</td>"
        f"<td>{puntuacion}/5</td><td>{fecha}</td></tr>"
        for restaurante, comentario, puntuacion, fecha in filas
    )
    return f"""
    <html>
      <head><title>Reseñas de restaurantes locales</title></head>
      <body>
        <h1>Reseñas de restaurantes locales</h1>
        <table border="1" cellpadding="6">
          <tr><th>Restaurante</th><th>Comentario</th><th>Puntuación</th><th>Fecha</th></tr>
          {filas_html}
        </table>
      </body>
    </html>
    """


@app.route("/api/resenas")
def api_resenas():
    filas = obtener_resenas()
    resultado = [
        {
            "restaurante": restaurante,
            "comentario": comentario,
            "puntuacion": puntuacion,
            "fecha": fecha.isoformat(),
        }
        for restaurante, comentario, puntuacion, fecha in filas
    ]
    return jsonify(resultado)


@app.route("/salud")
def salud():
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT 1;")
            cur.fetchone()
        conn.close()
        return "OK", 200
    except Exception as exc:  # noqa: BLE001
        return f"ERROR: {exc}", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
