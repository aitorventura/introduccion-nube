# 🧪 Actividad 4.1: Balanceador de carga y Auto Scaling Group

!!! warning "Descarga la plantilla"
    📄 [Plantilla 4.1 — Balanceador de carga y Auto Scaling Group](plantillas/Actividad_4_1_INU_Plantilla.docx){target="_blank" rel="noopener"}

!!! warning "Descarga los recursos"
    📦 [Recursos de la Actividad 4.1](recursos/actividad_4_1_recursos.zip){target="_blank" rel="noopener"} — descomprímelo en la raíz de tu proyecto: crea la carpeta `recursos/tema4/actividad_4_1/`, la misma ruta que usan los pasos de esta actividad (incluida la subcarpeta `estaticos/` que vas a reutilizar en la Actividad 4.2).

## Contexto

Una aplicación de encuestas en directo para eventos —Encuestas en Vivo— va a proyectarse en pantalla durante una conferencia con cientos de asistentes votando a la vez desde el móvil. Desplegarla en una única instancia significa que, si esa instancia se cae a mitad del evento, la encuesta desaparece delante de todo el público. Hoy resuelves justo eso — no añadiendo "una instancia más por si acaso", sino un mecanismo que reparte el tráfico entre varias copias y que repone automáticamente la que falle, sin que tú tengas que estar mirando la pantalla.

## Qué vas a practicar

- Empaquetar una aplicación propia en una plantilla de lanzamiento, de cero.
- Crear un balanceador de carga con su grupo de destino y comprobación de salud.
- Configurar un grupo de escalado automático a partir de esa plantilla.
- Comprobar el reparto real de tráfico entre instancias.
- Medir el tiempo real de reposición automática y de escalado por carga.

## Requisitos previos

Acceso a tu Learner Lab con una VPC de dos zonas y sus subredes públicas ya creadas (Tema 2). Los ficheros de la aplicación de Encuestas en Vivo (`app.py`, `requirements.txt`, `arranque-encuestas.sh`) — descárgalos del enlace de arriba, no los programas tú. El apunte de esta sesión — «Balanceo de carga y escalado automático» (alta-disponibilidad-escalado.md).

---

## Parte A — Balanceador y escalado automático (guiada)

### Paso 1 — Crea tu plantilla de lanzamiento desde la consola

1. Busca "EC2" en el buscador de servicios → menú lateral **Plantillas de lanzamiento** → **Crear plantilla de lanzamiento**.
2. Dale un nombre, por ejemplo `encuestas-lt-<tu-identificador>`.
3. Elige una AMI de Amazon Linux 2023, y el tipo `t3.micro`.
4. En **Par de claves**, elige el tuyo.
5. En **Configuración de red**, crea (o reutiliza) un grupo de seguridad con solo dos reglas: puerto 80 abierto a `0.0.0.0/0`, y puerto 22 restringido a tu propia IP.
6. Despliega **Detalles avanzados**, baja hasta el campo **Datos de usuario** (*user data*), y pega ahí el contenido completo de `arranque-encuestas.sh` — el script vive en `recursos/tema4/actividad_4_1/arranque-encuestas.sh`, dentro del zip que has descargado arriba.
7. Crea la plantilla.

