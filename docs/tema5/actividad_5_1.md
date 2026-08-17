# 🧪 Actividad 5.1: Monitorización y diagnóstico con CloudWatch

!!! warning "Descarga la plantilla"
    📄 [Plantilla 5.1 — Monitorización y diagnóstico con CloudWatch](plantillas/Actividad_5_1_INU_Plantilla.docx){target="_blank" rel="noopener"}

!!! warning "Descarga los recursos"
    📦 [Recursos de la Actividad 5.1](recursos/actividad_5_1_recursos.zip){target="_blank" rel="noopener"} — descomprímelo donde vayas a abrir `arranque-entradas.sh` con un editor de texto, para copiar su contenido en el Paso 1.

## Contexto

El servidor de Entradas —una aplicación de venta de entradas para conciertos— va a estar en marcha sin que nadie lo mire constantemente. Si algo falla a las tres de la madrugada, cuando se abre la venta de un concierto muy esperado, nadie está delante de una pantalla viéndolo en directo. Hoy montas el panel que te avisa cuando algo falla sin que tengas que estar mirando, y después diagnosticas una incidencia real usando solo lo que ese panel te cuenta — sin conectarte a ninguna instancia a mirar por dentro.

## Qué vas a practicar

- Desplegar un recurso mínimo y construir un panel de CloudWatch sobre él.
- Diseñar tres alarmas que de verdad importen, no veinte que generen ruido.
- Diagnosticar una incidencia real usando solo métricas y registros, sin acceso directo al servidor.

## Requisitos previos

Acceso a tu Learner Lab. Los ficheros de la aplicación de Entradas (`app.py`, `requirements.txt`, `arranque-entradas.sh`) — descárgalos del enlace de arriba, no los programas tú. Si ya tienes una instancia en marcha de otra actividad (por ejemplo la Actividad 4.1) puedes reutilizarla para esta sesión, pero no es obligatorio. Los apuntes de esta sesión — [«Monitorización y operación»](monitorizacion-operacion.md).

---

## Parte A — Panel y tres alarmas (guiada)

### Paso 1 — Lanza la instancia de Entradas desde la consola

1. Busca "EC2" en el buscador de servicios → **Instancias** → **Lanzar instancia**.
2. Dale un nombre, por ejemplo `entradas-<tu-identificador>`.
3. Elige una AMI de Amazon Linux 2023, y el tipo `t3.micro`.
4. En **Configuración de red**, elige tu subred pública, con **Asignar IP pública automáticamente** en **Habilitar**, y un grupo de seguridad con el puerto 80 abierto y el 22 restringido a tu IP.
5. Despliega **Detalles avanzados**, baja hasta **Datos de usuario**, y pega ahí el contenido completo de `arranque-entradas.sh` — el script vive en `recursos/tema5/actividad_5_1/arranque-entradas.sh`.
6. Lanza la instancia.

