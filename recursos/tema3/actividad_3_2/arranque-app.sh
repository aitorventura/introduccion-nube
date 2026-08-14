#!/bin/bash
# Script de user-data para la Actividad 3.2 — Amazon Linux 2023.
#
# Sustituye <nombre-secreto> por el nombre (o ARN) del secreto que RDS ha
# generado automáticamente en Secrets Manager para tu base de datos, y
# <nombre-bd> por el nombre de la base de datos que hayas creado.
#
# Pégalo tal cual en el campo "Datos de usuario" al lanzar la instancia:
# se ejecuta solo, una vez, en el primer arranque — no hace falta
# conectarse por SSH a configurar nada a mano.

set -euo pipefail

# 1. Dependencias del sistema: Python, pip y el cliente de PostgreSQL
dnf update -y
dnf install -y python3 python3-pip postgresql15 jq

# 2. Dependencias de la aplicación
pip3 install flask psycopg2-binary

# 3. Escribe la aplicación (embebida, sin depender de ningún repositorio externo)
mkdir -p /opt/biblioteca
cat > /opt/biblioteca/app.py << 'EOF'
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
    except Exception as exc:
        return f"ERROR: {exc}", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

# 4. Resuelve las credenciales desde Secrets Manager en tiempo de arranque
#    (nunca escritas a mano en ningún fichero del repositorio)
SECRETO_JSON=$(aws secretsmanager get-secret-value \
  --secret-id <nombre-secreto> \
  --query SecretString \
  --output text \
  --region "$(curl -s http://169.254.169.254/latest/meta-data/placement/region)")

export DB_HOST=$(echo "$SECRETO_JSON" | jq -r '.host')
export DB_USER=$(echo "$SECRETO_JSON" | jq -r '.username')
export DB_PASSWORD=$(echo "$SECRETO_JSON" | jq -r '.password')
export DB_NAME="<nombre-bd>"

# 5. Arranca la aplicación en el puerto 80
cd /opt/biblioteca
nohup python3 app.py > /var/log/biblioteca-app.log 2>&1 &
