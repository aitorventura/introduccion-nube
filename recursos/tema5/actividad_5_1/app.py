"""Entradas — aplicación mínima para la Actividad 5.1.

Simula el servidor de una aplicación de venta de entradas para conciertos:
un catálogo con la disponibilidad de cada concierto, una ruta de salud, y
una ruta de compra que falla de forma intermitente para poder practicar el
diagnóstico de incidencias apoyándose solo en métricas y registros.
"""

import logging
import random

from flask import Flask

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

# Catálogo de ejemplo (datos fijos, solo para la actividad)
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
    """Simula la compra de una entrada, fallando de forma intermitente.

    Aproximadamente una de cada cuatro peticiones responde con error 500,
    para servir de incidencia real que se pueda diagnosticar en la
    Actividad 5.1 a partir de las métricas y los registros, sin acceso
    directo al servidor.
    """
    if random.randint(1, 4) == 1:
        logging.error("Fallo al confirmar la compra: tiempo de espera agotado con la pasarela de pago")
        return "Error al procesar la compra", 500
    logging.info("Compra confirmada correctamente")
    return "Compra confirmada", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
