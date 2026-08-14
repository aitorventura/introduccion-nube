# 🧪 Actividad 6.2: Una función por cada imagen

!!! warning "Descarga la plantilla"
    📄 [Plantilla 6.2 — Una función por cada imagen](plantillas/Actividad_6_2_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

Cada vez que se sube una imagen de producto a Escaparate, alguien tiene que generar su miniatura y registrar sus metadatos. Hoy esa tarea deja de depender de tu instancia: una función se dispara sola cuando llega la imagen, hace su trabajo, y desaparece.

## Qué vas a practicar

- Crear una función Lambda disparada por un evento de S3.
- Procesar una imagen y registrar sus metadatos sin ningún servidor que administres.
- Montar una mini API con pasarela y función, y compararla con la misma operación servida por una instancia.

## Requisitos previos

Un bucket de imágenes de producto (el de la Actividad 3.1, o uno nuevo). El apunte de esta sesión — «Serverless» (serverless.md).

---

## Parte A — Función disparada por evento (guiada)

### Paso 1 — Crea la función desde la consola

1. Busca "Lambda" en el buscador de servicios → **Crear función**.
2. Elige **Crear desde cero**.
3. Dale un nombre (por ejemplo `escaparate-miniaturas-<tu-identificador>`).
4. Elige el entorno de ejecución que te indique el profesor (por ejemplo Python o Node.js).
5. En **Permisos de ejecución**, usa el rol existente que te ofrezca el asistente (no puedes crear uno nuevo) y confirma que incluye acceso a S3.
6. Crea la función.

![Función Lambda creada, con su configuración inicial visible](img/actividad_6_2_paso1_a.png)

**Comprueba**: que la función aparece con estado activo en el panel de Lambda.
**Captura**: `img/actividad_6_2_paso1_a.png`.

### Paso 2 — Escribe el código y configura el disparador de S3

1. En el editor de código integrado de la consola, escribe la función que recibe el evento de S3, genera una miniatura de la imagen y guarda sus metadatos (tamaño, formato, fecha) — el profesor te da la base del código a completar.
2. Guarda y despliega los cambios.
3. Ve a la pestaña **Configuración → Disparadores → Añadir disparador**.
4. Selecciona **S3**, elige tu bucket de imágenes, y como tipo de evento **Todos los eventos de creación de objetos**.
5. Guarda el disparador.

![Disparador de S3 configurado sobre la función](img/actividad_6_2_paso2_a.png)

6. Sube una imagen nueva a tu bucket (por CLI o por consola) y comprueba que se genera la miniatura sin que tú hayas ejecutado nada más.

![Miniatura generada automáticamente tras subir la imagen original](img/actividad_6_2_paso2_b.png)

**Comprueba**: que la miniatura aparece en el bucket unos segundos después de subir la imagen original, sin intervención tuya, y que los metadatos quedan registrados en algún sitio consultable (un fichero, una tabla, según lo que hayas implementado).
**Captura**: `img/actividad_6_2_paso2_a.png` y `img/actividad_6_2_paso2_b.png`.

!!! question "Reflexiona"
    Si subieras cien imágenes a la vez, ¿qué pasaría con tu función? Compáralo con lo que le pasaría a una única instancia si tuviera que procesar cien peticiones simultáneas de generación de miniaturas.

---

## Parte B — Mini API y comparación real (reto)

Monta una mini API con una pasarela delante de una función que resuelva una operación sencilla del catálogo (por ejemplo, devolver el detalle de un producto). No hay procedimiento dado — decide tú cómo conectas la pasarela con la función y cómo la pruebas.

Con la API funcionando, mide la latencia real de esa operación servida por tu función, y compárala con la latencia de la misma operación servida por tu instancia de aplicación ya desplegada. Repite la medición varias veces para distinguir el efecto del arranque en frío de una invocación ya "caliente".

Después, estima el coste mensual de ambas opciones para dos volúmenes de tráfico distintos: uno bajo (pocas peticiones al día) y uno alto (miles de peticiones por minuto de forma sostenida), y decide, con esos números delante, en qué casos elegirías la función y en cuáles la instancia.

**Comprueba**: que tus medidas de latencia distinguen claramente entre una invocación con arranque en frío y una ya caliente, y que tu comparación de coste está basada en cifras reales de la calculadora, no en una estimación aproximada.
**Captura**: las medidas de latencia (fría y caliente) de ambas soluciones; la comparación de coste para los dos volúmenes de tráfico; tu decisión razonada de cuándo elegir cada una.

---

## Verificación

Para dar por válida la práctica se ejecutará:

```bash
aws lambda get-function --function-name escaparate-miniaturas-<tu-identificador>
aws s3 ls s3://<tu-bucket-imagenes>/miniaturas/
```

Y debe observarse: la función activa con su disparador de S3 configurado, al menos una miniatura generada automáticamente, y la comparación de latencia y coste documentada con datos reales.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Función creada y disparador de S3 configurado correctamente | 3 |
| Miniatura generada automáticamente, sin intervención manual | 2 |
| Metadatos registrados correctamente | 1 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Mini API funcionando con pasarela y función | 2 |
| Comparación de latencia y coste con datos reales, decisión razonada | 1 |

---

## ✅ Cierre

Ya tienes procesamiento de imágenes que se dispara solo, sin ningún servidor que administres, y sabes con datos propios cuándo compensa serverless y cuándo no. La próxima sesión ves la tercera forma de ejecutar la misma aplicación: contenedores, sin servidor que gestionar pero sin el modelo de eventos de hoy.
