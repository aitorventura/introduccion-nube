# 🧪 Actividad 5.2: Gestión de credenciales y políticas IAM

!!! warning "Descarga la plantilla"
    📄 [Plantilla 5.2 — Gestión de credenciales y políticas IAM](plantillas/Actividad_5_2_INU_Plantilla.docx){target="_blank" rel="noopener"}

!!! warning "Descarga los recursos"
    📦 [Recursos de la Actividad 5.2](recursos/actividad_5_2_recursos.zip){target="_blank" rel="noopener"} — el script de arranque que cambia el almacenamiento de EFS a S3.

## Contexto

Escaparate guarda las fotos de sus productos en EFS desde la Actividad 4.1 — un sistema de ficheros compartido, pero al fin y al cabo un disco que hay que montar a mano en cada réplica. Hoy lo sustituyes por **S3**, y de paso dejas de tratar el rol de tus instancias como una caja negra: comprueba de verdad qué permite, y detectas si es más permisivo de lo que debería.

!!! info "Por qué esto no incluye crear usuarios ni roles (ni leer el JSON de una política)"
    El Learner Lab no permite crear identidades nuevas de IAM — tu rol viene preasignado y no se puede tocar. Tampoco te deja abrir el documento JSON de ninguna política, ni siquiera para consultarla: cualquier intento de `iam:GetPolicy`, por consola o por CLI, da un error de acceso denegado explícito. La Actividad 5.2 no necesita ninguna de las dos cosas: vas a **investigar el alcance real de tu rol probando acciones concretas con el simulador de IAM** (sin ejecutar nada de verdad contra tu cuenta), **corregir** una política mal escrita a partir de lo que has descubierto, y **diseñar en papel** cómo repartirías permisos en una organización — que es exactamente lo que un perfil de nube hace con la gestión de accesos en el día a día, sin necesitar privilegios de administrador para practicarlo.

## Qué vas a practicar

- Migrar el almacenamiento de imágenes de Escaparate de EFS a S3, sin cambiar una línea de código de la aplicación.
- Confirmar que el acceso a S3 se hace sin ninguna credencial estática, apoyándote en el rol de la instancia.
- Investigar el alcance real de la política de tu rol probando acciones concretas con el simulador de IAM.
- Corregir una política mal escrita aplicando el principio de mínimo privilegio.
- Diseñar en papel la estructura de permisos de una organización con varios roles distintos.

## Requisitos previos

El balanceador, el grupo de escalado, la RDS y el agente de CloudWatch de la 5.1 (si has pausado los recursos al cerrar esa actividad, repite su Paso 0 antes de continuar: mismo script `recrear-alb.sh`, misma RDS, mismo ASG a capacidad 2). El bucket S3 del frontend de la 3.3. Los apuntes de esta sesión — [«Identidad y gestión de accesos»](iam-aplicado.md).

---

## Parte A — Migración a S3 y lectura de permisos reales (guiada)

### Paso 1 — Crea el bucket privado de imágenes

1. **S3 → Crear bucket**. Nómbralo `escaparate-imagenes-<tu-identificador>` (recuerda que los nombres de bucket son únicos en todo AWS, no solo en tu cuenta). Región **us-east-1**, la misma que el resto de tu infraestructura.
2. Deja **"Bloquear todo el acceso público"** activado — es el valor por defecto, no lo toques. El bucket permanece privado: el navegador nunca va a hablar con S3 directamente, sigue pidiendo `GET /api/productos/{id}/imagen` a Escaparate como hasta ahora, y es la propia aplicación quien recupera el objeto de S3 por dentro.
3. Deja el resto de opciones (versionado, cifrado) en su valor por defecto y crea el bucket.

**Comprueba**: que el bucket aparece en la lista con el icono de "Acceso público bloqueado".

**Captura**: el bucket creado, con la columna de acceso público mostrando que está bloqueado.

### Paso 2 — Cambia el almacenamiento de Escaparate a S3

1. Descarga `arranque-instancia-s3.sh` de los recursos de hoy y sustituye sus tres marcadores (identificador, origen del frontend, y el nombre del bucket que acabas de crear).

    La mayor parte del script es idéntica a la de la 5.1 (identidad de la instancia, credenciales de RDS por Secrets Manager, agente de CloudWatch) — lo único que cambia de verdad es el bloque de almacenamiento:

    | Línea | Qué hace |
    |---|---|
    | `export APP_STORAGE_TYPE=s3` | Le dice a Escaparate que active `S3Storage` en vez de `FileSystemStorage` — es la misma variable que hasta ahora valía `filesystem`, apuntando ahora a la implementación de S3 |
    | `export APP_STORAGE_S3_BUCKET="${BUCKET_IMAGENES}"` | El bucket donde `S3Storage` va a leer y escribir los objetos — el que has creado en el Paso 1 |
    | *(ya no aparece)* `mount -t efs ...` | El montaje de EFS de la 5.1 desaparece por completo: S3 no necesita ningún punto de montaje en el sistema de ficheros de la instancia, así que esa parte del script simplemente sobra |

    Fíjate en lo que **tampoco** aparece por ningún lado: ninguna variable de tipo `APP_AWS_ACCESS_KEY` o similar. Eso es justo lo que has visto en la teoría de hoy — la aplicación llega a S3 a través del rol de la instancia, no de una credencial puesta a mano en este script.

