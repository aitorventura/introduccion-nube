# 🧪 Actividad 2.2: Diagnóstico de fallos de red por capas

!!! warning "Descarga la plantilla"
    📄 [Plantilla 2.2 — Diagnóstico de fallos de red por capas](plantillas/Actividad_2_2_INU_Plantilla.docx){target="_blank" rel="noopener"}

!!! warning "Descarga los recursos"
    📦 [Recursos de la Actividad 2.2](recursos/actividad_2_2_recursos.zip){target="_blank" rel="noopener"} — descomprímelo en la raíz de tu proyecto: crea la carpeta `recursos/tema2/actividad_2_2/`, la misma ruta que usan los pasos de esta actividad.

## Contexto

Sobre la VPC que construiste la sesión pasada vas a levantar hoy una instancia pública con un servidor web y una instancia privada solo alcanzable desde ella — el servidor de un tablón de anuncios municipal. Y luego, sin previo aviso, esa misma red va a dejar de funcionar: cuatro averías reales, preparadas de antemano, que tienes que diagnosticar contrarreloj.

## Qué vas a practicar

- Levantar una instancia pública que arranca su propio servidor web sin que tengas que conectarte a mano.
- Aislar una instancia privada, accesible solo desde la pública.
- Diagnosticar fallos de red de fuera hacia dentro, capa a capa, sin dar palos de ciego.
- Calcular el coste mensual real de una pasarela NAT.

## Requisitos previos

La VPC de dos zonas de la Actividad 2.1, con sus subredes públicas y privadas ya creadas. El apunte de esta sesión — «Seguridad de red» (seguridad-red.md).

---

## Parte A — Instancia pública y privada (guiada)

### Paso 1 — Lanza la instancia pública desde la consola

1. Busca "EC2" en el buscador de servicios → **Instancias** → **Lanzar instancia**.
2. Dale un nombre (por ejemplo `tablon-publica-<tu-identificador>`).
3. Elige la imagen (AMI) que te indique el profesor, y el tipo `t3.micro`.
4. En **Configuración de red**, elige tu VPC y tu subred pública, y asegúrate de que **Asignar IP pública automáticamente** está en **Habilitar**.
5. En el propio asistente, crea un grupo de seguridad nuevo con solo dos reglas: puerto 80 abierto a `0.0.0.0/0`, y puerto 22 restringido a tu propia IP (usa la opción "Mi IP" del desplegable de origen).
6. Despliega **Detalles avanzados**, baja hasta el campo **Datos de usuario** (*user data*), y pega ahí el contenido completo de `arranque-servidor.sh` — el script vive en `recursos/tema2/actividad_2_2/arranque-servidor.sh`, dentro del zip que has descargado arriba.
7. Haz clic en **Lanzar instancia**.

![Asistente de lanzamiento con el grupo de seguridad y el campo de user data rellenados](img/actividad_2_2_paso1_a.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_2_2_paso1_a.png`*

El script `arranque-servidor.sh` instala y arranca, al primer arranque de la instancia, un servidor web mínimo con la página del tablón de anuncios — sin intervención tuya. Espera un par de minutos y prueba la IP pública de la instancia en el navegador.

![El servidor web respondiendo en el navegador, sin haberte conectado por SSH](img/actividad_2_2_paso1_b.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_2_2_paso1_b.png`*

**Comprueba**: que la IP pública de la instancia responde en el puerto 80 desde tu navegador, sin haberte conectado nunca por SSH.

**Captura**: tu propio asistente de lanzamiento con el grupo de seguridad y el user data rellenados, y el servidor web respondiendo en el navegador sin haberte conectado por SSH.

### Paso 2 — Lanza la instancia privada por CLI

Lanza una segunda instancia en tu subred privada, esta vez por CLI. Su grupo de seguridad no debe permitir tráfico desde `0.0.0.0/0` en ningún puerto — solo desde el grupo de seguridad de la instancia pública:

```bash
aws ec2 run-instances \
  --image-id <ami-id> \
  --subnet-id <subnet-privada-id> \
  --security-group-ids <sg-privado-id>
```

**Comprueba**: conéctate primero a la instancia pública, y desde ahí intenta llegar a la instancia privada — debe funcionar. Comprueba también que la instancia privada no tiene IP pública asignada.

**Captura**: la conexión exitosa desde la instancia pública hacia la privada, y la ausencia de IP pública en la instancia privada.

---

## Parte B — Diagnóstico de las cuatro averías (reto)

El profesor va a introducir, sobre tu propia red o sobre una preparada para el ejercicio, **cuatro averías** independientes: una ruta incorrecta en una tabla de rutas, un grupo de seguridad cerrado donde no debería estarlo, una regla de NACL bloqueante, y una instancia parada. La red deja de responder como se espera, y no sabes de antemano cuál de las cuatro capas está fallando.

Diagnostica **de fuera hacia dentro**, sin saltarte capas: primero comprueba si la instancia está en marcha, luego la tabla de rutas de la subred, luego la NACL, y por último el grupo de seguridad. Para cada avería que encuentres, documenta por escrito:

1. Qué síntoma has observado (qué esperabas y qué ha pasado en realidad).
2. Qué capa has revisado primero y por qué esa y no otra.
3. Qué comando o comprobación te ha llevado a localizar el problema exacto.
4. Cómo lo has corregido.

Cuando tengas las cuatro averías resueltas, añade una pasarela NAT a tu VPC (si no la tenías ya) y **calcula su coste mensual estimado** con la calculadora oficial de AWS, a partir del precio por hora y una estimación razonable de GB de tráfico saliente de tus instancias privadas.

**Comprueba**: que, tras corregir las cuatro averías, la red vuelve a comportarse exactamente como en la Parte A.

**Captura**: las cuatro fichas de diagnóstico (síntoma, capa revisada, comando usado, corrección aplicada), y el desglose de coste mensual de la pasarela NAT.

!!! question "Reflexiona"
    De las cuatro averías, ¿cuál has confundido primero con otra capa distinta a la que realmente era? Un grupo de seguridad cerrado y una NACL bloqueante producen síntomas muy parecidos desde fuera. ¿Qué comprobación concreta es la que de verdad distingue una de la otra?

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Instancia pública con servidor web automático (user data) y grupo mínimo | 3 |
| Instancia privada accesible solo desde la pública | 4 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Las cuatro averías diagnosticadas y corregidas, con razonamiento documentado | 2 |
| Coste mensual de la pasarela NAT calculado y justificado | 1 |

---

## ✅ Cierre

Ya sabes diagnosticar una red de fuera hacia dentro, capa a capa, en vez de cambiar cosas al azar hasta que funcione — es la habilidad que más vas a usar el resto del curso cada vez que algo no responda como esperabas. La próxima sesión dejas de crear instancias a mano, una a una: vas a automatizar su lanzamiento con plantillas, para no repetir este mismo proceso cada vez que necesites una máquina más.

!!! danger "Antes de salir: borra las instancias y la pasarela NAT si la has creado"
    Termina las dos instancias EC2 de hoy (la pública del tablón y la privada) — la Actividad 2.3 lanza una instancia nueva, no reutiliza estas. Si has hecho la Parte B, borra también la pasarela NAT: es el recurso más caro de toda la sesión, factura por hora exista o no tráfico, y no le sirve a nadie después de hoy. **No borres la VPC, las subredes ni las tablas de rutas** — las sigue necesitando el resto del módulo.
