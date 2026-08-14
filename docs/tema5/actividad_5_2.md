# 🧪 Actividad 5.2: Gestión de credenciales y políticas IAM

!!! warning "Descarga la plantilla"
    📄 [Plantilla 5.2 — Gestión de credenciales y políticas IAM](plantillas/Actividad_5_2_INU_Plantilla.docx){target="_blank" rel="noopener"}

!!! info "Adaptación por las restricciones del Learner Lab"
    El Learner Lab no permite crear roles ni usuarios IAM nuevos. Donde el enunciado dice "rol con permisos mínimos", vas a usar el rol ya preasignado a tu laboratorio, adjuntándolo a la instancia y **verificando qué permisos concede de verdad**, en vez de crear uno desde cero. El principio de mínimo privilegio se practica hoy leyendo y corrigiendo políticas ya escritas, no diseñando una nueva.

## Contexto

El catálogo de Escaparate necesita acceder al almacenamiento de objetos sin que ninguna credencial viva escrita en el código ni en la instancia. Hoy resuelves eso con el rol ya preasignado, y después te enfrentas a políticas mal escritas de verdad — el tipo de error que se cuela en cualquier cuenta real si nadie las revisa.

## Qué vas a practicar

- Adjuntar el rol preasignado del Learner Lab a una instancia y verificar el acceso a S3 sin credenciales hardcodeadas.
- Leer y corregir políticas IAM mal escritas, prediciendo el resultado con el simulador de políticas antes de comprobarlo.
- Confirmar que la credencial de la base de datos vive fuera del código.
- Localizar en el registro de auditoría quién ha hecho qué durante una incidencia ya resuelta.

## Requisitos previos

Una instancia en marcha con acceso a una CLI (por ejemplo, la de la Actividad 4.1). El apunte de esta sesión — «Identidad y gestión de accesos» (iam-aplicado.md).

---

## Parte A — Rol en vez de credenciales (guiada)

### Paso 1 — Adjunta el rol preasignado a la instancia desde la consola

1. Ve al panel de **EC2** → **Instancias**, y selecciona la instancia de tu aplicación.
2. **Acciones → Seguridad → Modificar rol de IAM**.
3. En el desplegable, selecciona el rol preasignado de tu Learner Lab (el mismo que viste con `aws sts get-caller-identity` en la sesión 1).
4. Haz clic en **Actualizar rol de IAM**.

![Rol de IAM del Learner Lab adjuntado a la instancia](img/actividad_5_2_paso1.png)

**Comprueba**: en la pestaña **Seguridad** de los detalles de la instancia, que el rol IAM aparece asignado.
**Captura**: `img/actividad_5_2_paso1.png`.

### Paso 2 — Verifica el acceso desde dentro de la instancia, sin credenciales propias

Conéctate a la instancia (por SSH o Session Manager) y, **sin haber ejecutado nunca `aws configure` dentro de ella**, comprueba que puede acceder a S3 usando solo las credenciales temporales que le da el rol:

```bash
aws s3 ls s3://<tu-bucket-del-front>
```

**Comprueba**: que el comando devuelve el listado sin ningún error de credenciales, y que dentro de la instancia no existe ningún fichero `~/.aws/credentials` con claves de acceso escritas.
**Captura**: la salida del comando, y la comprobación de que no existe fichero de credenciales.

!!! question "Reflexiona"
    Si mañana el rol preasignado del Learner Lab cambiase de permisos, ¿qué tendrías que modificar en tu instancia para que el catálogo siguiera accediendo a S3? Compáralo con lo que habrías tenido que hacer si hubieras usado credenciales fijas guardadas dentro de la instancia.

---

## Parte B — Políticas mal escritas y auditoría real (reto)

**Corrige cinco políticas sin ayuda paso a paso.** El profesor te entrega cinco políticas IAM con errores reales (comodines de más, recursos completamente abiertos, permisos de escritura donde solo hacía falta lectura). Para cada una: **antes de tocar nada**, predice por escrito qué acceso de más está concediendo la política tal como está. Después, usa el simulador de políticas de IAM para comprobar tu predicción contra una acción concreta, y corrige la política al mínimo privilegio real que necesita.

**Confirma que la base de datos sigue sin credenciales en el código.** Verifica que la contraseña de tu instancia RDS del Tema 3 sigue resuelta por Secrets Manager, y no ha aparecido en ningún commit del repositorio desde entonces.

**Localiza en el registro de auditoría quién hizo qué.** Activa (o revisa, si ya estaba activo) el registro de eventos de CloudTrail, y busca en él la corrección de la incidencia que hiciste en la Actividad 5.1: ¿qué llamada a la API queda registrada como el momento exacto en que corregiste el problema?

**Comprueba**: que cada política corregida sigue permitiendo lo que la aplicación necesita de verdad (no la has dejado tan restrictiva que rompe algo), y que localizas el evento de auditoría exacto de la incidencia anterior, no una búsqueda aproximada.
**Captura**: tus cinco predicciones escritas antes de usar el simulador, junto con el resultado real del simulador para cada una; las políticas corregidas; el evento de CloudTrail localizado con su marca de tiempo.

---

## Verificación

Para dar por válida la práctica se ejecutará:

```bash
aws sts get-caller-identity
aws s3 ls s3://<tu-bucket-del-front>
aws cloudtrail lookup-events --max-results 10
```

Ambos comandos deben ejecutarse desde dentro de la instancia sin ningún fichero de credenciales local. Debe observarse: acceso correcto a S3 solo por el rol, las cinco políticas corregidas con su predicción documentada, y el evento de auditoría de la incidencia anterior localizado.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Rol preasignado adjuntado y acceso a S3 verificado sin credenciales propias | 6 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Cinco políticas corregidas, con predicción previa y verificación por simulador | 2 |
| Credencial de la base de datos confirmada fuera del código, y evento de auditoría localizado | 1 |

---

## ✅ Cierre

Ya sabes leer una política IAM sin que te intimide el JSON, y sabes que "sin credenciales en el código" no es un eslogan — es algo que puedes verificar de verdad, dentro y fuera de la instancia. La próxima sesión cierras el tema del gobierno de la nube con la pregunta que lleva rondando desde la primera clase: cuánto cuesta de verdad todo lo que has construido.
