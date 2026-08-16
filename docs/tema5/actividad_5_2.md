# 🧪 Actividad 5.2: Gestión de credenciales y políticas IAM

!!! warning "Descarga la plantilla"
    📄 [Plantilla 5.2 — Gestión de credenciales y políticas IAM](plantillas/Actividad_5_2_INU_Plantilla.docx){target="_blank" rel="noopener"}

!!! warning "Descarga los recursos"
    📦 [Recursos de la Actividad 5.2](recursos/actividad_5_2_recursos.zip){target="_blank" rel="noopener"} — descomprímelo en la raíz de tu proyecto: crea la carpeta `recursos/tema5/actividad_5_2/`, la misma ruta que usan los pasos de esta actividad.

!!! info "Adaptación por las restricciones del Learner Lab"
    El Learner Lab no permite crear roles ni usuarios IAM nuevos. Donde el enunciado dice "rol con permisos mínimos", vas a usar el rol ya preasignado a tu laboratorio, adjuntándolo a la instancia y **verificando qué permisos concede de verdad**, en vez de crear uno desde cero. El principio de mínimo privilegio se practica hoy leyendo y corrigiendo políticas ya escritas, no diseñando una nueva.

## Contexto

Inventario —la aplicación de gestión de inventario de un almacén— necesita acceder al almacenamiento de objetos donde vive el listado de existencias, sin que ninguna credencial viva escrita en el código ni en la instancia, y necesita también una credencial de base de datos que en un despliegue real vendría de Secrets Manager. Hoy resuelves eso con el rol ya preasignado, y después te enfrentas a políticas mal escritas de verdad — el tipo de error que se cuela en cualquier cuenta real si nadie las revisa.

## Qué vas a practicar

- Desplegar una instancia con la aplicación de Inventario, apoyada en IAM y en una variable de entorno que simula Secrets Manager.
- Adjuntar el rol preasignado del Learner Lab a la instancia y verificar el acceso a S3 sin credenciales hardcodeadas.
- Leer y corregir políticas IAM mal escritas, prediciendo el resultado con el simulador de políticas antes de comprobarlo.
- Confirmar que la credencial de la base de datos vive fuera del código.
- Localizar en el registro de auditoría quién ha hecho qué durante una incidencia ya resuelta.

## Requisitos previos

Acceso a tu Learner Lab, con un bucket S3 propio (puedes crear uno nuevo o reutilizar uno existente) con algún objeto dentro. Los ficheros de la aplicación de Inventario (`app.py`, `requirements.txt`, `arranque-inventario.sh`) — descárgalos del enlace de arriba, no los programas tú. El apunte de esta sesión — «Identidad y gestión de accesos» (iam-aplicado.md).

---

## Parte A — Rol en vez de credenciales (guiada)

### Paso 1 — Lanza la instancia de Inventario desde la consola

1. Busca "EC2" en el buscador de servicios → **Instancias** → **Lanzar instancia**.
2. Dale un nombre, por ejemplo `inventario-<tu-identificador>`.
3. Elige una AMI de Amazon Linux 2023, y el tipo `t3.micro`.
4. En **Configuración de red**, elige tu subred pública, con IP pública habilitada, y un grupo de seguridad con el puerto 80 abierto y el 22 restringido a tu IP.
5. Despliega **Detalles avanzados**, baja hasta **Datos de usuario**, y pega ahí el contenido de `arranque-inventario.sh` — sustituye antes el nombre de bucket de ejemplo por el tuyo. El script vive en `recursos/tema5/actividad_5_2/arranque-inventario.sh`.
6. Lanza la instancia. Todavía no tendrá permisos sobre S3 — eso es justo lo que vas a resolver en el paso siguiente.

