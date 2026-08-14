# 🧪 Actividad 5.3: Cuánto cuesta lo que has construido

!!! warning "Descarga la plantilla"
    📄 [Plantilla 5.3 — Cuánto cuesta lo que has construido](plantillas/Actividad_5_3_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

Después de doce sesiones construyendo Escaparate, hoy pones un número real a todo lo que has levantado — no una cifra aproximada de memoria, sino una estimación desglosada partida por partida con la calculadora oficial de AWS.

## Qué vas a practicar

- Estimar el coste mensual de una arquitectura completa, desglosado por servicio.
- Reestimar esa misma arquitectura bajo escenarios de tráfico distintos, eligiendo el modelo de compra adecuado a cada uno.
- Aplicar las 6 R de la migración a un caso concreto.

## Requisitos previos

Tu arquitectura completa de la Actividad 3.3, ampliada con el balanceador y el escalado del Tema 4. El apunte de esta sesión — «Economía de la nube» (economia-nube.md).

---

## Parte A — Estima tu arquitectura real (guiada)

### Paso 1 — Abre la calculadora oficial y añade el cómputo

1. Entra en la [AWS Pricing Calculator](https://calculator.aws) (fuera de la consola de tu Learner Lab, es una herramienta pública).
2. Haz clic en **Create estimate**.
3. Busca el servicio **Amazon EC2** y añádelo a tu estimación.
4. Configura el tipo de instancia que usas de verdad en tu grupo de escalado (por ejemplo `t3.micro`), la cantidad de instancias de tu capacidad deseada, y la región de tu laboratorio.
5. Guarda esa línea de la estimación.

![Línea de EC2 añadida a la calculadora, con el tipo y cantidad de instancias reales](img/actividad_5_3_paso1.png)

**Comprueba**: que el coste mensual de esa línea tiene un orden de magnitud razonable para el número de instancias que de verdad tienes en marcha.
**Captura**: `img/actividad_5_3_paso1.png`.

### Paso 2 — Añade el resto de servicios de tu arquitectura

Repite el mismo proceso para cada pieza real de tu arquitectura: busca el servicio en la calculadora, añádelo, y configúralo con los valores que corresponden a lo que tienes desplegado de verdad (no valores por defecto sin revisar):

- **Amazon RDS**: tu clase de instancia y almacenamiento asignado.
- **Amazon S3**: el volumen aproximado de datos que tienes en tus buckets.
- **Elastic Load Balancing**: tu balanceador de carga.
- **Amazon CloudFront**: tu distribución CDN, si la tienes activa.
- Transferencia de datos de salida: una estimación razonable de tráfico mensual.

![Estimación completa con todos los servicios de tu arquitectura añadidos](img/actividad_5_3_paso2.png)

**Comprueba**: que el desglose final muestra una línea por cada servicio, con su coste individual visible, no solo un total sin explicar.
**Captura**: `img/actividad_5_3_paso2.png`, con el desglose completo y el total mensual.

!!! question "Reflexiona"
    De todas las líneas de tu desglose, ¿cuál te ha sorprendido más —por ser más cara o más barata de lo que esperabas antes de calcularlo? ¿Coincide con lo que has ido apuntando como "recurso más caro" en el ritual de cierre de las sesiones anteriores?

---

## Parte B — Reestima, optimiza y decide una migración (reto)

No hay procedimiento dado para ninguno de los tres retos siguientes — decide tú cómo reflejarlos en la calculadora y cómo justificas cada elección de modelo de compra.

**Reestima tres escenarios** a partir de tu arquitectura del Paso 2: tráfico multiplicado por diez de forma sostenida, un pico de tráfico solo durante una campaña de dos semanas al año, y una arquitectura que se apaga por las noches y los fines de semana. Para cada escenario, elige el modelo de compra que tenga más sentido (bajo demanda, reserva, plan de ahorro o instancias interrumpibles) y justifica por qué ese y no otro.

**Baja el coste sin perder disponibilidad**: parte de una arquitectura hipotética de 900 €/mes con las mismas piezas que la tuya, y encuentra la forma de bajarla a 400 €/mes sin eliminar ninguna capa de alta disponibilidad que hayas construido en el Tema 4 — nada de "quita el balanceador" o "vuelve a una sola instancia".

**Decide una migración con las 6 R**: se te presenta una aplicación heredada (el profesor te da el caso concreto) y tienes que elegir, justificando con criterios de negocio y no solo técnicos, cuál de las seis estrategias de migración aplicarías.

**Comprueba**: que cada estimación de los tres escenarios está desglosada por servicio, no es solo un número final; y que tu propuesta de 400 €/mes mantiene el mismo número de zonas de disponibilidad y el mismo mecanismo de reposición automática que tu arquitectura original.
**Captura**: las tres estimaciones de escenarios con su modelo de compra justificado; la propuesta de arquitectura a 400 €/mes con el desglose que demuestra que no ha perdido disponibilidad; la decisión de migración razonada.

---

## Verificación

Se revisará la estimación exportada de la AWS Pricing Calculator (o su enlace compartido) correspondiente a tu arquitectura real, los tres escenarios reestimados con su modelo de compra justificado, la propuesta a 400 €/mes con su desglose, y la decisión de migración con las 6 R razonada por escrito.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Estimación completa de la arquitectura real, desglosada por servicio | 6 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Tres escenarios reestimados con modelo de compra justificado | 1 |
| Reto de bajar a 400 €/mes sin perder disponibilidad, con desglose que lo demuestre | 1 |
| Decisión de migración con las 6 R, razonada | 1 |

---

## ✅ Cierre

Ya sabes poner un número real, desglosado y justificado, a cualquier arquitectura que construyas — y sabes que reducir coste no siempre significa reducir disponibilidad, si sabes qué palanca mover. Con esto se cierra el Tema 5. En el Tema 6 dejas de construir infraestructura a mano, aunque sea de forma guiada: la vas a declarar en código, para poder reconstruirla entera con un solo comando.
