# Empaquetar `lambda_function.py` con sus dependencias

Pillow (la librería que usa `lambda_function.py` para generar la miniatura)
no viene incluida en el entorno de ejecución de Lambda por defecto — hay que
empaquetarla junto con el código antes de subir la función. Dos formas de
hacerlo, de más simple a más avanzada:

## Opción 1 — Todo en un único .zip (la más simple para este ejercicio)

```bash
pip install -r requirements.txt -t package/
cp lambda_function.py package/
cd package
zip -r ../funcion.zip .
```

El fichero `funcion.zip` resultante contiene tanto las dependencias como el
código de la función. Se sube como código de la función Lambda (**Cargar
desde → archivo .zip**), en vez de escribirlo en el editor integrado de la
consola.

## Opción 2 — Una capa (layer) con las dependencias

Si prefieres mantener el código de la función separado de sus dependencias
(por ejemplo, para reutilizar la misma capa en varias funciones), empaqueta
solo las dependencias en su propia estructura de carpetas (`python/`) y
publícalas como una capa de Lambda; la función en sí se sube entonces solo
con `lambda_function.py`, con la capa asociada. Es más flexible, pero
requiere un paso adicional de gestión de la capa — para esta actividad, la
Opción 1 es suficiente.