2. **EC2 → Plantillas de lanzamiento → tu plantilla → Modificar plantilla (crear nueva versión)** → pega el script nuevo en **Datos de usuario**, reemplazando el contenido entero.
3. Marca esta versión nueva como **Versión predeterminada**.
4. Termina **una sola** instancia a mano y espera a que su reemplazo esté `healthy` en el grupo de destino antes de tocar la segunda — el mismo procedimiento uno-a-uno de la 5.1.

!!! info "Las fotos que subiste en actividades anteriores no se migran solas"
    Estaban en EFS; el script nuevo ya no monta ese sistema de ficheros, así que esas imágenes concretas dejan de ser accesibles. No es un error — es justo lo que cabe esperar al cambiar de backend de almacenamiento sin escribir una migración de datos. Para probar S3 necesitas un producto nuevo con una foto nueva, en el Paso 3.

**Comprueba**: que las dos instancias vuelven a estar `healthy` en el grupo de destino con la plantilla nueva.

**Captura**: la plantilla de lanzamiento mostrando la versión nueva como predeterminada, y el grupo de destino con las dos instancias `healthy`.

### Paso 3 — Verifica que el acceso a S3 funciona sin credenciales estáticas

1. Crea un producto nuevo con una foto, usando el mismo DNS de tu balanceador:

    ```bash
    curl -X POST http://<dns-del-balanceador>/api/productos \
      -F "nombre=Prueba S3" \
      -F "descripcion=Verificando el almacenamiento en S3" \
      -F "precio=9.99" \
      -F "imagen=@/ruta/a/una/foto.jpg"
    ```

2. Comprueba que la imagen se sirve bien: `curl http://<dns-del-balanceador>/api/productos/<id-del-producto-nuevo>/imagen` (o ábrelo directamente en el navegador).
3. Entra en tu bucket S3 y confirma que aparece un objeto nuevo, dentro de la carpeta `escaparate/`.

Fíjate en lo que **no** ha hecho falta en ningún momento: ni una clave de acceso, ni un secreto, ni nada parecido a `APP_AWS_ACCESS_KEY` en el script. La aplicación usa la cadena de credenciales estándar del SDK de AWS, que en una instancia EC2 resuelve directamente al rol que ya lleva asignada.

**Comprueba**: que la imagen se sirve correctamente desde la API, y que el objeto correspondiente existe en el bucket S3.

**Captura**: el producto nuevo respondiendo con su imagen, y el objeto correspondiente visible dentro del bucket.

### Paso 4 — Investiga el alcance real de tu rol con el simulador de políticas

1. **EC2 → tu instancia → pestaña Seguridad → Rol de IAM** → haz clic en el nombre del rol (te lleva a la consola de IAM, a tu rol `LabRole`). Verás la lista de políticas adjuntas — puedes ver sus **nombres**, pero no vas a poder abrir ninguna para leer su JSON: cualquier intento de consultar el contenido de una política (`iam:GetPolicy`) está denegado explícitamente en este Lab. No es un error tuyo — no hay forma de leer el documento directamente.

    !!! warning "El simulador de políticas por consola no es fiable en este Lab — usa la CLI"
        Tanto la versión nueva del simulador (el botón "Simular" aparece deshabilitado) como la antigua (da resultados que no coinciden con lo que de verdad ocurre) fallan en esta cuenta. La CLI, en cambio, funciona perfectamente y es la fuente fiable — así que vas a simular desde CloudShell en vez de por consola.

2. Averigua el ARN completo de tu rol:

    ```bash
    aws iam get-role --role-name LabRole --query "Role.Arn" --output text
    ```

3. Simula varias acciones a la vez con `simulate-principal-policy`, sustituyendo el ARN del paso anterior:

    ```bash
    aws iam simulate-principal-policy \
      --policy-source-arn <ARN-de-LabRole> \
      --action-names s3:GetObject s3:PutObject s3:DeleteObject s3:DeleteBucket s3:PutBucketPolicy iam:CreateUser \
      --resource-arns "arn:aws:s3:::escaparate-imagenes-<tu-identificador>/*"
    ```

