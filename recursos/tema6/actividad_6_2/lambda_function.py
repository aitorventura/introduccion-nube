"""
Función Lambda — Carrera Popular: fotos de dorsal
Actividad 6.2 — Una función por cada imagen

Se dispara con el evento de creación de un objeto en el bucket de fotos de
dorsal. Genera una miniatura de la foto (200x200 px, manteniendo la
proporción) y la guarda en el mismo bucket bajo el prefijo `miniaturas/`,
y además registra un objeto JSON con los metadatos de la foto original bajo
el prefijo `metadatos/`.

Requiere Pillow, que no viene incluido en el runtime de Lambda por defecto
— ver README.md de esta misma carpeta para empaquetarla antes de subir la
función.
"""

import json
import urllib.parse
from datetime import datetime, timezone
from io import BytesIO

import boto3
from PIL import Image

s3 = boto3.client("s3")

TAMANO_MINIATURA = (200, 200)
PREFIJO_MINIATURAS = "miniaturas/"
PREFIJO_METADATOS = "metadatos/"


def lambda_handler(event, context):
    procesados = []

    for registro in event["Records"]:
        bucket = registro["s3"]["bucket"]["name"]
        clave = urllib.parse.unquote_plus(registro["s3"]["object"]["key"])

        # Evita que la función se dispare a sí misma al escribir en
        # miniaturas/ o metadatos/ dentro del mismo bucket.
        if clave.startswith(PREFIJO_MINIATURAS) or clave.startswith(PREFIJO_METADATOS):
            continue

        objeto = s3.get_object(Bucket=bucket, Key=clave)
        contenido = objeto["Body"].read()
        tamano_original_bytes = objeto["ContentLength"]

        imagen = Image.open(BytesIO(contenido))
        formato = imagen.format or "JPEG"
        ancho_original, alto_original = imagen.size

        # Genera la miniatura manteniendo la proporción original.
        miniatura = imagen.copy()
        miniatura.thumbnail(TAMANO_MINIATURA)

        buffer_miniatura = BytesIO()
        miniatura.save(buffer_miniatura, format=formato)
        buffer_miniatura.seek(0)

        nombre_fichero = clave.rsplit("/", 1)[-1]
        clave_miniatura = f"{PREFIJO_MINIATURAS}{nombre_fichero}"

        s3.put_object(
            Bucket=bucket,
            Key=clave_miniatura,
            Body=buffer_miniatura.getvalue(),
            ContentType=objeto.get("ContentType", "image/jpeg"),
        )

        metadatos = {
            "fichero_original": clave,
            "ancho_original_px": ancho_original,
            "alto_original_px": alto_original,
            "formato": formato,
            "tamano_original_bytes": tamano_original_bytes,
            "fecha_subida": datetime.now(timezone.utc).isoformat(),
            "miniatura": clave_miniatura,
        }

        clave_metadatos = f"{PREFIJO_METADATOS}{nombre_fichero}.json"
        s3.put_object(
            Bucket=bucket,
            Key=clave_metadatos,
            Body=json.dumps(metadatos, indent=2).encode("utf-8"),
            ContentType="application/json",
        )

        procesados.append(clave)

    return {"statusCode": 200, "body": json.dumps({"procesados": procesados})}