![Instancia respondiendo en el puerto 80, con el error de acceso al bucket antes de tener rol asignado](img/actividad_5_2_paso1.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_5_2_paso1.png`*

**Comprueba**: que la instancia responde en el puerto 80, y que la ruta `/` muestra un error de acceso al bucket (todavía no tiene rol asignado).

**Captura**: tu propia instancia respondiendo en el puerto 80, con el error de acceso al bucket antes de tener rol asignado.

### Paso 2 — Adjunta el rol preasignado a la instancia desde la consola

1. Ve al panel de **EC2** → **Instancias**, y selecciona la instancia de tu aplicación.
2. **Acciones → Seguridad → Modificar rol de IAM**.
3. En el desplegable, selecciona el rol preasignado de tu Learner Lab (el mismo que viste con `aws sts get-caller-identity` en la sesión 1).
4. Haz clic en **Actualizar rol de IAM**.

![Rol de IAM del Learner Lab adjuntado a la instancia](img/actividad_5_2_paso2.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_5_2_paso2.png`*

**Comprueba**: en la pestaña **Seguridad** de los detalles de la instancia, que el rol IAM aparece asignado, y que la ruta `/` ahora muestra el listado del bucket como fichas de inventario.

**Captura**: tu propio rol de IAM del Learner Lab ya adjuntado a la instancia.

### Paso 3 — Verifica el acceso desde dentro de la instancia, sin credenciales propias

Conéctate a la instancia (por SSH o Session Manager) y, **sin haber ejecutado nunca `aws configure` dentro de ella**, comprueba que puede acceder a S3 usando solo las credenciales temporales que le da el rol:

```bash
aws s3 ls s3://<tu-bucket-de-inventario>
```

**Comprueba**: que el comando devuelve el listado sin ningún error de credenciales, y que dentro de la instancia no existe ningún fichero `~/.aws/credentials` con claves de acceso escritas.

**Captura**: la salida del comando, y la comprobación de que no existe fichero de credenciales.

!!! question "Reflexiona"
    Si mañana el rol preasignado del Learner Lab cambiase de permisos, ¿qué tendrías que modificar en tu instancia para que Inventario siguiera accediendo a S3? Compáralo con lo que habrías tenido que hacer si hubieras usado credenciales fijas guardadas dentro de la instancia.

---

## Parte B — Políticas mal escritas y auditoría real (reto)

**Corrige cinco políticas sin ayuda paso a paso.** El profesor te entrega cinco políticas IAM con errores reales (comodines de más, recursos completamente abiertos, permisos de escritura donde solo hacía falta lectura). Para cada una: **antes de tocar nada**, predice por escrito qué acceso de más está concediendo la política tal como está. Después, usa el simulador de políticas de IAM para comprobar tu predicción contra una acción concreta, y corrige la política al mínimo privilegio real que necesita.

**Confirma que la base de datos sigue sin credenciales en el código.** Inventario lee su credencial de base de datos desde una variable de entorno de la instancia (`DB_PASSWORD`), simulando que llega inyectada desde Secrets Manager. Comprueba la ruta `/estado-bd` de la aplicación, revisa el código de `app.py` para confirmar que ningún valor de contraseña aparece escrito en él, y verifica que la variable tampoco ha aparecido nunca en texto plano en ningún commit del repositorio.

**Localiza en el registro de auditoría quién hizo qué.** Activa (o revisa, si ya estaba activo) el registro de eventos de CloudTrail de tu cuenta, y busca en él la corrección de la incidencia que hiciste en la Actividad 5.1: ¿qué llamada a la API queda registrada como el momento exacto en que corregiste el problema?

**Comprueba**: que cada política corregida sigue permitiendo lo que la aplicación necesita de verdad (no la has dejado tan restrictiva que rompe algo), y que localizas el evento de auditoría exacto de la incidencia anterior, no una búsqueda aproximada.

**Captura**: tus cinco predicciones escritas antes de usar el simulador, junto con el resultado real del simulador para cada una; las políticas corregidas; el evento de CloudTrail localizado con su marca de tiempo.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Instancia de Inventario desplegada, con la aplicación funcionando | 1 |
| Rol preasignado adjuntado y acceso a S3 verificado sin credenciales propias | 5 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Cinco políticas corregidas, con predicción previa y verificación por simulador | 2 |
| Credencial de la base de datos confirmada fuera del código, y evento de auditoría localizado | 1 |

---

## ✅ Cierre

Ya sabes leer una política IAM sin que te intimide el JSON, y sabes que "sin credenciales en el código" no es un eslogan — es algo que puedes verificar de verdad, dentro y fuera de la instancia. La próxima sesión cierras el tema del gobierno de la nube con una pregunta distinta: cuánto cuesta de verdad una arquitectura en la nube, con números reales y no una estimación de memoria.