4. Revisa, para cada acción, el campo `EvalDecision` (`allowed` o `denied` — o `implicitDeny` si ninguna política dice nada). `s3:GetObject`, `s3:PutObject` y `s3:DeleteObject` son justo lo que Escaparate necesita, así que deberían salir permitidas. Fíjate especialmente en `s3:DeleteBucket` y `s3:PutBucketPolicy`: si también salen permitidas (que es lo que cabe esperar en este Lab), es la prueba de que el rol real tiene más permisos de los que la aplicación necesita. `iam:CreateUser` debería salir denegada, confirmando que crear usuarios sigue bloqueado.

**Comprueba**: que has documentado el resultado exacto de las seis acciones, y que sabes explicar qué te dice cada una sobre si el rol real de tu instancia sigue el principio de mínimo privilegio o es más amplio de lo que Escaparate necesita.

**Captura**: la salida completa del comando `simulate-principal-policy`.

---

## Parte B — Reto: corrige y diseña permisos sin tocar la consola de IAM (reto)

- **Corrige esta política mal escrita**: un compañero ha configurado el acceso de una aplicación parecida a Escaparate con esto:

    ```json
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
    ```

    Explica por escrito, con tus propias palabras, **todo** lo que hay de malo en esta política (piensa en el principio de mínimo privilegio, en el alcance de `Action` y en el de `Resource`), y reescríbela para que conceda exactamente lo que Escaparate necesita sobre su propio bucket de imágenes — ni una acción ni un recurso de más. Usa como referencia lo que has confirmado en el Paso 4.

    **Captura**: tu explicación de los problemas y tu política corregida.

- **Diseña en papel la estructura de permisos de una organización con al menos tres roles distintos**: imagina que Escaparate deja de ser un proyecto de prácticas y pasa a tener un equipo detrás. Define al menos tres roles (por ejemplo, aunque puedes elegir otros: alguien que despliega y mantiene la infraestructura, alguien de soporte que necesita consultar datos pero no modificarlos, y alguien de auditoría que solo necesita poder revisar qué ha pasado). Para cada rol, indica por escrito:

    1. Qué necesita poder hacer de verdad, en términos concretos (no "acceso a AWS", sino acciones y servicios concretos).
    2. Qué **no** debería poder hacer, aunque técnicamente pudiera serle útil alguna vez.
    3. Por qué esa separación reduce el daño posible si una de esas identidades se ve comprometida.

    No hace falta crear nada en la consola — es un documento de diseño, el mismo tipo de trabajo que haría alguien de nube antes de pedirle a quien administra IAM que cree los roles de verdad.

    **Captura**: no aplica — este reto se entrega como documento de texto, no como captura de consola.

**Entrega**: la política corregida con su explicación, y el diseño de los tres roles con sus permisos justificados.

---

## Criterios de evaluación

**Parte A — hasta 6 puntos**

| Apartado | Puntos |
|---|---|
| Bucket S3 creado privado y correctamente configurado | 1 |
| Migración a S3 completada, instancias `healthy` con la plantilla nueva | 2 |
| Producto de prueba subido y verificado, tanto en la API como en el bucket | 1 |
| Alcance real del rol investigado con el simulador (las tres comprobaciones), documentado y explicado | 2 |

**Parte B — reto, hasta 4 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Política corregida, identificando los problemas y ajustando acción y recurso al mínimo necesario | 2 |
| Diseño de permisos de la organización, con al menos tres roles justificados por separado | 2 |

---

## ✅ Cierre

Escaparate ya no depende de un disco compartido montado a mano, y tú ya no tratas el rol de tus instancias como algo que "ya viene bien configurado" — lo has leído, lo has puesto a prueba con el simulador, y has practicado el mismo razonamiento de mínimo privilegio que se aplicaría para crear roles de verdad fuera del Learner Lab.

!!! danger "Antes de salir: qué hacer con lo de hoy"
    1. El bucket `escaparate-imagenes-<tu-identificador>` puedes dejarlo — no tiene coste relevante mientras esté casi vacío, y lo necesitas si continúas con la 5.3.
    2. Si no vas a continuar con la 5.3 en las próximas horas: baja el ASG a capacidad 0, detén la RDS, y borra el balanceador y el grupo de destino (`recrear-alb.sh`, de los recursos de la 5.1, te lo vuelve a montar en un par de minutos) — el mismo criterio de pausar-no-borrar de siempre.
    3. No toques el EFS, la AMI, ni el bucket S3 del frontend — puede que otra actividad los siga necesitando.
