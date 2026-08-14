"""Encuestas en Vivo — aplicación mínima para la Actividad 4.1.

Muestra el resultado de una encuesta de ejemplo para un evento y, de forma
visible, el identificador de la instancia EC2 que ha respondido a la
petición — así se puede comprobar a simple vista cómo el balanceador de
carga reparte el tráfico entre instancias al recargar la página.
"""

import socket
import time

import requests
from flask import Flask

app = Flask(__name__)

# Resultado de encuesta de ejemplo (datos fijos, solo para la actividad)
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
    """Devuelve el ID de instancia EC2 vía IMDSv2, o el hostname si no está disponible.

    Se usa IMDSv2 (con token) porque IMDSv1 puede estar deshabilitado por
    política de seguridad. Si la petición de metadatos falla por cualquier
    motivo (por ejemplo, ejecutando fuera de EC2), se recurre al hostname
    para que la aplicación nunca deje de responder por este motivo.
    """
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
    """Ocupa la CPU unos segundos, para poder forzar el escalado con tráfico real."""
    fin = time.time() + 5
    while time.time() < fin:
        pass
    return "Carga generada", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
