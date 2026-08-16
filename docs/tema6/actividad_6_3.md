# 🧪 Actividad 6.3: Tu imagen, sin servidores

!!! warning "Descarga la plantilla"
    📄 [Plantilla 6.3 — Tu imagen, sin servidores](plantillas/Actividad_6_3_INU_Plantilla.docx){target="_blank" rel="noopener"}

!!! warning "Descarga los recursos"
    📦 [Recursos de la Actividad 6.3](recursos/actividad_6_3_recursos.zip){target="_blank" rel="noopener"} — descomprímelo en la raíz de tu proyecto: crea la carpeta `recursos/tema6/actividad_6_3/`, la misma ruta que usan los pasos de esta actividad.

!!! info "La imagen te la entrega el profesor"
    Este módulo no cubre cómo se construye una imagen de contenedor desde cero — eso pertenece a otro tipo de formación. El código fuente de la aplicación (en `recursos/tema6/actividad_6_3/v1/` y `v2/`, cada una con su `Dockerfile` listo para construir) está en el zip que has descargado arriba; tu trabajo de hoy es construir la imagen, publicarla y ejecutarla como servicio gestionado.

## Contexto

Un evento necesita mostrar en pantalla, en tiempo real, cuántos asistentes se han registrado. Hoy despliegas ese contador como contenedor, sin administrar ningún servidor por debajo: construyes la imagen, la publicas en un registro, la despliegas como servicio gestionado, y compruebas que puedes escalarla y actualizarla sin cortar el servicio.

## Qué vas a practicar

- Construir y publicar una imagen de contenedor en un registro gestionado.
- Desplegar un servicio de contenedores sin servidores que administrar.
- Escalar el servicio y actualizar de versión observando el reemplazo en marcha.
- Comparar, con datos propios, las tres formas de ejecutar una aplicación que has usado en este tema.

## Requisitos previos

El código fuente del contador de asistencia, versión 1 y versión 2 (cada carpeta con su `app.py`, `requirements.txt` y `Dockerfile`) — descárgalo del enlace de arriba. Docker no hace falta instalarlo: tu **CloudShell** (Tema 1) ya lo trae listo, así que vas a construir las imágenes ahí, sin tocar tu ordenador. El apunte de esta sesión — «Contenedores gestionados» (contenedores-gestionados.md).

---

## Parte A — Publica y despliega (guiada)

### Paso 1 — Crea el registro y publica la imagen

1. Busca "ECR" (Elastic Container Registry) en el buscador de servicios → **Crear repositorio**.
2. Dale un nombre (por ejemplo `contador-asistencia-<tu-identificador>`), déjalo privado, y créalo.
3. En el repositorio recién creado, haz clic en **Ver comandos de inserción** — te da el login y los comandos exactos para tu repositorio concreto.

    ![Repositorio ECR creado, con el botón de comandos de inserción](img/actividad_6_3_paso1.png)
    *🖼️ Captura de referencia del profesor — guardar como `img/actividad_6_3_paso1.png`*

4. Desde tu **CloudShell**: sube `actividad_6_3_recursos.zip` con **Actions → Upload file**, descomprímelo (`unzip actividad_6_3_recursos.zip`), sitúate en `recursos/tema6/actividad_6_3/v1/` y construye la imagen (`docker build -t contador-asistencia .`).
5. Ejecuta el login y sube la imagen construida siguiendo los comandos del paso 3, etiquetándola como versión 1.

**Comprueba**: que la imagen aparece listada en el repositorio, con su etiqueta de versión.

**Captura**: tu propio repositorio ECR creado, y la imagen subida ya listada con su etiqueta de versión.

### Paso 2 — Despliega el servicio desde la consola

1. Busca "ECS" en el buscador de servicios.
2. Si no tienes un clúster todavía, crea uno con lanzamiento **Fargate** (sin servidores que administrar).
3. Ve a **Definiciones de tarea → Crear nueva definición de tarea**.
4. Como tipo de lanzamiento, elige **Fargate**.
5. En el contenedor, pega la URI de tu imagen en ECR (la ves en el repositorio del Paso 1), y configura el puerto 80.
6. Crea la definición de tarea.
7. Dentro de tu clúster, **Crear servicio**, usando esa definición de tarea, con **1** tarea deseada.
8. Configura la red (tu VPC, subred pública) y crea el servicio.

![Servicio ECS creado, con la tarea en estado running](img/actividad_6_3_paso2.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_6_3_paso2.png`*

**Comprueba**: que el contador responde en la IP pública de la tarea, mostrando "Asistentes registrados" con el color de la versión 1.

**Captura**: tu propio servicio ECS con la tarea en estado `running`, y el contador respondiendo en el navegador.

!!! question "Reflexiona"
    No has tocado ningún sistema operativo, ni elegido un tipo de instancia, para llegar hasta aquí. ¿Qué parte exacta de lo que implicaría gestionar tú mismo una instancia EC2 (elegir la imagen base, parchear el sistema operativo, dimensionarla) ha desaparecido de tu responsabilidad, y qué parte sigue siendo tuya (la definición de tarea, el código de la imagen)?

---

## Parte B — Escala, actualiza y compara las tres formas (reto)

**Escala el servicio**: aumenta el número de tareas deseadas por encima de una, y comprueba que el servicio mantiene ese número en marcha de verdad, repartiendo tráfico entre ellas.

**Actualiza sin cortar el servicio**: construye la imagen de la versión 2 (desde `recursos/tema6/actividad_6_3/v2/`), publícala en el registro, actualiza la definición de tarea para usarla, y despliega la actualización sobre el servicio. Observa el reemplazo mientras ocurre —no te limites a comprobar el resultado final— y documenta qué ves durante la transición: ¿hay algún momento en que el contador deja de responder?

**Construye la tabla comparativa final**: con datos propios de las tres formas de ejecución que has visto en este tema (la instancia de prueba de la Actividad 6.1, la función de la Actividad 6.2, el contenedor de hoy), completa una tabla con cuatro columnas — tiempo de despliegue, coste estimado, esfuerzo operativo, y en qué caso elegirías cada una — y justifica cada celda con lo que has medido de verdad, no con la teoría del apunte.

**Comprueba**: que durante la actualización de versión el contador sigue respondiendo en todo momento, y que la tabla comparativa final tiene una celda de justificación para cada combinación, no solo para las que te resultan obvias.

**Captura**: el servicio escalado con varias tareas; la evidencia de la actualización sin corte (por ejemplo, peticiones continuas durante el despliegue, viendo cómo el color pasa de azul a verde); la tabla comparativa final completa.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Imagen construida y publicada en el registro, servicio desplegado correctamente | 4 |
| Contador respondiendo desde el contenedor | 2 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Servicio escalado a varias tareas | 1 |
| Actualización de versión sin corte de servicio, documentada | 1 |
| Tabla comparativa completa y justificada con datos propios | 1 |

---

## ✅ Cierre

Has ejecutado una aplicación de tres formas distintas a lo largo de este tema, y tienes datos propios —no solo teoría— para decidir cuál encaja mejor en cada situación. Con esto se cierra el Tema 6. En el Tema 7, la última sesión del módulo, das un paso atrás y auditas todo lo que has construido con un marco de referencia real.

!!! danger "Antes de salir: para el servicio de ECS"
    Cada tarea de Fargate factura por hora mientras esté en marcha, y si has hecho la Parte B tienes varias a la vez. Baja a 0 el número de tareas deseadas del servicio (o borra directamente el servicio y el clúster) en cuanto termines — no le sirve a ninguna actividad posterior. El repositorio ECR con las imágenes apenas cuesta nada, puedes dejarlo.