![Entradas respondiendo en el navegador, con el catálogo de conciertos](img/actividad_5_1_paso1.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_5_1_paso1.png`*

**Comprueba**: que la IP pública de la instancia responde en el puerto 80 con el catálogo de conciertos de Entradas, al cabo de un par de minutos.

**Captura**: tu propia instancia de Entradas respondiendo en el navegador, con el catálogo de conciertos.

### Paso 2 — Construye el panel desde la consola

1. Busca "CloudWatch" en el buscador de servicios → menú lateral **Panel de control** → **Crear panel**.
2. Dale un nombre (por ejemplo `entradas-panel-<tu-identificador>`).
3. Añade un widget de línea → elige la métrica **CPUUtilization** de tu instancia (namespace `AWS/EC2`).
4. Añade un segundo widget → métrica **StatusCheckFailed** de la misma instancia.
5. Añade un tercer widget → métrica **NetworkIn** o **NetworkOut** de la misma instancia.
6. Guarda el panel.

![Panel de CloudWatch con los tres widgets mostrando actividad real](img/actividad_5_1_paso2.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_5_1_paso2.png`*

**Comprueba**: que el panel muestra datos reales de las últimas horas para cada widget, no gráficas vacías.

**Captura**: tu propio panel de CloudWatch con los tres widgets mostrando actividad real.

### Paso 3 — Crea dos alarmas

Crea una alarma de CPU sostenida (por ejemplo, por encima del 80 % durante 5 minutos) sobre tu instancia, y otra sobre el estado de la comprobación de salud de la instancia. Por consola: CloudWatch → **Alarmas** → **Crear alarma** → elige la métrica, el umbral y el periodo. Por CLI, las dos en dos comandos seguidos:

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name entradas-cpu-alta-<tu-identificador> \
  --metric-name CPUUtilization --namespace AWS/EC2 \
  --statistic Average --period 300 --threshold 80 \
  --comparison-operator GreaterThanThreshold --evaluation-periods 1 \
  --dimensions Name=InstanceId,Value=<instance-id>
```

Comprueba el resultado en consola: CloudWatch → **Alarmas**.

![Las dos alarmas listadas con su estado y su umbral configurado](img/actividad_5_1_paso3.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_5_1_paso3.png`*

**Comprueba**: que ambas alarmas aparecen en estado `OK` (o `ALARM` si de verdad hay carga en ese momento), no en estado de datos insuficientes.

**Captura**: tus propias alarmas listadas, con su estado y su umbral configurado.

### Paso 4 — Localiza dónde controlar el gasto acumulado

!!! warning "Comprueba esto antes de la sesión"
    Igual que en la sesión 1, una alarma de gasto acumulado con CloudWatch/Budgets no está garantizada en todos los Learner Lab.

Si tu laboratorio lo permite: busca "Administración de facturación y costos" → **Presupuestos y planificación** → **Presupuestos** → crea o revisa el presupuesto de la sesión 1, y añádele si no la tenía una alarma sobre el gasto estimado del mes.

Si no te deja: entra en el panel de tu Learner Lab (fuera de la consola de AWS) y documenta con precisión dónde consultas el gasto acumulado, y qué umbral usarías como referencia para saber que te estás acercando al límite.

![Alarma de gasto acumulado, o panel de crédito del Learner Lab](img/actividad_5_1_paso4.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_5_1_paso4.png`*

**Comprueba**: que sabes decir, sin dudar, qué vas a mirar para saber si te estás acercando al límite de crédito del laboratorio.

**Captura**: tu propia alarma de gasto acumulado, o el panel de crédito del Learner Lab, según tu caso.

!!! question "Reflexiona"
    De las tres alarmas, ¿cuál te habría avisado antes de un problema real y cuál solo te lo habría confirmado después de que ya hubiera pasado? No todas las alarmas son igual de útiles como aviso temprano.

---

## Parte B — Diagnóstico sin acceso directo al servidor (reto)

El profesor va a introducir una incidencia real sobre tu instancia de Entradas —puede ser el proceso de la aplicación caído, una comprobación de salud mal configurada, o un fallo de permisos— sin decirte cuál de las tres es. No te conectes a la instancia por SSH a mirar por dentro: diagnostica **solo** con las métricas y los registros que ya tienes disponibles en el panel y en CloudWatch Logs.

Documenta tu proceso completo, no solo la conclusión: qué has mirado primero y por qué, qué descartaste y por qué, y qué evidencia concreta te ha llevado a identificar la causa real. Corrige la incidencia, y **crea la alarma que la habría detectado antes** de que tú tuvieras que ponerte a buscar — si esa alarma hubiera existido desde el principio, ¿te habría avisado antes de que un usuario notara el problema?

**Comprueba**: que, tras tu corrección, la aplicación vuelve a comportarse con normalidad, y que la alarma nueva se dispara si reproduces el mismo fallo.

**Captura**: tu proceso de diagnóstico documentado paso a paso, la corrección aplicada, y la alarma nueva configurada.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Instancia de Entradas desplegada, con la aplicación funcionando | 1 |
| Panel con las tres métricas de la instancia | 1 |
| Alarmas de CPU y de comprobación de salud configuradas y funcionando | 3 |
| Gasto acumulado localizado o alarmado, según lo permita el Lab | 2 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Incidencia diagnosticada solo con métricas y registros, proceso documentado | 2 |
| Alarma nueva creada, que habría detectado la incidencia antes | 1 |

---

## ✅ Cierre

Ya sabes diagnosticar sin mirar por dentro de una instancia — la habilidad que de verdad importa cuando una arquitectura escala sola y las instancias van y vienen. La próxima sesión te toca la otra mitad de la gobernanza: quién puede tocar qué, y cómo verificarlo antes de que sea un problema.

!!! danger "Antes de salir: borra la instancia de Entradas"
    Termina la instancia (`entradas-...`, o la que hayas reutilizado de otra actividad) — no le sirve a ninguna actividad posterior. El panel de CloudWatch y las alarmas no tienen coste por existir, puedes dejarlos tal cual.
