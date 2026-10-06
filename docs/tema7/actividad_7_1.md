# 🧪 Actividad 7.1: Auditoría y mejora

!!! warning "Descarga la plantilla"
    📄 [Plantilla 7.1 — Auditoría y mejora](plantillas/Actividad_7_1_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

A lo largo del módulo has construido Escaparate pieza a pieza: red, instancias, base de datos, balanceador, monitorización, permisos, presupuesto. Cada decisión tenía su sesión y su justificación, pero nunca has mirado el conjunto entero con las mismas preguntas. Hoy lo haces: auditas tu propia arquitectura con los seis pilares de Well-Architected, buscas dónde falla y decides qué merece la pena arreglar y qué no. Después haces lo mismo con la arquitectura de otra persona, que además trae un problema sin solución perfecta.

Esta actividad no despliega nada nuevo. La arquitectura de Escaparate ya no está encendida (la borraste al cerrar la 5.3), pero conservas su lista de componentes, tus capturas y tus cifras de coste, y el código de la red sigue en `recursos/tema3/red-base/main.tf`. Con eso se audita.

## Qué vas a practicar

- Inventariar una arquitectura con la configuración real de cada pieza.
- Revisar cada uno de los seis pilares y anotar los hallazgos con su impacto y su esfuerzo.
- Calcular la disponibilidad de un sistema y encontrar su eslabón más débil.
- Interpretar recomendaciones automáticas y decidir cuáles se aplican.
- Priorizar mejoras con un presupuesto limitado y dejar por escrito el riesgo que se acepta.

## Requisitos previos

La lista de componentes y el coste mensual que calculaste en la Actividad 5.3 (Pasos 1 y 2), y tus capturas de las actividades anteriores si las conservas. Los apuntes de esta sesión — [«Well-Architected: los seis pilares»](well-architected.md). Acceso a la [calculadora de precios de AWS](https://calculator.aws) y a tu CloudShell (Tema 1).

!!! warning "Cómo hacer las capturas"
    En cada captura tiene que verse con claridad lo que se pide (salida de comandos, líneas de la calculadora...) — una captura recortada, borrosa o con la información clave fuera de encuadre no sirve como evidencia. Además, tiene que verse algo que identifique que es tuyo: tu identificador en el nombre de los recursos (`escaparate-imagenes-<tu-identificador>`) — no una captura genérica que podría ser de cualquier otro alumno.

!!! tip "No necesitas nada encendido"
    Ni instancias, ni base de datos, ni balanceador. Los únicos recursos reales que vas a tocar son los dos buckets de S3, que siguen existiendo y no cuestan prácticamente nada.

---

## Parte A — Audita tu propia arquitectura (guiada)

### Paso 1 — Haz el inventario de lo que tenías

Parte de tu lista de la Actividad 5.3 y complétala hasta tener una tabla con una fila por componente. Cada fila tiene que decir qué es, con qué configuración exacta, en qué zona de disponibilidad vive y quién puede llegar a él. Cubre al menos estas piezas: las instancias del grupo de escalado, el balanceador, la base de datos, los dos buckets de S3, la red (VPC, subredes públicas y privadas, grupos de seguridad), las alarmas y el dashboard de la 5.1, y los permisos con los que trabajaban tus instancias.

Para la red y el grupo de seguridad base (el de SSH), abre `recursos/tema3/red-base/main.tf` y descríbelo tal como está declarado: qué puerto abre su regla de entrada y hacia qué origen. Los grupos de seguridad del balanceador y de las instancias, los que creaste en la Actividad 4.1, ya no existen para poder consultarlos ahí: usa tus propias capturas o notas de esa sesión, no los reconstruyas de memoria.

| Componente | Configuración exacta | Zona(s) | Quién puede llegar a él |
|---|---|---|---|
| … | … | … | … |

**Comprueba**: que ninguna fila dice solo «una instancia» o «una base de datos». Tiene que decir, por ejemplo, qué tipo de instancia, cuántas réplicas, si la base de datos era Multi-AZ o no, y con qué regla se abría cada puerto.

**Captura**: tu tabla de inventario completa.

### Paso 2 — Audita los dos buckets que siguen vivos

Es lo único de tu arquitectura que puedes examinar en directo. Antes de ejecutar nada, apunta qué esperas encontrar en cada uno de los dos buckets (el del frontend y el de imágenes) en cuatro cosas: si el acceso público está bloqueado, si tiene versionado activado, si cifra los objetos en reposo y si tiene alguna regla que borre o mueva objetos antiguos. Después lo compruebas desde CloudShell, cambiando el nombre por el de cada bucket:

```bash
aws s3api get-public-access-block --bucket escaparate-imagenes-<tu-identificador>
aws s3api get-bucket-versioning --bucket escaparate-imagenes-<tu-identificador>
aws s3api get-bucket-encryption --bucket escaparate-imagenes-<tu-identificador>
aws s3api get-bucket-lifecycle-configuration --bucket escaparate-imagenes-<tu-identificador>
```

Dos avisos antes de que creas que algo ha fallado. Si un bucket no tiene configurada una de estas cosas, el comando no devuelve un valor vacío sino un error del tipo `NoSuchLifecycleConfiguration`: ese error es la respuesta («no hay regla»). Y `get-bucket-versioning` devuelve una salida vacía si el versionado no se ha activado nunca.

Si has borrado alguno de los dos buckets, audita el que quede. Si no queda ninguno, crea uno con las opciones por defecto y audítalo.

**Comprueba**: que has anotado tus predicciones antes de ejecutar los comandos y que tienes la salida (o el error) de los cuatro comandos para cada bucket.

**Captura**: la salida de los cuatro comandos para cada bucket, junto a tus predicciones.

!!! question "Reflexiona"
    ¿Coincidían tus predicciones con lo que había? Para cada diferencia, di a qué pilar pertenece y si la consideras un problema o una decisión razonable. El bucket del frontend probablemente tenía el **bloqueo** de acceso público desactivado —es decir, el bucket sí es accesible desde fuera— por una razón que ya conoces: antes de anotarlo como hallazgo de seguridad, comprueba que tiene sentido para lo que ese bucket sirve.

### Paso 3 — Pasa los seis pilares por tu inventario

Recorre los seis pilares, uno a uno, con tu tabla del Paso 1 y lo que has visto en el Paso 2 delante. Para cada hallazgo, apunta el pilar, qué pasa exactamente, su impacto (alto, medio o bajo) y su esfuerzo de corregirlo (alto, medio o bajo).

Necesitas al menos cinco hallazgos que salgan de **tu** arquitectura, repartidos entre al menos cuatro pilares. Si un pilar no tiene hallazgos, apúntalo como «sin hallazgos» y escribe qué has comprobado para llegar a esa conclusión. Ojo con dos tentaciones: copiar hallazgos genéricos que valdrían para cualquier arquitectura (tienen que referirse a algo concreto de la tuya) e inventar un problema para rellenar un pilar.

| Pilar | Hallazgo | Impacto | Esfuerzo |
|---|---|---|---|
| … | … | … | … |

**Comprueba**: que cada hallazgo se refiere a un componente de tu inventario y que los seis pilares aparecen, con hallazgos o con «sin hallazgos» y su comprobación.

**Captura**: tu tabla de hallazgos.

!!! question "Reflexiona"
    Elige uno de tus hallazgos de impacto alto y describe cómo lo corregirías. Después indica qué otro pilar empeora con esa corrección y cuánto: en coste, en complejidad de operación o en otra cosa. Si crees que no empeora ninguno, revísalo.

### Paso 4 — Calcula el eslabón más débil

Tu arquitectura tenía tres piezas en serie que hacían falta para servir una petición: el balanceador, las instancias y la base de datos. Usa estas disponibilidades, que son inventadas y solo sirven para el cálculo:

| Pieza | Disponibilidad |
|---|---|
| Balanceador | 99,99 % |
| Cada instancia de aplicación (repartidas en dos zonas) | 99,5 % |
| Base de datos en una sola zona | 99,5 % |
| Base de datos Multi-AZ | 99,95 % |

Antes de calcular nada, contesta por escrito: para mejorar la disponibilidad total de tu arquitectura, ¿qué compensaría más, pasar de 2 a 4 instancias o pasar la base de datos a Multi-AZ? Después calcula la disponibilidad total con tu configuración real de base de datos (la del Paso 1), con 2 instancias, y con cada una de las dos mejoras. Pasa cada resultado a horas de caída al año.

**Comprueba**: que tus tres cálculos usan tus cifras de partida, que has convertido cada resultado a horas al año y que puedes decir cuál de las dos mejoras ha movido más el resultado.

**Captura**: tus cálculos, con el resultado en horas de caída al año.

!!! question "Reflexiona"
    Con tu configuración real, si la base de datos hubiera caído hoy a las 10:00, ¿qué habría pasado exactamente? Estima cuánto tiempo habría estado el sistema sin responder (tu RTO real) y cuántos datos recientes habrías podido perder (tu RPO real). ¿Cuál de esas dos cifras te habría preocupado más, si Escaparate fuera la tienda de otra persona?

---

## Parte B — Audita la arquitectura de otra persona (reto)

Una clínica veterinaria de barrio, con seis personas trabajando, te pide que revises cómo ha desplegado su aplicación de citas e historiales clínicos. Esto es lo que ha descrito su responsable:

- La aplicación y su base de datos PostgreSQL corren juntas en una sola instancia `m5.2xlarge` (8 vCPU y 32 GB de RAM), encendida las 24 horas, con IP pública.
- Los historiales y las radiografías se guardan en el disco de esa misma instancia (500 GB). Cada noche a las 02:00 un script copia los datos a un segundo disco conectado a la misma instancia.
- Para entrar a administrar la instancia se usa SSH, abierto a todo internet, y las seis personas comparten el mismo usuario y la misma contraseña.
- La web solo funciona por HTTP. No hay ninguna alarma ni panel: se enteran de que algo ha fallado cuando un cliente llama para avisar.
- Requisitos que ha puesto el responsable: no se pueden perder más de 60 minutos de datos, la aplicación no puede estar caída más de 15 minutos durante el horario de consulta (lunes a sábado, de 9 a 20) y el presupuesto máximo es de 100 USD al mes. Las urgencias se atienden por teléfono, sin la aplicación.

Además, ha puesto encima de la mesa las dos recomendaciones automáticas que ha recibido en la consola, sin saber qué hacer con ellas:

!!! example "Recomendación de Compute Optimizer"
    La instancia lleva 14 días con una CPU media del 6 %. Recomendación: cambiar a `m5.large` (2 vCPU, 8 GB), con un ahorro estimado del 75 %.

!!! example "Recomendación de Trusted Advisor (costes)"
    La instancia no recibe tráfico entre las 21:00 y las 08:00 de cada día ni durante todo el domingo. Recomendación: apagarla en esos tramos, con un ahorro estimado del 54 %.

Un dato más que el responsable ha aportado al preguntarle: la memoria de la instancia está usada de media al 78 %, porque PostgreSQL guarda en ella los datos que consulta con más frecuencia.

Haz la auditoría completa. Necesitas un inventario de lo que hay, una tabla de hallazgos priorizada por impacto y esfuerzo (con al menos seis hallazgos, de al menos cinco pilares distintos), y una decisión razonada, para cada una de las dos recomendaciones, de si se aplica tal cual, se aplica modificada o se descarta. Si descartas una, di por qué; si la modificas, di cómo y con qué precio. Con eso, propón un plan de mejora ordenado y estima su coste mensual con la calculadora de precios: el plan tiene que caber en el presupuesto, o explicar exactamente qué se queda fuera y por qué.

Los tres requisitos del responsable no caben del todo a la vez. No hay una única respuesta correcta, pero sí una obligación: elige qué requisito se cumple entero, cuál se cumple a medias y cuál se relaja, y deja por escrito el riesgo que se acepta y cómo lo explicarías al responsable de la clínica, que no sabe de arquitectura. Fíjate en que las dos recomendaciones no son independientes entre sí, y en cómo se relacionan con el script de copia nocturna.

**Comprueba**: que tus hallazgos se apoyan en datos del enunciado (no en generalidades), que has usado el dato de la memoria para juzgar la recomendación de Compute Optimizer y que el coste de tu plan sale de la calculadora, no de una estimación a ojo.

**Captura**: la calculadora con la estimación de tu plan de mejora; tu tabla de hallazgos priorizada; tus decisiones sobre las dos recomendaciones; la explicación del riesgo que aceptas.

---

## Criterios de evaluación

**Parte A — hasta 6 puntos**

| Apartado | Puntos |
|---|---|
| Inventario con configuración real y concreta de cada componente | 1 |
| Auditoría de los buckets con predicciones previas y comparación con la salida real | 1 |
| Tabla de hallazgos propia (al menos 5, en al menos 4 pilares), con impacto y esfuerzo, y los pilares sin hallazgos comprobados | 2 |
| Cálculo de disponibilidad correcto, comparando las dos mejoras, y RTO y RPO razonados | 2 |

**Parte B — reto, hasta 4 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Inventario y tabla de hallazgos priorizada, apoyada en los datos del enunciado | 1 |
| Decisión razonada sobre las dos recomendaciones, usando el dato de la memoria y su relación con la copia nocturna | 1 |
| Plan de mejora con coste real de la calculadora, requisitos priorizados y riesgo aceptado por escrito | 2 |

---

## ✅ Cierre

Has recorrido una arquitectura completa con un método, en lugar de fiarte de tu intuición sobre qué mirar, y has comprobado que casi cada mejora cuesta algo en otro pilar. Es la última actividad del módulo: lo que te llevas es una forma de revisar cualquier arquitectura, propia o ajena, y de explicar por escrito qué se arregla, qué se deja y por qué.

!!! danger "Antes de salir: comprueba que la cuenta ha quedado vacía"
    Esta es la última sesión del módulo y ya nada de lo anterior se va a reutilizar. Comprueba desde CloudShell que no queda nada con coste por hora, sobre todo lo que hayas creado en el Tema 6 (instancia de comparación de la 6.2, servicio y balanceador de la 6.3):

    ```bash
    aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query "Reservations[].Instances[].InstanceId"
    aws rds describe-db-instances --query "DBInstances[].DBInstanceIdentifier"
    aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerName"
    aws ecs list-clusters
    aws ec2 describe-nat-gateways --filter Name=state,Values=available --query "NatGateways[].NatGatewayId"
    aws ec2 describe-addresses --query "Addresses[].PublicIp"
    ```

    Todas las listas tienen que salir vacías. Si el clúster de ECS aparece, entra en él y comprueba que no queda ningún servicio con tareas en marcha antes de borrarlo. Los buckets de S3 y las funciones Lambda puedes dejarlos: no cuestan nada sin uso.
