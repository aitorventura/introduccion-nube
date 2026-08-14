"""Inventario — aplicación mínima para la Actividad 5.2.

Simula la aplicación de gestión de inventario de un almacén: lista los
objetos de un bucket S3 usando el rol de la instancia (sin ninguna
credencial escrita en el código), y muestra si dispone de la credencial de
base de datos que en un despliegue real vendría de Secrets Manager.
"""

import os

import boto3
from botocore.exceptions import ClientError
from flask import Flask

app = Flask(__name__)

# Nombre del bucket a listar como inventario (configúralo a tu bucket real)
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
    """Confirma que la credencial de base de datos llega por variable de entorno,
    sin conectar de verdad a ninguna base de datos: la actividad se centra en
    IAM y Secrets Manager, no en RDS."""
    credencial = os.environ.get("DB_PASSWORD")
    if credencial:
        return "La instancia tiene la credencial de base de datos disponible", 200
    return "No hay credencial de base de datos configurada", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
