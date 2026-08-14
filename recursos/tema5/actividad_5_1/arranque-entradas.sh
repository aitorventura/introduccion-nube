#!/bin/bash
# User data para Amazon Linux 2023 — Actividad 5.1
# Instala y arranca, sin intervención manual, la aplicación de Entradas,
# en el puerto 80.

dnf install -y python3-pip
pip3 install flask

mkdir -p /opt/entradas

cat > /opt/entradas/app.py << 'EOF'
"""Entradas — aplicación mínima para la Actividad 5.1."""

import logging
import random

from flask import Flask

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

CONCIERTOS = [
    {"artista": "Noches de Neón", "ciudad": "Madrid", "entradas_disponibles": 214},
    {"artista": "Los del Puerto", "ciudad": "Valencia", "entradas_disponibles": 0},
    {"artista": "Cristal Roto", "ciudad": "Sevilla", "entradas_disponibles": 58},
    {"artista": "Órbita Sur", "ciudad": "Bilbao", "entradas_disponibles": 132},
]


@app.route("/")
def index():
    filas = ""
    for concierto in CONCIERTOS:
        estado = "Agotado" if concierto["entradas_disponibles"] == 0 else "Disponible"
        filas += (
            f"<tr><td>{concierto['artista']}</td><td>{concierto['ciudad']}</td>"
            f"<td>{concierto['entradas_disponibles']}</td><td>{estado}</td></tr>"
        )

    return f"""
    <html>
    <head><title>Entradas</title></head>
    <body style="font-family: sans-serif; max-width: 640px; margin: 40px auto;">
        <h1>Entradas</h1>
        <table border="1" cellpadding="8" style="border-collapse: collapse; width: 100%;">
            <tr><th>Artista</th><th>Ciudad</th><th>Disponibles</th><th>Estado</th></tr>
            {filas}
        </table>
    </body>
    </html>
    """


@app.route("/salud")
def salud():
    return "OK", 200


@app.route("/comprar")
def comprar():
    if random.randint(1, 4) == 1:
        logging.error("Fallo al confirmar la compra: tiempo de espera agotado con la pasarela de pago")
        return "Error al procesar la compra", 500
    logging.info("Compra confirmada correctamente")
    return "Compra confirmada", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

cat > /etc/systemd/system/entradas.service << 'EOF'
[Unit]
Description=Entradas
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/entradas/app.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now entradas
