# 🧪 Actividad 5.3: Cuánto cuesta lo que has construido

!!! warning "Descarga la plantilla"
    📄 [Plantilla 5.3 — Cuánto cuesta lo que has construido](plantillas/Actividad_5_3_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

Desde el Tema 2 has ido lanzando instancias, bases de datos, balanceadores y buckets sin pararte a poner un número encima — solo a apagar lo que no hacía falta al cerrar cada sesión. Hoy inviertes el orden: antes de que el Tema 6 empiece a reconstruir infraestructura desde cero con código, le pones precio real a la arquitectura concreta que **tú** has construido hasta ahora — no una arquitectura de ejemplo, la tuya, con las decisiones que has tomado en cada actividad (qué tamaño de instancia, cuánta RDS, si terminaste en S3 o si algo de EFS se te quedó atrás sin querer).

## Qué vas a practicar

- Desglosar tu arquitectura en los componentes que AWS factura por separado.
- Estimar el coste real de cada componente con la calculadora oficial de AWS.
- Sumar un coste mensual y anual total, y compararlo con el crédito que te queda en el Lab.
- Aplicar una palanca de optimización real sobre un recurso tuyo que ya no se usa.
- Aplicar el criterio de las 6 R de la migración a un caso ajeno, por escrito.

## Requisitos previos

El balanceador, el grupo de escalado, la RDS y el bucket de imágenes en S3 de la 5.2 (si has pausado los recursos al cerrar esa actividad, repite el Paso 0 de la 5.1 para reactivarlos: mismo `recrear-alb.sh`, misma RDS, mismo ASG a capacidad 2). El bucket S3 del frontend de la 3.3. No hace falta desplegar nada nuevo — la actividad de hoy es de estimación, no de construcción. Acceso a la [calculadora de precios oficial de AWS](https://calculator.aws) y al panel **AWS Details** de tu Learner Lab (donde ves el crédito restante). Los apuntes de esta sesión — [«Economía de la nube»](economia-nube.md).

---

## Parte A — Desglosa y calcula el coste real de tu arquitectura (guiada)

### Paso 1 — Lista tus componentes facturables

Antes de abrir la calculadora, escribe la lista completa de lo que tu arquitectura tiene desplegado ahora mismo, con su configuración exacta — no genérica, la tuya:

- **EC2**: tipo de instancia y cuántas réplicas mantiene tu grupo de escalado.
- **Balanceador de carga**: cuál usas (Application Load Balancer).
- **RDS**: motor, clase de instancia y GB de almacenamiento asignado.
- **S3**: el bucket de imágenes de la 5.2 y el bucket del frontend de la 3.3 — GB aproximados en cada uno.
- **Tráfico estimado**: cuántas peticiones y cuánta transferencia de salida generas en una sesión de pruebas típica, multiplicado por las veces que pruebas tu aplicación en un mes.

Si algo de esta lista ya no existe porque lo borraste al cerrar una sesión anterior, anótalo también como "actualmente apagado" — lo vas a necesitar en el Paso 3.

**Comprueba**: que tu lista cubre, como mínimo, los cinco puntos de arriba con valores concretos (no "una instancia", sino "un `t3.micro`").

**Captura**: no aplica en este paso — la lista es la base escrita que vas a usar en el Paso 2, entrégala junto con el resto.

### Paso 2 — Estima cada componente con la calculadora oficial

1. Entra en [calculator.aws](https://calculator.aws) y crea una estimación nueva.
2. Añade **un servicio por cada línea de tu lista del Paso 1**, con la configuración real que has anotado — región **US East (N. Virginia)**, la misma donde tiene todo tu Learner Lab.
3. Para el tráfico, usa tu estimación del Paso 1 tal cual, aunque sea aproximada — lo importante es que la cifra salga de un cálculo tuyo, no de un valor por defecto que no has tocado.

**Comprueba**: que la estimación tiene una línea por cada componente de tu lista, y que el resumen final muestra un coste mensual y un coste anual total.

**Captura**: cada línea de la calculadora con su coste individual, y el resumen final con el total mensual y anual.

### Paso 3 — Compara tu estimación con el crédito real del Lab

El Learner Lab no te factura como a una cuenta personal, pero el crédito que te queda sí es un número real y limitado — es una buena referencia para lo que acabas de calcular.

1. Abre el panel **AWS Details** de tu Learner Lab y anota el crédito restante.
2. Divide ese crédito entre el coste **mensual** que ha salido en el Paso 2.

**Pregunta**: si esta arquitectura estuviera en una cuenta personal de verdad (no en el Lab), ¿cuántos meses aguantaría funcionando con el crédito que te queda ahora mismo? ¿Te sorprende el resultado, por arriba o por abajo?

**Comprueba**: que el cálculo usa el crédito restante real de tu Lab, no una cifra inventada.

**Captura**: el crédito restante en el panel AWS Details, junto a tu cálculo de meses.

---

## Parte B — Reto: optimiza de verdad y aplica las 6 R a un caso ajeno (reto)

- **Encuentra y elimina un coste que ya no debería existir**: comprueba si el sistema de ficheros EFS que usabas antes de migrar a S3 en la Actividad 5.2 sigue existiendo. Es muy probable que sí — nadie te pidió borrarlo entonces, porque otra actividad podía necesitarlo todavía. Ya no es el caso.

    - Si **sigue existiendo**: añádelo a tu estimación de la calculadora con su tamaño real, apunta cuánto te está costando mantenerlo sin usarlo desde la 5.2, y bórralo de verdad desde la consola de EFS. Vuelve a calcular tu coste mensual total sin él.
    - Si **ya no existe** (lo borraste en algún cierre anterior): confirma que ha desaparecido de la consola y explica en una frase por qué borrarlo fue la decisión correcta en su momento, aplicando la primera palanca de optimización de la teoría de hoy.

    **Captura**: la consola de EFS mostrando que el sistema de ficheros ya no existe (tanto si lo acabas de borrar como si ya no estaba), y tu coste mensual recalculado sin esa partida.

- **Aplica las 6 R a un caso que no es el tuyo**: una tienda de barrio lleva quince años usando una aplicación de gestión de inventario instalada en un único ordenador de la trastienda. Funciona, pero solo la puede usar quien esté delante de esa máquina, no tiene copias de seguridad automáticas, y el ordenador ya ha fallado dos veces este año. El dueño quiere "llevarlo a la nube", pero no tiene presupuesto para rehacer la aplicación desde cero ni tiempo que perder si algo sale mal durante el cambio.

    Elige **una** de las 6 R de la migración para este caso — no la que suene más avanzada técnicamente, la que de verdad resuelve su problema con el esfuerzo justificado — y explica por escrito:

    1. Qué estrategia has elegido y por qué encaja mejor que las otras cinco en esta situación concreta.
    2. Qué cambia técnicamente con tu elección (qué se mueve, qué se queda igual).
    3. Qué problema de los que tiene ahora mismo (disponibilidad, copias de seguridad, punto único de fallo) queda resuelto, y cuál **no** queda resuelto todavía con solo esa estrategia.

    **Captura**: no aplica — este reto se entrega como documento de texto, no como captura de consola.

**Entrega**: tu estimación completa de la calculadora (con y sin el EFS, si lo tenías), el cálculo de meses de crédito, y tu elección justificada de una de las 6 R para el caso de la tienda.

---

## Criterios de evaluación

**Parte A — hasta 6 puntos**

| Apartado | Puntos |
|---|---|
| Lista de componentes completa y con configuración real, no genérica | 1 |
| Estimación en la calculadora con una línea por componente y coste mensual/anual visible | 3 |
| Cálculo de meses de crédito del Lab, con el crédito restante real documentado | 2 |

**Parte B — reto, hasta 4 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| EFS comprobado y, si procedía, eliminado con el coste recalculado | 2 |
| Elección de una de las 6 R para el caso de la tienda, justificada y con sus tres puntos razonados | 2 |

---

## ✅ Cierre

Ya sabes poner un número real a lo que construyes antes de construirlo, no solo después de ver la factura — y has usado ese mismo criterio para decidir qué de lo que ya tenías desplegado no debía seguir encendido. Es el mismo razonamiento de las 6 R que acabas de aplicar a un caso ajeno: la solución correcta no es la más sofisticada, es la que resuelve el problema con el esfuerzo justificado.

!!! danger "Antes de salir: qué hacer con lo de hoy"
    Esta es la última actividad del Tema 5 — el Tema 6 construye su propia infraestructura desde cero con código, así que no necesitas mantener nada de esto encendido mientras tanto.

    1. Si no lo has hecho ya en el reto: borra el sistema de ficheros EFS.
    2. Baja el grupo de escalado a capacidad 0, borra el balanceador y el grupo de destino (`recrear-alb.sh` te lo vuelve a montar en un par de minutos si lo necesitas más adelante).
    3. Detén o borra la RDS.
    4. Los buckets S3 (frontend e imágenes) puedes dejarlos — su coste es mínimo y el Tema 6 puede seguir usándolos.
