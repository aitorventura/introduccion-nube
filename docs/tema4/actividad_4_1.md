# 🧪 Actividad 4.1: Balanceador de carga y Auto Scaling Group

!!! warning "Descarga la plantilla"
    📄 [Plantilla 4.1 — Balanceador de carga y Auto Scaling Group](plantillas/Actividad_4_1_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

El primer punto único de fallo de tu lista de la sesión pasada era la instancia única de la aplicación. Hoy lo eliminas: pones un balanceador delante de dos instancias en dos zonas distintas, y un grupo de escalado automático que repone lo que se caiga sin que tú intervengas.

## Qué vas a practicar

- Crear un balanceador de carga con su grupo de destino y comprobación de salud.
- Configurar un grupo de escalado automático usando la plantilla de lanzamiento del Tema 2.
- Comprobar el reparto real de tráfico entre instancias.
- Medir el tiempo real de reposición automática y de escalado por carga.

## Requisitos previos

La plantilla de lanzamiento de la Actividad 2.3, y la arquitectura completa de la Actividad 3.3. El apunte de esta sesión — «Balanceo de carga y escalado automático» (alta-disponibilidad-escalado.md).

---

## Parte A — Balanceador y escalado automático (guiada)

### Paso 1 — Crea el balanceador y el grupo de destino desde la consola

1. Busca "EC2" en el buscador de servicios → menú lateral **Balanceadores de carga** → **Crear balanceador de carga**.
2. Elige **Balanceador de carga de aplicación**.
3. Dale un nombre, esquema **Con acceso a internet**, y selecciona tu VPC con sus dos subredes públicas.
4. En **Listeners y enrutamiento**, en lugar de un grupo de destino existente, haz clic en **Crear grupo de destino**:
    1. Tipo de destino: **Instancias**.
    2. Protocolo/puerto: el de tu aplicación (por ejemplo HTTP 80).
    3. En **Comprobaciones de estado**, cambia la ruta a `/api/salud`.
    4. Crea el grupo de destino (todavía sin instancias registradas).
5. Vuelve al asistente del balanceador, selecciona el grupo de destino recién creado, y haz clic en **Crear balanceador de carga**.

![Balanceador creado, con su listener apuntando al grupo de destino y su comprobación de salud en /api/salud](img/actividad_4_1_paso1.png)

**Comprueba**: que el grupo de destino aparece vacío por ahora (todavía no tienes instancias registradas) y que el balanceador está `active`.
**Captura**: `img/actividad_4_1_paso1.png`.

### Paso 2 — Crea el grupo de escalado automático por CLI

Crea el grupo de escalado automático por CLI, usando tu plantilla de lanzamiento del Tema 2, con capacidad mínima 2, deseada 2 y máxima 4, en las dos zonas de tu VPC, asociado al grupo de destino del Paso 1:

```bash
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name escaparate-asg-<tu-identificador> \
  --launch-template LaunchTemplateName=escaparate-lt-<tu-identificador> \
  --min-size 2 --desired-capacity 2 --max-size 4 \
  --target-group-arns <target-group-arn> \
  --vpc-zone-identifier "<subnet-publica-a>,<subnet-publica-b>"
```

Comprueba el resultado en consola: entra en tu grupo de destino, pestaña **Destinos registrados**.

![Grupo de destino con dos instancias en estado healthy, una por zona](img/actividad_4_1_paso2.png)

**Comprueba**: que al cabo de unos minutos, el grupo de destino del balanceador muestra dos instancias en estado `healthy`, una en cada zona.
**Captura**: `img/actividad_4_1_paso2.png`.

### Paso 3 — Comprueba el reparto real de tráfico

Consulta el endpoint `/api/instancia` del catálogo a través de la URL del balanceador varias veces seguidas, y observa qué identificador de instancia responde en cada petición.

**Comprueba**: que el identificador de instancia cambia entre peticiones sucesivas, señal de que el balanceador está repartiendo el tráfico entre las dos.
**Captura**: al menos cuatro peticiones consecutivas al endpoint, mostrando identificadores distintos.

!!! question "Reflexiona"
    Antes de esta sesión, la URL que usaba cualquier visitante de Escaparate era la IP pública de una instancia concreta. Ahora es la del balanceador. ¿Qué le pasa a un visitante que tuviera guardada la IP antigua de la instancia, y qué te dice eso sobre por qué nunca se debe dar a los usuarios una dirección que apunte directamente a una instancia?

---

## Parte B — Provoca el fallo y mide el escalado (reto)

**Termina una instancia a mano**, sin avisar a nadie, mientras el catálogo sigue en marcha. No hay procedimiento dado: decide tú cómo vas a observar la reposición automática y qué evidencia vas a capturar para demostrar que ha ocurrido sin intervención tuya.

**Genera carga real** contra el endpoint `/api/carga` hasta forzar que el grupo de escalado automático añada una instancia nueva por encima de la capacidad deseada, y mide con precisión el tiempo transcurrido desde que la métrica de CPU supera el umbral hasta que esa instancia nueva empieza a atender tráfico de verdad a través del balanceador. Representa esa curva de escalado con los datos reales que hayas recogido, no con una estimación.

**Comprueba**: que, tras terminar la instancia a mano, el grupo vuelve a tener exactamente el número de instancias saludables de su capacidad deseada, sin que hayas lanzado tú ninguna manualmente.
**Captura**: el momento en que terminas la instancia y el momento en que el grupo la ha repuesto; la curva de escalado con los tiempos reales medidos durante la generación de carga.

---

## Verificación

Para dar por válida la práctica se ejecutará:

```bash
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names escaparate-asg-<tu-identificador>
```

Y debe observarse: el grupo de destino con el número de instancias saludables igual a la capacidad deseada, y el historial de actividad del grupo de escalado mostrando al menos un evento de reposición y uno de escalado por carga.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Balanceador y grupo de destino configurados con comprobación de salud | 2 |
| Grupo de escalado automático funcionando con dos instancias en dos zonas | 2 |
| Reparto de tráfico comprobado con evidencia real | 2 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Reposición automática tras terminar una instancia, demostrada | 2 |
| Curva de escalado por carga medida con tiempos reales | 1 |

---

## ✅ Cierre

Ya no depende de una única instancia: si una cae, el grupo repone otra sin que nadie tenga que intervenir, y si sube el tráfico, el sistema escala dentro de los límites que has definido. La próxima sesión resuelves el siguiente punto único de fallo de tu lista: el dominio y el certificado, que hasta ahora siguen dependiendo de una URL genérica de AWS sin HTTPS propio.
