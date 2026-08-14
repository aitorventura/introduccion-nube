# 🧪 Actividad 5.1: Monitorización y diagnóstico con CloudWatch

!!! warning "Descarga la plantilla"
    📄 [Plantilla 5.1 — Monitorización y diagnóstico con CloudWatch](plantillas/Actividad_5_1_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

Escaparate lleva varias semanas creciendo en piezas, y hasta ahora has comprobado que cada una funciona mirándola directamente. Hoy montas el panel que te avisa cuando algo falla sin que tengas que estar mirando, y después diagnosticas una incidencia real usando solo lo que ese panel te cuenta — sin conectarte a ninguna instancia a mirar por dentro.

## Qué vas a practicar

- Construir un panel con la arquitectura completa del curso.
- Diseñar tres alarmas que de verdad importen, no veinte que generen ruido.
- Diagnosticar una incidencia real usando solo métricas y registros, sin acceso directo al servidor.

## Requisitos previos

La arquitectura completa de las Actividades 3.3 y 4.1. El apunte de esta sesión — «Monitorización y operación» (monitorizacion-operacion.md).

---

## Parte A — Panel y tres alarmas (guiada)

### Paso 1 — Construye el panel desde la consola

1. Busca "CloudWatch" en el buscador de servicios → menú lateral **Panel de control** → **Crear panel**.
2. Dale un nombre (por ejemplo `escaparate-panel-<tu-identificador>`).
3. Añade un widget de línea → elige la métrica **CPUUtilization** de tu grupo de escalado automático (namespace `AWS/EC2` o `AWS/AutoScaling`).
4. Añade un segundo widget → métricas `RequestCount` y `HTTPCode_Target_5XX_Count` de tu balanceador de carga.
5. Añade un tercer widget → métrica `DatabaseConnections` de tu instancia RDS.
6. Guarda el panel.

![Panel de CloudWatch con los tres widgets mostrando actividad real](img/actividad_5_1_paso1.png)

**Comprueba**: que el panel muestra datos reales de las últimas horas para cada widget, no gráficas vacías.
**Captura**: `img/actividad_5_1_paso1.png`.

### Paso 2 — Crea dos alarmas por CLI

Crea por CLI una alarma de CPU sostenida (por ejemplo, por encima del 80 % durante 5 minutos) sobre tu grupo de escalado automático, y otra de errores 5xx del balanceador por encima de un umbral razonable:

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name escaparate-cpu-alta-<tu-identificador> \
  --metric-name CPUUtilization --namespace AWS/EC2 \
  --statistic Average --period 300 --threshold 80 \
  --comparison-operator GreaterThanThreshold --evaluation-periods 1 \
  --dimensions Name=AutoScalingGroupName,Value=escaparate-asg-<tu-identificador>
```

Comprueba el resultado en consola: CloudWatch → **Alarmas**.

![Las dos alarmas listadas con su estado y su umbral configurado](img/actividad_5_1_paso2.png)

**Comprueba**: que ambas alarmas aparecen en estado `OK` (o `ALARM` si de verdad hay carga en ese momento), no en estado de datos insuficientes.
**Captura**: `img/actividad_5_1_paso2.png`.

### Paso 3 — Localiza dónde controlar el gasto acumulado

!!! warning "Comprueba esto antes de la sesión"
    Igual que en la sesión 1, una alarma de gasto acumulado con CloudWatch/Budgets no está garantizada en todos los Learner Lab.

Si tu laboratorio lo permite: busca "Billing and Cost Management" → **Budgets** → crea o revisa el presupuesto de la sesión 1, y añádele si no la tenía una alarma sobre el gasto estimado del mes.

Si no te deja: entra en el panel de tu Learner Lab (fuera de la consola de AWS) y documenta con precisión dónde consultas el gasto acumulado, y qué umbral usarías como referencia para saber que te estás acercando al límite.

![Alarma de gasto acumulado, o panel de crédito del Learner Lab](img/actividad_5_1_paso3.png)

**Comprueba**: que sabes decir, sin dudar, qué vas a mirar para saber si te estás acercando al límite de crédito del laboratorio.
**Captura**: `img/actividad_5_1_paso3.png`.

!!! question "Reflexiona"
    De las tres alarmas, ¿cuál te habría avisado antes de un problema real y cuál solo te lo habría confirmado después de que ya hubiera pasado? No todas las alarmas son igual de útiles como aviso temprano.

---

## Parte B — Diagnóstico sin acceso directo al servidor (reto)

El profesor va a introducir una incidencia real sobre tu arquitectura —puede ser una capa caída, una comprobación de salud mal configurada, o un fallo de permisos— sin decirte cuál de las tres es. No te conectes a ninguna instancia por SSH a mirar por dentro: diagnostica **solo** con las métricas y los registros que ya tienes disponibles en el panel y en CloudWatch Logs.

Documenta tu proceso completo, no solo la conclusión: qué has mirado primero y por qué, qué descartaste y por qué, y qué evidencia concreta te ha llevado a identificar la causa real. Corrige la incidencia, y **crea la alarma que la habría detectado antes** de que tú tuvieras que ponerte a buscar — si esa alarma hubiera existido desde el principio, ¿te habría avisado antes de que un usuario notara el problema?

**Comprueba**: que, tras tu corrección, la arquitectura vuelve a comportarse con normalidad, y que la alarma nueva se dispara si reproduces el mismo fallo.
**Captura**: tu proceso de diagnóstico documentado paso a paso, la corrección aplicada, y la alarma nueva configurada.

---

## Verificación

Para dar por válida la práctica se ejecutará:

```bash
aws cloudwatch describe-alarms --alarm-name-prefix escaparate
aws cloudwatch get-dashboard --dashboard-name <tu-panel>
```

Y debe observarse: al menos tres alarmas configuradas con umbrales razonables, el panel con las cuatro métricas de arquitectura, y la documentación del proceso de diagnóstico con la causa real identificada y corregida.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Panel con las métricas de las tres capas de la arquitectura | 2 |
| Alarmas de CPU y errores 5xx configuradas y funcionando | 2 |
| Gasto acumulado localizado o alarmado, según lo permita el Lab | 2 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Incidencia diagnosticada solo con métricas y registros, proceso documentado | 2 |
| Alarma nueva creada, que habría detectado la incidencia antes | 1 |

---

## ✅ Cierre

Ya sabes diagnosticar sin mirar por dentro de una instancia — la habilidad que de verdad importa cuando la arquitectura escala sola y las instancias van y vienen. La próxima sesión te toca la otra mitad de la gobernanza: quién puede tocar qué, y cómo verificarlo antes de que sea un problema.
