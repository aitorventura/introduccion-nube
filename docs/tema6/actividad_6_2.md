# 🧪 Actividad 6.2: Una función por cada imagen

!!! warning "Descarga la plantilla"
    📄 [Plantilla 6.2 — Una función por cada imagen](plantillas/Actividad_6_2_INU_Plantilla.docx){target="_blank" rel="noopener"}

!!! warning "Descarga los recursos"
    📦 [Recursos de la Actividad 6.2](recursos/actividad_6_2_recursos.zip){target="_blank" rel="noopener"} — lo vas a subir y descomprimir en el Paso 3 de esta actividad.

## Contexto

En una carrera popular, cada participante sube la foto de su dorsal, y alguien tiene que generar su miniatura y registrar sus metadatos. Hoy esa tarea deja de depender de una instancia tuya: una función se dispara sola cuando llega la imagen, hace su trabajo, y desaparece.

## Qué vas a practicar

- Crear una función Lambda disparada por un evento de S3.
- Procesar una imagen y registrar sus metadatos sin ningún servidor que administres.
- Montar una mini API con pasarela y función, y compararla con la misma operación servida por una instancia.

## Requisitos previos

Un bucket de S3 nuevo, creado por ti en la Parte A de esta misma actividad. El código base de la función, `lambda_function.py` (con su `requirements.txt` y su `README.md` de empaquetado) — descárgalo del enlace de arriba. Los apuntes de esta sesión — [«Serverless»](serverless.md).

---

## Parte A — Función disparada por evento (guiada)

### Paso 1 — Crea el bucket de fotos de dorsal

1. Busca "S3" en el buscador de servicios → **Crear bucket**.
2. Dale un nombre único a nivel global, por ejemplo `carrera-dorsales-<tu-identificador>`.
3. Deja el resto de opciones por defecto (bloqueo de acceso público activado) y créalo.

