<a id="iam-aplicado"></a>

# 🧩 2. Identidad y gestión de accesos

---

Desde la primera sesión sabes que tu rol en el Learner Lab está preasignado, y que no puedes crear usuarios ni roles nuevos. Hoy no cambia esa regla — pero sí dejas de tratar IAM como una caja negra que "ya viene configurada" y empiezas a leerla, corregirla y usarla de verdad: aplicar un rol existente a una instancia para que acceda a otros servicios sin credenciales, y detectar por qué una política está mal escrita antes de que cause un problema real.

---

## 🧭 Usuarios frente a roles, políticas y credenciales temporales

IAM (*Identity and Access Management*) tiene varias piezas que conviene distinguir bien, porque ya llevas semanas usando una de ellas sin nombrarla:

| Pieza | Qué es | En el Learner Lab |
|---|---|---|
| Usuario | Una identidad fija, con sus propias credenciales de larga duración | No puedes crear ninguno — no lo necesitas para este módulo |
| Rol | Una identidad que "se presta" temporalmente a quien la asume (una persona, o un servicio como una instancia) | Tienes uno preasignado (`assumed-role`, lo viste en la sesión 1) |
| Política | Un documento que dice qué acciones están permitidas o denegadas | Puedes leerlas, analizarlas y corregirlas — no crear roles nuevos para adjuntarlas |
| Credenciales temporales | Claves de acceso con caducidad, generadas al asumir un rol | Es lo que usa tu sesión del Learner Lab ahora mismo |

Toda llamada a la API de AWS —tu código pidiendo a S3 que guarde una foto, por ejemplo— tiene que ir firmada con una credencial: un par de claves, una pública y una secreta, que le dicen a AWS *quién* está llamando antes de comprobar si tiene permiso. La pregunta es de dónde sale esa credencial, y ahí es donde un rol resuelve algo que un usuario no puede.

Si una instancia necesitara las claves fijas de un usuario para acceder a S3, esas claves tendrían que vivir guardadas en algún sitio dentro de la instancia (una variable de entorno, un fichero de configuración) — exactamente el problema de "credenciales en el código" que ya evitaste en el Tema 3 con Secrets Manager: no caducan solas, y si alguien las consigue, tiene acceso indefinido hasta que tú te des cuenta y las revoques a mano.

Un rol asignado a la instancia evita ese problema de raíz, sin que tú guardes ni rotes nada: AWS publica unas credenciales temporales —caducan solas al cabo de unas horas y se renuevan solas— en una dirección de red interna especial, `169.254.169.254` (el **servicio de metadatos de la instancia**, la misma dirección que ya usas en tus scripts para leer el `instance-id`). El SDK de AWS que usa tu aplicación ya sabe mirar ahí por defecto, así que tu código nunca necesita saber dónde están esas claves ni pedirlas explícitamente.

!!! example "Por qué S3Storage no tiene ninguna clave de acceso"
    En la Actividad 5.2, la clase que guarda las fotos de Escaparate en S3 crea su cliente así: `S3Client.builder().build()`, sin pasarle ninguna credencial. Eso funciona porque el SDK, al no recibir ninguna clave explícita, pregunta solo al servicio de metadatos qué credenciales temporales tiene la instancia ahora mismo, y las usa. Si mañana esa instancia se termina y otra la sustituye, la nueva pregunta lo mismo y recibe sus propias credenciales — nadie ha tenido que copiar ni rotar ninguna clave a mano.

---

## 🧩 Anatomía de una política

Una política IAM es un documento en el mismo formato JSON que ya viste en la sesión 1, con una estructura fija, y aprender a leerla rápido es más útil que memorizar su sintaxis exacta.

```json
{
  "Effect": "Allow",
  "Action": ["s3:GetObject", "s3:PutObject"],
  "Resource": "arn:aws:s3:::escaparate-imagenes-<tu-identificador>/*",
  "Condition": {
    "Bool": { "aws:SecureTransport": "true" }
  }
}
```

| Campo | Responde a | En el ejemplo |
|---|---|---|
| `Effect` | ¿Permite o deniega? | `Allow` |
| `Action` | ¿Qué operación? | `s3:GetObject` y `s3:PutObject` (leer y escribir un objeto) |
| `Resource` | ¿Sobre qué recurso concreto? | Los objetos dentro del bucket `escaparate-imagenes-<tu-identificador>` |
| `Condition` | ¿Bajo qué circunstancia adicional? | Solo si la petición viaja cifrada (HTTPS) |

!!! example "Leer una política, frase por frase"
    Este ejemplo completo se lee así: "Permite leer y escribir objetos dentro del bucket de imágenes de Escaparate, pero solo si la conexión va cifrada." Cuatro campos, una frase — cuando te enfrentes a la política real de tu rol en la Actividad 5.2 (moviendo las imágenes de Escaparate a S3), sigue leyéndola exactamente así, campo a campo.

Leer una política te dice qué *debería* permitir sobre el papel, pero con varias líneas y comodines de por medio es fácil equivocarse. El **simulador de políticas de IAM** te deja elegir una política, una acción y un recurso concretos, y te responde directamente "permitido" o "denegado" — sin ejecutar nada de verdad contra tu cuenta. Es la forma de comprobar si tu lectura de una política era correcta antes de fiarte de ella.

!!! example "Probar el simulador con la política de arriba"
    Si eligieras esta política, la acción `s3:GetObject` y como recurso un objeto dentro de `escaparate-imagenes-<tu-identificador>`, el simulador respondería **Permitido**. Si en cambio probaras `s3:DeleteObject` sobre ese mismo recurso, respondería **Denegado** — esta política nunca menciona esa acción, así que no la concede. Vas a hacer exactamente esta comprobación, con la política real de tu rol, en la Actividad 5.2.

