#!/bin/bash
# User data para Amazon Linux 2023 — Actividad 4.1
# Instala y arranca, sin intervención manual, la aplicación de
# Encuestas en Vivo, en el puerto 80.

dnf install -y python3-pip
pip3 install flask requests

mkdir -p /opt/encuestas

cat > /opt/encuestas/app.py << 'EOF'
"""Encuestas en Vivo — aplicación mínima para la Actividad 4.1."""

import socket
import time

import requests
from flask import Flask

app = Flask(__name__)

ENCUESTA = {
    "pregunta": "¿Qué charla te ha gustado más del evento?",
    "opciones": [
        {"texto": "Cloud nativo desde cero", "votos": 142},
        {"texto": "Seguridad en producción", "votos": 98},
        {"texto": "IA aplicada al día a día", "votos": 210},
        {"texto": "Bases de datos distribuidas", "votos": 67},
    ],
}


def obtener_id_instancia():
    try:
        token = requests.put(
            "http://169.254.169.254/latest/api/token",
            headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"},
            timeout=1,
        ).text
        return requests.get(
            "http://169.254.169.254/latest/meta-data/instance-id",
            headers={"X-aws-ec2-metadata-token": token},
            timeout=1,
        ).text
    except Exception:
        return socket.gethostname()


@app.route("/")
def index():
    instancia = obtener_id_instancia()
    total_votos = sum(opcion["votos"] for opcion in ENCUESTA["opciones"])
    filas = ""
    for opcion in ENCUESTA["opciones"]:
        porcentaje = round(100 * opcion["votos"] / total_votos, 1)
        filas += (
            f"<tr><td>{opcion['texto']}</td>"
            f"<td>{opcion['votos']}</td><td>{porcentaje}%</td></tr>"
        )

    return f"""
    <html>
    <head><title>Encuestas en Vivo</title></head>
    <body style="font-family: sans-serif; max-width: 640px; margin: 40px auto;">
        <h1>Encuestas en Vivo</h1>
        <h2>{ENCUESTA['pregunta']}</h2>
        <table border="1" cellpadding="8" style="border-collapse: collapse; width: 100%;">
            <tr><th>Opción</th><th>Votos</th><th>%</th></tr>
            {filas}
        </table>
        <p>Total de votos: {total_votos}</p>
        <p style="margin-top: 40px; color: #666;">
            Respondido por la instancia: <strong>{instancia}</strong>
        </p>
    </body>
    </html>
    """


@app.route("/salud")
def salud():
    return "OK", 200


@app.route("/carga")
def carga():
    fin = time.time() + 5
    while time.time() < fin:
        pass
    return "Carga generada", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

cat > /etc/systemd/system/encuestas.service << 'EOF'
[Unit]
Description=Encuestas en Vivo
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/encuestas/app.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now encuestas