![Plantilla de lanzamiento creada, con la AMI, el grupo de seguridad y el user data de Encuestas en Vivo configurados](img/actividad_4_1_paso1.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_4_1_paso1.png`*

El script `arranque-encuestas.sh` instala y arranca, al primer arranque de cada instancia, la aplicación de Encuestas en Vivo en el puerto 80, sin intervención tuya.

**Comprueba**: que la plantilla aparece creada, con la AMI, el tipo de instancia, el grupo de seguridad y el user data correctos.

**Captura**: tu propia plantilla de lanzamiento creada, con la AMI, el grupo de seguridad y el user data configurados.

### Paso 2 — Crea el balanceador y el grupo de destino desde la consola

1. Menú lateral **Balanceadores de carga** → **Crear balanceador de carga**.
2. Elige **Balanceador de carga de aplicación**.
3. Dale un nombre, esquema **Con acceso a internet**, y selecciona tu VPC con sus dos subredes públicas.
4. En **Listeners y enrutamiento**, en lugar de un grupo de destino existente, haz clic en **Crear grupo de destino**:
    1. Tipo de destino: **Instancias**.
    2. Protocolo/puerto: HTTP 80.
    3. En **Comprobaciones de estado**, cambia la ruta a `/salud`.
    4. Crea el grupo de destino (todavía sin instancias registradas).
5. Vuelve al asistente del balanceador, selecciona el grupo de destino recién creado, y haz clic en **Crear balanceador de carga**.

![Balanceador creado, con su listener apuntando al grupo de destino y su comprobación de salud en /salud](img/actividad_4_1_paso2.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_4_1_paso2.png`*

**Comprueba**: que el grupo de destino aparece vacío por ahora (todavía no tienes instancias registradas) y que el balanceador está `active`.

**Captura**: tu propio balanceador creado, con su listener apuntando al grupo de destino y la comprobación de salud en `/salud`.

### Paso 3 — Crea el grupo de escalado automático por CLI

Aquí la consola no te ahorra trabajo: crear un grupo de Auto Scaling por consola significa recorrer un asistente de varias pantallas repitiendo datos que ya diste en la plantilla del Paso 1; por CLI es un único comando con los mismos parámetros. Si aun así prefieres verlo por consola, está en EC2 → **Grupos de Auto Scaling** → **Crear grupo de Auto Scaling**. Usa la plantilla de lanzamiento del Paso 1, con capacidad mínima 2, deseada 2 y máxima 4, en las dos zonas de tu VPC, asociado al grupo de destino del Paso 2:

```bash
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name encuestas-asg-<tu-identificador> \
  --launch-template LaunchTemplateName=encuestas-lt-<tu-identificador> \
  --min-size 2 --desired-capacity 2 --max-size 4 \
  --target-group-arns <target-group-arn> \
  --vpc-zone-identifier "<subnet-publica-a>,<subnet-publica-b>"
```

Comprueba el resultado en consola: entra en tu grupo de destino, pestaña **Destinos registrados**.

![Grupo de destino con dos instancias en estado healthy, una por zona](img/actividad_4_1_paso3.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_4_1_paso3.png`*

**Comprueba**: que al cabo de unos minutos, el grupo de destino del balanceador muestra dos instancias en estado `healthy`, una en cada zona.

**Captura**: tu propio grupo de destino con las instancias en estado `healthy`, una por zona.

### Paso 4 — Comprueba el reparto real de tráfico

Consulta la página principal (`/`) de Encuestas en Vivo a través de la URL del balanceador varias veces seguidas, y observa qué identificador de instancia aparece respondiendo en cada petición.

**Comprueba**: que el identificador de instancia cambia entre peticiones sucesivas, señal de que el balanceador está repartiendo el tráfico entre las dos.

**Captura**: al menos cuatro peticiones consecutivas a la URL del balanceador, mostrando identificadores distintos.

!!! question "Reflexiona"
    Antes de esta sesión, la URL que usaba cualquier asistente para votar habría sido la IP pública de una instancia concreta. Ahora es la del balanceador. ¿Qué le pasa a un visitante que tuviera guardada la IP antigua de la instancia, y qué te dice eso sobre por qué nunca se debe dar a los usuarios una dirección que apunte directamente a una instancia?

---

## Parte B — Provoca el fallo y mide el escalado (reto)

**Termina una instancia a mano**, sin avisar a nadie, mientras la encuesta sigue en marcha. No hay procedimiento dado: decide tú cómo vas a observar la reposición automática y qué evidencia vas a capturar para demostrar que ha ocurrido sin intervención tuya.

**Genera carga real** contra el endpoint `/carga` hasta forzar que el grupo de escalado automático añada una instancia nueva por encima de la capacidad deseada, y mide con precisión el tiempo transcurrido desde que la métrica de CPU supera el umbral hasta que esa instancia nueva empieza a atender tráfico de verdad a través del balanceador. Representa esa curva de escalado con los datos reales que hayas recogido, no con una estimación.

**Comprueba**: que, tras terminar la instancia a mano, el grupo vuelve a tener exactamente el número de instancias saludables de su capacidad deseada, sin que hayas lanzado tú ninguna manualmente.

**Captura**: el momento en que terminas la instancia y el momento en que el grupo la ha repuesto; la curva de escalado con los tiempos reales medidos durante la generación de carga.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Plantilla de lanzamiento propia, con user data funcionando | 1 |
| Balanceador y grupo de destino configurados con comprobación de salud | 2 |
| Grupo de escalado automático funcionando con dos instancias en dos zonas | 2 |
| Reparto de tráfico comprobado con evidencia real | 2 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Reposición automática tras terminar una instancia, demostrada | 2 |
| Curva de escalado por carga medida con tiempos reales | 1 |

---

## ✅ Cierre

Encuestas en Vivo ya no depende de una única instancia: si una cae, el grupo repone otra sin que nadie tenga que intervenir, y si sube el tráfico durante el evento, el sistema escala dentro de los límites que has definido. La próxima sesión resuelves el siguiente punto débil de esta misma arquitectura: el dominio y el certificado, que hasta ahora siguen dependiendo de una URL genérica de AWS sin HTTPS propio.

!!! warning "No apagues nada todavía"
    A diferencia del resto de actividades del módulo, hoy **no** termines el balanceador de carga ni el grupo de escalado al salir — la Actividad 4.2 de la próxima sesión los necesita en marcha, con sus instancias respondiendo. Es la única excepción del módulo: normalmente el cierre te pide apagar lo que no vayas a necesitar más, pero aquí es justo lo contrario. La limpieza de estos recursos llega al final de la 4.2.