---

## 🧭 Cómo se evalúa una política: quién gana cuando hay varias en juego

Cuando una petición llega a AWS, casi nunca hay una sola política de por medio — pueden aplicar a la vez la del rol, la del propio recurso (como un bucket de S3) y, en una cuenta dentro de una organización, otras por encima que tú ni siquiera puedes ver. El resultado nunca se decide "sumando" políticas: se decide con un orden fijo, siempre el mismo.

```mermaid
flowchart TD
    A["¿Hay algún Deny explícito<br/>en cualquier política aplicable?"] -->|Sí| Deny["❌ Denegado, sin excepciones"]
    A -->|No| B["¿Hay algún Allow explícito?"]
    B -->|Sí| Allow["✅ Permitido"]
    B -->|No| DenyDef["❌ Denegado por defecto<br/>(nadie ha dicho que sí)"]
```

Un *Deny* explícito en cualquiera de las políticas implicadas gana siempre, aunque otra política diga *Allow* — y si ninguna política menciona una acción, esa acción queda denegada por defecto, nunca permitida "por si acaso".

---

## 🔧 Principio de mínimo privilegio y MFA

El **principio de mínimo privilegio** dice que una identidad debe tener exactamente los permisos que necesita para su trabajo, ni uno más. No es una recomendación abstracta — tiene un coste medible cuando se ignora.

```mermaid
flowchart LR
    A["🔓 Permisos amplios<br/>'por si acaso'"] --> B["⚠️ Cualquier fallo o filtración<br/>tiene alcance mucho mayor"]
    C["🔒 Mínimo privilegio"] --> D["✅ Un fallo queda contenido<br/>al alcance estrictamente necesario"]
```

!!! warning "Un comodín de más es la forma más común de romper este principio"
    Una política con `"Action": "s3:*"` en vez de `"Action": "s3:GetObject"` da permiso para borrar, sobrescribir y cambiar permisos de todo el almacenamiento, cuando quizás solo hacía falta leer. Vas a encontrarte exactamente este tipo de error en las políticas que corrijas en la Actividad 5.2.

El **MFA** (*Multi-Factor Authentication*) añade una segunda prueba de identidad —un código temporal, además de la contraseña— para las operaciones más sensibles. En el Learner Lab no lo vas a configurar tú (la identidad ya viene resuelta por el rol asumido), pero es la pieza que, en una cuenta real, protege contra que una contraseña filtrada sea suficiente para entrar.

---

## ⚙️ Gestión de secretos: nunca en el código ni en el repositorio

Ya aplicaste esta regla en el Tema 3 con la contraseña de la base de datos — hoy se generaliza a cualquier secreto: claves de API, tokens, certificados privados. Ninguno debe aparecer nunca en texto plano dentro de un fichero versionado.

```mermaid
flowchart LR
    Secreto["🔑 Secreto"] --> Malo["❌ Escrito en el código<br/>o en un fichero de configuración versionado"]
    Secreto --> Bueno["✅ Secrets Manager / variable de entorno<br/>resuelto en tiempo de ejecución"]
```

!!! danger "Un secreto que ha llegado a un repositorio, aunque lo borres después, sigue expuesto"
    El historial de Git conserva versiones anteriores de cualquier fichero — borrar un secreto en el commit siguiente no lo elimina del historial. La única solución correcta ante un secreto filtrado es rotarlo (generar uno nuevo e invalidar el antiguo), nunca solo "quitarlo" del código.

---

## 📊 Registro de auditoría

El **registro de auditoría** (en AWS, CloudTrail) guarda un histórico de quién ha hecho qué, cuándo y desde dónde — cada llamada a la API queda registrada, tanto si la has hecho tú por consola como por CLI. Ya lo mencionaste como una de las cinco señales de la sesión pasada; hoy lo usas para responder a una pregunta muy concreta: "¿quién ha tocado esto, y cuándo?"

!!! example "Auditoría aplicada a un caso real"
    Imagina que en la incidencia que diagnosticaste la sesión pasada, un grupo de seguridad tenía una regla que no debería estar ahí. Las métricas y los registros te dijeron *qué* estaba fallando; el registro de auditoría te dice *quién* cambió esa regla y *cuándo* — la pieza que faltaba para entender no solo el síntoma, sino el origen del problema.

---

## ✅ Ideas clave

??? tip "Abrir resumen"

    - Un rol se presta temporalmente (con credenciales que caducan); un usuario tiene credenciales fijas — el Learner Lab usa un rol preasignado, y tú no creas roles ni usuarios nuevos.
    - Una política se lee en cuatro campos: efecto (permite/deniega), acción (qué operación), recurso (sobre qué) y condición (bajo qué circunstancia).
    - Cuando hay varias políticas en juego, gana siempre el orden fijo: un *Deny* explícito primero, luego un *Allow* explícito, y si ninguna dice nada, deniega por defecto.
    - El principio de mínimo privilegio limita el alcance de cualquier fallo o filtración; un comodín de más en una acción es el error más común que lo rompe.
    - Ningún secreto va nunca en texto plano en un fichero versionado — y si uno llega a estarlo, la solución es rotarlo, no solo borrarlo del código.
    - El registro de auditoría responde a quién ha hecho qué y cuándo — la pieza que completa el diagnóstico de una incidencia, más allá de las métricas y los registros.

Con esto ya tienes las piezas para la Actividad 5.2 — Gestión de credenciales y políticas IAM.
