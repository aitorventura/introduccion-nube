# 🧪 Actividad 5.3: Cuánto cuesta lo que has construido

!!! warning "Descarga la plantilla"
    📄 [Plantilla 5.3 — Cuánto cuesta lo que has construido](plantillas/Actividad_5_3_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

Hoy pones un número real a una arquitectura concreta — no una cifra aproximada de memoria, sino una estimación desglosada partida por partida con la calculadora oficial de AWS. No hace falta tener nada desplegado: la calculadora funciona a partir de una lista de componentes que tú introduces, no de lo que exista en una cuenta.

## Qué vas a practicar

- Estimar el coste mensual de una arquitectura completa, desglosado por servicio.
- Reestimar esa misma arquitectura bajo escenarios de tráfico distintos, eligiendo el modelo de compra adecuado a cada uno.
- Aplicar las 6 R de la migración a un caso concreto.

## Requisitos previos

Ninguno técnico — no necesitas tener nada desplegado en el Learner Lab para esta sesión. Los apuntes de esta sesión — [«Economía de la nube»](economia-nube.md).

---

## Arquitectura de referencia

Trabaja con esta arquitectura de referencia durante toda la actividad — podría ser, por ejemplo, la que sostiene el servidor de venta de entradas para conciertos de la Actividad 5.1 en un escenario de producción, ampliado con lo que has ido viendo en el módulo:

- **2 instancias EC2** `t3.micro`, en la región de tu laboratorio.
- **1 instancia RDS** `db.t3.micro`, con **20 GB** de almacenamiento.
- **1 balanceador de carga de aplicación** (Elastic Load Balancing).
- **1 bucket S3** con **50 GB** de datos almacenados y **200 GB/mes** de transferencia saliente.
- **1 distribución CloudFront** delante del contenido estático.

---

## Parte A — Estima la arquitectura de referencia (guiada)

### Paso 1 — Abre la calculadora oficial y añade el cómputo

1. Entra en la [AWS Pricing Calculator](https://calculator.aws) (fuera de la consola de tu Learner Lab, es una herramienta pública).
2. Haz clic en **Create estimate**.
3. Busca el servicio **Amazon EC2** y añádelo a tu estimación.
4. Configura el tipo de instancia `t3.micro`, 2 instancias, y la región de tu laboratorio.
5. Guarda esa línea de la estimación.

![Línea de EC2 añadida a la calculadora, con el tipo y cantidad de instancias de la arquitectura de referencia](img/actividad_5_3_paso1.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_5_3_paso1.png`*

**Comprueba**: que el coste mensual de esa línea tiene un orden de magnitud razonable para dos instancias `t3.micro`.

**Captura**: tu propia línea de EC2 añadida a la calculadora, con el tipo y cantidad de instancias de tu arquitectura de referencia.

### Paso 2 — Añade el resto de servicios de la arquitectura de referencia

Repite el mismo proceso para cada pieza de la arquitectura de referencia: busca el servicio en la calculadora, añádelo, y configúralo con los valores exactos indicados más arriba (no valores por defecto sin revisar):

- **Amazon RDS**: `db.t3.micro`, 20 GB de almacenamiento.
- **Amazon S3**: 50 GB de datos, 200 GB/mes de transferencia saliente.
- **Elastic Load Balancing**: 1 balanceador de carga de aplicación.
- **Amazon CloudFront**: 1 distribución.

![Estimación completa con todos los servicios de la arquitectura de referencia añadidos](img/actividad_5_3_paso2.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_5_3_paso2.png`*

**Comprueba**: que el desglose final muestra una línea por cada servicio, con su coste individual visible, no solo un total sin explicar.

**Captura**: tu propia estimación completa, con todos los servicios añadidos, el desglose completo y el total mensual.

!!! question "Reflexiona"
    De todas las líneas de tu desglose, ¿cuál te ha sorprendido más —por ser más cara o más barata de lo que esperabas antes de calcularlo?

---

## Parte B — Reestima, optimiza y decide una migración (reto)

No hay procedimiento dado para ninguno de los tres retos siguientes — decide tú cómo reflejarlos en la calculadora y cómo justificas cada elección de modelo de compra.

**Reestima tres escenarios** a partir de la arquitectura de referencia del Paso 2: tráfico multiplicado por diez de forma sostenida, un pico de tráfico solo durante una campaña de dos semanas al año, y una arquitectura que se apaga por las noches y los fines de semana. Para cada escenario, elige el modelo de compra que tenga más sentido (bajo demanda, reserva, plan de ahorro o instancias interrumpibles) y justifica por qué ese y no otro.

**Baja el coste sin perder disponibilidad**: parte de una arquitectura hipotética de 900 €/mes con las mismas piezas que la de referencia, y encuentra la forma de bajarla a 400 €/mes sin eliminar ninguna capa de alta disponibilidad — nada de "quita el balanceador" o "vuelve a una sola instancia".

**Decide una migración con las 6 R**: se te presenta una aplicación heredada (el profesor te da el caso concreto) y tienes que elegir, justificando con criterios de negocio y no solo técnicos, cuál de las seis estrategias de migración aplicarías.

**Comprueba**: que cada estimación de los tres escenarios está desglosada por servicio, no es solo un número final; y que tu propuesta de 400 €/mes mantiene el mismo número de zonas de disponibilidad y el mismo mecanismo de reposición automática que la arquitectura de referencia.

**Captura**: las tres estimaciones de escenarios con su modelo de compra justificado; la propuesta de arquitectura a 400 €/mes con el desglose que demuestra que no ha perdido disponibilidad; la decisión de migración razonada.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Estimación completa de la arquitectura de referencia, desglosada por servicio | 7 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Tres escenarios reestimados con modelo de compra justificado | 1 |
| Reto de bajar a 400 €/mes sin perder disponibilidad, con desglose que lo demuestre | 1 |
| Decisión de migración con las 6 R, razonada | 1 |

---

## ✅ Cierre

Ya sabes poner un número real, desglosado y justificado, a cualquier arquitectura que te encuentres — y sabes que reducir coste no siempre significa reducir disponibilidad, si sabes qué palanca mover. Con esto se cierra el Tema 5. En el Tema 6 dejas de construir infraestructura a mano, aunque sea de forma guiada: la vas a declarar en código, para poder reconstruirla entera con un solo comando.
