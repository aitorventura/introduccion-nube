#!/bin/bash
# User data para Amazon Linux 2023 — Actividad 2.2
# Instala y arranca, sin intervención manual, un servidor web mínimo:
# el tablón de anuncios municipal.

dnf install -y nginx

cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Tablón de anuncios municipal</title>
</head>
<body>
    <h1>Tablón de anuncios municipal</h1>
    <p>Corte de agua programado el próximo miércoles de 9:00 a 13:00 en la calle Mayor.</p>
    <p>Recogida de muebles y enseres: inscripción abierta hasta el día 20 en la web del ayuntamiento.</p>
</body>
</html>
EOF

systemctl enable --now nginx
