#!/bin/bash
# User data para Amazon Linux 2023 — Actividad 5.2
# Instala y arranca, sin intervención manual, la aplicación de Inventario,
# en el puerto 80. Sustituye <tu-bucket-de-inventario> y el valor de
# DB_PASSWORD por los tuyos antes de usar este script (o inyéctalos de otra
# forma, por ejemplo desde Secrets Manager en un despliegue real).

dnf install -y python3-pip
pip3 install flask boto3

mkdir -p /opt/inventario

cat > /opt/inventario/app.py << 'EOF'
"""Inventario — aplicación mínima para la Actividad 5.2."""

import os

import boto3
from botocore.exceptions import ClientError
from flask import Flask

app = Flask(__name__)

BUCKET_INVENTARIO = os.environ.get("BUCKET_INVENTARIO", "<tu-bucket-de-inventario>")

s3 = boto3.client("s3")


@app.route("/")
def index():
    try:
        respuesta = s3.list_objects_v2(Bucket=BUCKET_INVENTARIO)
        objetos = respuesta.get("Contents", [])
    except ClientError as error:
        return f"<h1>Inventario</h1><p>Error al listar el bucket: {error}</p>", 500

    fichas = ""
    for objeto in objetos:
        tamano_kb = round(objeto["Size"] / 1024, 1)
        fichas += (
            f"<div style='border:1px solid #ccc; padding:10px; margin:8px 0;'>"
            f"<strong>{objeto['Key']}</strong><br>"
            f"Tamaño: {tamano_kb} KB<br>"
            f"Última modificación: {objeto['LastModified']}"
            f"</div>"
        )

    if not fichas:
        fichas = "<p>El bucket no tiene objetos todavía.</p>"

    return f"""
    <html>
    <head><title>Inventario</title></head>
    <body style="font-family: sans-serif; max-width: 640px; margin: 40px auto;">
        <h1>Inventario del almacén</h1>
        <p>Bucket: {BUCKET_INVENTARIO}</p>
        {fichas}
    </body>
    </html>
    """


@app.route("/salud")
def salud():
    return "OK", 200


@app.route("/estado-bd")
def estado_bd():
    credencial = os.environ.get("DB_PASSWORD")
    if credencial:
        return "La instancia tiene la credencial de base de datos disponible", 200
    return "No hay credencial de base de datos configurada", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

cat > /etc/systemd/system/inventario.service << 'EOF'
[Unit]
Description=Inventario
After=network.target

[Service]
Environment="BUCKET_INVENTARIO=<tu-bucket-de-inventario>"
Environment="DB_PASSWORD=<credencial-simulada-de-secrets-manager>"
ExecStart=/usr/bin/python3 /opt/inventario/app.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now inventario
