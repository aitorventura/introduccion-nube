"""
Contador de Asistencia — versión 2
Actividad 6.3 — Tu imagen, sin servidores
"""

from flask import Flask

app = Flask(__name__)

ASISTENTES = 312

HTML = f"""
<!doctype html>
<html lang="es">
  <head>
    <meta charset="utf-8">
    <title>Contador de Asistencia</title>
    <style>
      body {{
        background-color: #2E7D32;
        color: #FFFFFF;
        font-family: Arial, sans-serif;
        text-align: center;
        padding-top: 15vh;
      }}
      h1 {{ font-size: 3rem; margin-bottom: 0.2em; }}
      p {{ font-size: 1.2rem; opacity: 0.85; }}
      .badge {{
        display: inline-block;
        margin-top: 1em;
        padding: 0.3em 1em;
        border: 2px solid #FFFFFF;
        border-radius: 999px;
        font-weight: bold;
        letter-spacing: 0.1em;
      }}
    </style>
  </head>
  <body>
    <h1>Asistentes registrados: {ASISTENTES}</h1>
    <p>Contador de Asistencia — versión 2</p>
    <div class="badge">NUEVA VERSIÓN</div>
  </body>
</html>
"""


@app.route("/")
def contador():
    return HTML


@app.route("/salud")
def salud():
    return "OK", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
