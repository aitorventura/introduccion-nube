#!/bin/bash
# Script de user-data para la Actividad 3.3 — Amazon Linux 2023.
#
# Sustituye <nombre-secreto> por el nombre (o ARN) del secreto que RDS ha
# generado automáticamente en Secrets Manager para tu base de datos, y
# <nombre-bd> por el nombre de la base de datos que hayas creado.
#
# Pégalo tal cual en el campo "Datos de usuario" al lanzar la instancia del
# backend: se ejecuta solo, una vez, en el primer arranque.

set -euo pipefail

# 1. Dependencias del sistema
dnf update -y
dnf install -y python3 python3-pip postgresql15 jq

# 2. Dependencias de la aplicación
pip3 install flask psycopg2-binary flask-cors

# 3. Escribe el backend (embebido, sin depender de ningún repositorio externo)
mkdir -p /opt/resenas
cat > /opt/resenas/app.py << 'EOF'
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
    except Exception as exc:
        return f"ERROR: {exc}", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

# 4. Resuelve las credenciales desde Secrets Manager en tiempo de arranque
SECRETO_JSON=$(aws secretsmanager get-secret-value \
  --secret-id <nombre-secreto> \
  --query SecretString \
  --output text \
  --region "$(curl -s http://169.254.169.254/latest/meta-data/placement/region)")

export DB_HOST=$(echo "$SECRETO_JSON" | jq -r '.host')
export DB_USER=$(echo "$SECRETO_JSON" | jq -r '.username')
export DB_PASSWORD=$(echo "$SECRETO_JSON" | jq -r '.password')
export DB_NAME="<nombre-bd>"

# 5. Arranca el backend en el puerto 80
cd /opt/resenas
nohup python3 app.py > /var/log/resenas-backend.log 2>&1 &
