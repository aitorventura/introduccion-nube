#!/bin/bash
# User data para Amazon Linux 2023 — Actividad 2.2
# Instala y arranca, sin intervención manual, el servidor web de la
# aplicación de reservas de pistas deportivas.

dnf install -y nginx

cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reservas de pistas deportivas</title>
</head>
<body>
    <h1>Reservas de pistas deportivas</h1>
    <p>Pista 1 (pádel): libre a partir de las 18:00.</p>
    <p>Pista 2 (fútbol sala): reservada hasta las 20:00.</p>
</body>
</html>
EOF

systemctl enable --now nginx