![Bucket de fotos de dorsal creado, vacío](img/actividad_6_2_paso1.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_6_2_paso1.png`*

**Comprueba**: que el bucket aparece vacío y accesible desde tu cuenta.

**Captura**: tu propio bucket de fotos de dorsal creado, vacío.

### Paso 2 — Crea la función desde la consola

1. Busca "Lambda" en el buscador de servicios → **Crear función**.
2. Elige **Crear desde cero**.
3. Dale un nombre (por ejemplo `carrera-miniaturas-<tu-identificador>`).
4. Elige el entorno de ejecución **Python** (es el que usa el código que te entrega el profesor).
5. En **Permisos de ejecución**, usa el rol existente que te ofrezca el asistente (no puedes crear uno nuevo) y confirma que incluye acceso a S3.
6. Crea la función.

![Función Lambda creada, con su configuración inicial visible](img/actividad_6_2_paso2_a.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_6_2_paso2_a.png`*

**Comprueba**: que la función aparece con estado activo en el panel de Lambda.

**Captura**: tu propia función Lambda creada, con su configuración inicial visible.

### Paso 3 — Sube el código y configura el disparador de S3

El profesor te entrega el código ya escrito en `recursos/tema6/actividad_6_2/lambda_function.py`: recibe el evento de S3, genera una miniatura real con Pillow (redimensionada a 200x200 manteniendo la proporción) bajo el prefijo `miniaturas/`, y registra un objeto JSON con los metadatos (tamaño original, formato, fecha de subida) bajo el prefijo `metadatos/`, todo en el mismo bucket.

1. Pillow no viene incluida en el entorno de ejecución de Lambda por defecto, y tiene partes compiladas específicas del sistema operativo — tienes que empaquetarla en un Linux compatible con Lambda, no en Windows ni macOS. Para eso usa tu **CloudShell** (Tema 1), que ya es Amazon Linux: sube `actividad_6_2_recursos.zip` con **Actions → Upload file**, descomprímelo (`unzip actividad_6_2_recursos.zip`), y sigue las instrucciones de `recursos/tema6/actividad_6_2/README.md` para empaquetar el código junto con sus dependencias en un `.zip` — todo dentro de CloudShell.
2. El `.zip` empaquetado se ha generado dentro de CloudShell, no en tu ordenador — descárgalo primero con **Actions → Download file** (indicando la ruta del `.zip` dentro de CloudShell). Ahora sí, súbelo como código de la función desde la consola de Lambda (**Cargar desde → archivo .zip**), en vez de escribirlo en el editor integrado.
3. Ve a la pestaña **Configuración → Disparadores → Añadir disparador**.
4. Selecciona **S3**, elige tu bucket de fotos de dorsal, y como tipo de evento **Todos los eventos de creación de objetos**.
5. Guarda el disparador.

    ![Disparador de S3 configurado sobre la función](img/actividad_6_2_paso3_a.png)
    *🖼️ Captura de referencia del profesor — guardar como `img/actividad_6_2_paso3_a.png`*

6. Sube una foto de dorsal nueva a tu bucket (por CLI o por consola) y comprueba que se genera la miniatura sin que tú hayas ejecutado nada más.

![Miniatura generada automáticamente tras subir la foto original](img/actividad_6_2_paso3_b.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_6_2_paso3_b.png`*

**Comprueba**: que la miniatura aparece en el bucket unos segundos después de subir la foto original, sin intervención tuya, y que el objeto de metadatos aparece bajo `metadatos/` con los datos correctos.

**Captura**: tu propio disparador de S3 configurado sobre la función, y la miniatura generada automáticamente tras subir la foto original.

!!! question "Reflexiona"
    Si se subieran cien fotos de dorsal a la vez (por ejemplo, al final de la carrera), ¿qué pasaría con tu función? Compáralo con lo que le pasaría a una única instancia si tuviera que procesar cien peticiones simultáneas de generación de miniaturas.

---

## Parte B — Mini API y comparación real (reto)

Monta una mini API con una pasarela delante de una función que resuelva una operación sencilla (por ejemplo, devolver los metadatos de un dorsal concreto). No hay procedimiento dado — decide tú cómo conectas la pasarela con la función y cómo la pruebas.

Con la API funcionando, mide la latencia real de esa operación servida por tu función, y compárala con la latencia de la misma operación servida por una instancia con un servidor sencillo desplegado por ti. Repite la medición varias veces para distinguir el efecto del arranque en frío de una invocación ya "caliente".

Después, estima el coste mensual de ambas opciones para dos volúmenes de tráfico distintos: uno bajo (pocas peticiones al día) y uno alto (miles de peticiones por minuto de forma sostenida), y decide, con esos números delante, en qué casos elegirías la función y en cuáles la instancia.

**Comprueba**: que tus medidas de latencia distinguen claramente entre una invocación con arranque en frío y una ya caliente, y que tu comparación de coste está basada en cifras reales de la calculadora, no en una estimación aproximada.

**Captura**: las medidas de latencia (fría y caliente) de ambas soluciones; la comparación de coste para los dos volúmenes de tráfico; tu decisión razonada de cuándo elegir cada una.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Función creada y disparador de S3 configurado correctamente | 3 |
| Miniatura generada automáticamente, sin intervención manual | 3 |
| Metadatos registrados correctamente | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Mini API funcionando con pasarela y función | 2 |
| Comparación de latencia y coste con datos reales, decisión razonada | 1 |

---

## ✅ Cierre

Ya tienes procesamiento de imágenes que se dispara solo, sin ningún servidor que administres, y sabes con datos propios cuándo compensa serverless y cuándo no. La próxima sesión ves la tercera forma de ejecutar una aplicación: contenedores, sin servidor que gestionar pero sin el modelo de eventos de hoy.

!!! tip "Antes de salir: borra la instancia de comparación, si la has creado"
    Si has hecho la Parte B, termina la instancia que desplegaste para comparar su latencia con la función Lambda — es lo único de esta actividad con coste por hora. La función, el bucket y la pasarela API no cuestan nada por existir sin tráfico, puedes dejarlos.
