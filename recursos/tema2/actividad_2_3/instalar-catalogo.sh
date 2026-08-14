#!/bin/bash
# User data para Amazon Linux 2023 — Actividad 2.3
# Instala Flask y despliega, sin intervención manual, la app de turnos
# de una peluquería. Autocontenido: no depende de subir ficheros aparte.

dnf install -y python3-pip
pip3 install flask

cat > /home/ec2-user/app.py << 'EOF'
from flask import Flask

app = Flask(__name__)

turnos = [
    {"hora": "09:00", "cliente": "Laura G.", "servicio": "Corte de pelo"},
    {"hora": "09:30", "cliente": "Marcos T.", "servicio": "Tinte"},
    {"hora": "10:15", "cliente": "Elena R.", "servicio": "Peinado"},
    {"hora": "11:00", "cliente": "David P.", "servicio": "Corte y barba"},
]


@app.route("/")
def index():
    filas = "".join(
        f"<tr><td>{t['hora']}</td><td>{t['cliente']}</td><td>{t['servicio']}</td></tr>"
        for t in turnos
    )
    return f"""
    <!DOCTYPE html>
    <html lang="es">
    <head><meta charset="UTF-8"><title>Turnos de la peluquería</title></head>
    <body>
        <h1>Próximos turnos</h1>
        <table border="1" cellpadding="6">
            <tr><th>Hora</th><th>Cliente</th><th>Servicio</th></tr>
            {filas}
        </table>
    </body>
    </html>
    """


@app.route("/salud")
def salud():
    return "OK", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

cat > /etc/systemd/system/turnos.service << 'EOF'
[Unit]
Description=App de turnos de la peluqueria
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/ec2-user/app.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now turnos.service
