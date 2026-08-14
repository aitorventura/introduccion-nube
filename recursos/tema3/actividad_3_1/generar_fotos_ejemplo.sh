#!/usr/bin/env bash
# Genera fotos de ejemplo para la Actividad 3.1 (festival de música).
#
# No son fotografías reales: son ficheros con extensión .jpg y contenido
# aleatorio, de tamaño variable, pensados solo para tener contenido de
# prueba que subir a S3 y a EFS sin tener que buscar imágenes reales ni
# depender de herramientas de edición de imagen.
#
# Uso:
#   ./generar_fotos_ejemplo.sh [carpeta_destino]
#
# Por defecto crea las fotos en ./fotos_festival

set -euo pipefail

DESTINO="${1:-./fotos_festival}"
mkdir -p "$DESTINO"

NOMBRES=(
  "asistente_01.jpg"
  "asistente_02.jpg"
  "asistente_03.jpg"
  "asistente_04.jpg"
  "asistente_05.jpg"
  "asistente_06.jpg"
)

for nombre in "${NOMBRES[@]}"; do
  # Tamaño aleatorio entre 200 KB y 800 KB, para que no sean todas idénticas
  tam_kb=$(( (RANDOM % 600) + 200 ))
  dd if=/dev/urandom of="$DESTINO/$nombre" bs=1024 count="$tam_kb" status=none
  echo "Generado $DESTINO/$nombre (${tam_kb} KB)"
done

echo
echo "Fotos de ejemplo listas en $DESTINO/."
echo "Súbelas al bucket, por ejemplo:"
echo "  aws s3 cp $DESTINO/ s3://<tu-bucket>/ --recursive"
echo
echo "Si trabajas sobre un volumen EFS montado, cópialas directamente a la carpeta montada:"
echo "  cp $DESTINO/* /mnt/efs-festival/"
