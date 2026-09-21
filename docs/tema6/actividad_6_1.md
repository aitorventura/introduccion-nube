# 🧪 Actividad 6.1: Destruir y reconstruir

!!! warning "Descarga la plantilla"
    📄 [Plantilla 6.1 — Destruir y reconstruir](plantillas/Actividad_6_1_INU_Plantilla.docx){target="_blank" rel="noopener"}

!!! warning "Descarga los recursos"
    📦 [Recursos de la Actividad 6.1](recursos/actividad_6_1_recursos.zip){target="_blank" rel="noopener"} — lo vas a subir y descomprimir en el Paso 2 de esta actividad.

## Contexto

Desde el Tema 3 has ejecutado `terraform apply` sobre la red de cada sesión sin haber abierto nunca el fichero que la describe. Hoy trabajas con un módulo de Terraform más pequeño, autocontenido, que despliega una VPC de ejemplo con una subred pública y una privada — descárgalo del enlace de arriba, en `recursos/tema6/actividad_6_1/terraform/`. Lo lees, lo modificas, compruebas qué ve Terraform (y qué no) cuando alguien toca la infraestructura a mano, y lo destruyes y reconstruyes por completo, cronometrando cuánto tarda el código en hacer lo que a mano, clic a clic en la consola, te llevaría mucho más y sería fácil de dejar a medias.

## Qué vas a practicar

- Leer un módulo de Terraform ya escrito y entender qué infraestructura describe antes de ejecutarlo.
- Modificarlo, revisar el plan antes de aplicar, y aplicarlo de verdad.
- Distinguir en un plan los cambios que se hacen en el sitio de los que destruyen y vuelven a crear un recurso.
- Comprobar qué ve Terraform, y qué no, cuando alguien cambia o crea algo a mano.
- Desplegar dos entornos con el mismo código sin que uno pise al otro.
- Medir el tiempo real de destruir y reconstruir una infraestructura completa desde código.

## Requisitos previos

Terraform instalado desde la Actividad 3.1 (comprueba con `terraform -version`; si no aparece, repite la instalación de la 3.1). El módulo de Terraform (`main.tf`, `variables.tf`, `outputs.tf`) — descárgalo del enlace de arriba. Los apuntes de esta sesión — [«Infraestructura como código»](infraestructura-como-codigo.md).

No necesitas nada de lo que has construido en los Temas 3, 4 y 5: al cerrar la 5.3 has dejado la cuenta prácticamente vacía (solo quedan los buckets de S3) y el módulo de hoy trae su propia red.

!!! warning "A tu CloudShell le cabe 1 GB: hoy solo cabe un `terraform init`"
    El proveedor de AWS que descarga `terraform init` pesa unos **675 MB**, y tu CloudShell tiene 1 GB en total. Si el proveedor de la red del Tema 3 sigue en su carpeta, el `init` de hoy fallará con `no space left on device`. Como esa red ya está destruida, borrar ese proveedor no pierde nada —`terraform init` lo vuelve a descargar si algún día lo necesitas—:

    ```bash
    rm -rf ~/recursos/tema3/red-base/.terraform
    rm -f ~/*_recursos.zip
    ```

    Por la misma razón, **hoy solo puedes hacer un `terraform init`**: no podrás copiar el módulo a otra carpeta e inicializarlo de nuevo. Tenlo presente en la Parte B.

---

## Parte A — Lee, modifica y comprueba qué ve Terraform (guiada)

### Paso 1 — Lee el módulo antes de tocar nada

Descomprime el zip que has descargado, abre los tres ficheros `.tf` en cualquier editor de texto y localiza, sin ejecutar todavía nada:

1. Qué recursos declara (busca los bloques `resource`).
2. Qué variables acepta (bloques `variable`, en `variables.tf`), cuál de ellas no tiene valor por defecto y qué implica eso al ejecutar, y qué salidas expone al terminar (bloques `output`, en `outputs.tf`).
3. Qué información lee de AWS sin crearla (busca el bloque `data`) y en qué recurso la usa.
4. Qué rango CIDR resulta para cada subred con los valores por defecto (mira cómo se calcula con `cidrsubnet` en la teoría).

Antes de seguir, escribe dos cosas: **cuántos recursos crees que va a crear `terraform apply`**, y, en tus propias palabras, qué infraestructura completa describe el módulo.

**Comprueba**: que tu descripción coincide con lo que realmente declaran los ficheros — una VPC, una subred pública y una privada en dos zonas de disponibilidad distintas, una pasarela de internet, una tabla de rutas y la asociación de esa tabla con la subred pública — y que los rangos de las dos subredes no se solapan.

**Captura**: el fichero `main.tf` abierto en tu editor, con el nombre de cada bloque `resource` rodeado o subrayado (si no cabe en una sola captura, haz dos). Tu predicción y tu descripción del módulo no son una captura: las escribes en la plantilla.

### Paso 2 — Inicializa y aplica por primera vez

Desde tu **CloudShell** (Tema 1), con la región **US East (N. Virginia)** que has usado siempre:

1. Libera espacio con los dos comandos del aviso de arriba (si no lo has hecho ya).
2. Sube `actividad_6_1_recursos.zip` con **Actions → Upload file** y descomprímelo:

    ```bash
    unzip actividad_6_1_recursos.zip
    ```

3. Comprueba que Terraform está disponible (`terraform -version`) y entra en la carpeta del módulo:

    ```bash
    cd recursos/tema6/actividad_6_1/terraform/
    ```

4. El módulo pide tu `identificador` (la variable no tiene valor por defecto) para poner tu nombre a los recursos, igual que en `red-base`. En vez de escribirlo con `-var` en cada comando, guárdalo en un fichero `terraform.tfvars`, que Terraform lee solo al ejecutarse en esa carpeta. Después inicializa el módulo: el `init` tarda un rato porque descarga el proveedor de AWS.

    ```bash
    echo 'identificador = "<tu-identificador>"' > terraform.tfvars
    terraform init
    terraform plan
    ```

    Lee el plan con atención antes de continuar: cuántos recursos va a crear, y si coincide con la cifra que anotaste en el Paso 1.

5. Aplícalo y confirma cuando te lo pida:

    ```bash
    terraform apply
    ```

6. Abre la consola de AWS, **VPC → Sus VPC**, y comprueba que existe la `vpc-actividad61-<tu-identificador>-dev` con sus subredes.

![La VPC y las subredes creadas por Terraform, visibles en la consola de AWS](img/actividad_6_1_paso2.png)

**Comprueba**: que el número de recursos creados coincide exactamente con lo que mostraba el plan, y que la VPC y las subredes de la consola tienen los nombres y los rangos que leíste en el Paso 1.

**Captura**: la salida de `terraform apply` con el resumen final, y tu propia VPC con las subredes creadas por Terraform, visibles en la consola de AWS.

### Paso 3 — Modifica el módulo para añadir una subred

Añade una tercera subred al módulo (por ejemplo, otra privada en una de las dos zonas), editando el código — no la consola. Para editar en CloudShell puedes usar `nano main.tf` (baja hasta el final del fichero, escribe el bloque nuevo, guarda con `Ctrl+O` e `Intro`, y sal con `Ctrl+X`). Fíjate en cómo están declaradas `publica` y `privada`, y en qué es lo que distingue el rango de una de otra. Antes de aplicar:

```bash
terraform plan
```

**Comprueba**: que el plan muestra únicamente la creación de la subred nueva, sin tocar ni destruir ninguno de los recursos que ya existían.

```bash
terraform apply
```

**Comprueba**: que la subred nueva aparece en la consola con exactamente el CIDR y la zona que has definido en el código.

**Captura**: el plan mostrando solo la creación añadida, y la subred nueva visible en consola.

!!! question "Reflexiona"
    Añadir una subred a mano en la consola significa varios clics, sin ningún registro de qué has cambiado ni por qué. Hoy ha quedado como un bloque de código que se puede guardar en Git, con el mensaje de quién lo ha cambiado y por qué. Si dentro de tres meses alguien pregunta por qué existe esa subred nueva, ¿qué respuesta te da el código que nunca te habría dado la consola?

### Paso 4 — Cambios que se hacen en el sitio y cambios que destruyen

No todos los cambios se aplican igual, y el plan te lo avisa con un símbolo (`~` o `-/+`, en la teoría). Vas a hacer tres pruebas; **antes de cada `terraform plan`, escribe qué esperas ver**.

1. Añade una etiqueta nueva a la VPC, `Curso = "INU"`, dentro de su bloque `tags`. Predice si el plan mostrará `~` o `-/+`, ejecútalo, léelo y aplícalo.
2. Sin tocar nada más, ejecuta `terraform plan` otra vez. Predice qué dirá.
3. Comprueba qué pasaría si cambiaras el rango de red de la VPC, sin llegar a hacerlo: ejecuta `terraform plan -var="vpc_cidr=10.2.0.0/16"`. Predice antes cuántos recursos se verán afectados y de qué manera, y **no lo apliques**. Anota el resumen final del plan.

**Comprueba**: que la etiqueta se ha aplicado sin destruir nada, que el segundo plan no propone ningún cambio, y que el cambio de rango sí habría destruido y vuelto a crear recursos.

**Captura**: el plan del primer cambio con su símbolo, el plan sin cambios, y el resumen final del plan del rango de red.

!!! question "Reflexiona"
    Si dentro de esa VPC hubiera una base de datos RDS, ¿qué habría pasado con sus datos al aplicar el tercer plan? ¿Qué te dice eso sobre leer el plan antes de aplicar?

### Paso 5 — Lo que Terraform no ve

Terraform solo conoce lo que ha creado él. Lo vas a comprobar con dos cambios hechos a mano, en la consola:

1. **VPC → Grupos de seguridad → Crear grupo de seguridad**. Ponle el nombre `grupo-a-mano` (AWS no admite nombres que empiecen por `sg-`), una descripción cualquiera, y como VPC elige `vpc-actividad61-<tu-identificador>-dev`, la que ha creado Terraform. Pulsa **Crear grupo de seguridad**.
2. **Predice** si `terraform plan` va a mencionar ese grupo. Ejecútalo.
3. **VPC → Sus VPC**, selecciona tu VPC → pestaña **Etiquetas** → **Administrar etiquetas**, y cambia el valor de la etiqueta `Name` por `vpc-cambiada-a-mano`.
4. **Predice** qué mostrará ahora el plan. Ejecútalo, y después aplícalo. Vuelve a mirar el nombre de la VPC en la consola.

**Comprueba**: que el grupo de seguridad no aparece en el plan (Terraform no sabe que existe), y que el cambio de nombre sí, y que tras aplicarlo la VPC recupera el nombre que dice el código.

**Captura**: los dos planes, y la consola con el nombre de la VPC ya restaurado.

!!! question "Reflexiona"
    Deja `grupo-a-mano` donde está: lo borrarás tú en el Cierre. ¿Qué crees que pasará con la VPC cuando ejecutes `terraform destroy` si no lo has borrado antes? ¿Por qué Terraform no lo borra por su cuenta? Te ayuda la tabla de los tres mundos de la teoría («El fichero de estado»), sobre todo su última fila.

---

## Parte B — Dos entornos, una instancia y un cronómetro (reto)

**Despliega dos entornos con el mismo código, a la vez.** Al terminar tienes que tener en tu cuenta dos VPC creadas desde este mismo código: una `dev` y otra `prod`, con rangos de red distintos (`vpc_cidr`), y poder destruir una sin que la otra se entere. El módulo ya trae una variable `environment` que admite los valores `dev` y `prod`.

Empieza por una prueba que no toca nada. Ahora mismo tienes `dev` desplegado:

1. **Predice**, antes de ejecutar nada: si cambias solo el entorno y ejecutas `terraform plan -var="environment=prod"` en la carpeta donde ya tienes `dev`, ¿va a proponer crear una segunda VPC junto a la primera, o va a hacer otra cosa? Ayúdate de lo que has visto en la teoría sobre qué recuerda Terraform de lo que ha creado.
2. Ejecútalo (solo `plan`, no apliques) y anota el resumen final. ¿Has acertado?

Lo que veas en ese plan te dice dónde está el problema. Ahora el reto: encuentra la forma de tener los dos entornos a la vez con el mismo código. Terraform ofrece más de una manera de resolverlo, así que investiga cuál te conviene, recordando que hoy solo puedes hacer un `terraform init`. Cuando lo consigas, comprueba en la consola de AWS que existen las dos VPC.

!!! tip "Pista: un estado por entorno"
    Todo el problema viene de que hay un solo fichero de estado. Hay tres maneras de tener uno por entorno:

    - Los **workspaces** de Terraform (`terraform workspace --help`): el mismo código con varios estados con nombre, y sin necesidad de otro `init`.
    - Indicar un fichero de estado distinto en cada orden con la opción `-state=<fichero>`.
    - Copiar el módulo a otra carpeta. Aquí no sirve, porque cada carpeta necesitaría su propio `init`.

    Elige una y sé capaz de justificar por qué. Recuerda que cada orden lleva su `-var`, y que `prod` necesita un `vpc_cidr` distinto del de `dev`.

**Añade una instancia de prueba al módulo**: extiende el código para que, en cada entorno, se despliegue también una instancia EC2 mínima con un servidor web sencillo arrancado por `user_data` (por ejemplo, nginx sirviendo una página que diga en qué entorno estás). Tiene que quedar declarada directamente dentro del módulo, sin plantilla de lanzamiento externa y sin nada creado a mano. La variable `instance_type` ya existe en `variables.tf`, pero todavía no la usa nadie. Tendrás que decidir de dónde sale la imagen (AMI) de la instancia —el módulo ya te enseña cómo se lee información de AWS sin crearla— y qué deja pasar el tráfico HTTP hacia ella. Antes de aplicar, anota cuántos recursos nuevos esperas que aparezcan en el plan. El código es uno solo, pero cada entorno tiene su propio estado: para que la instancia aparezca en `dev` y en `prod`, el cambio tendrás que aplicarlo en cada uno de los dos, con las mismas opciones con las que los creaste, y en cada `plan` solo deberían salir recursos nuevos.

**Cronometra destruir y reconstruir**: destruye uno de los dos entornos por completo y vuelve a crearlo desde cero, cronometrando el tiempo real desde el primer comando hasta que la instancia vuelve a responder (`time` delante de un comando te da su duración). Compáralo con una estimación razonada de lo que tardarías en montar la misma infraestructura a mano, clic a clic en la consola.

**Comprueba**: que los dos entornos coexisten sin pisarse (cada uno con su VPC, su rango y su instancia), que la instancia de cada entorno responde con su propia página, y que tras destruir y reconstruir un entorno no queda ningún recurso huérfano de la versión anterior.

**Captura**: el código que has añadido; tu predicción del primer punto junto a lo que ha mostrado el plan; los dos entornos desplegados y visibles en consola; y el cronómetro real de destruir/reconstruir, comparado con tu estimación del montaje manual.

---

## Criterios de evaluación

**Parte A — hasta 6 puntos**

| Apartado | Puntos |
|---|---|
| Módulo leído y entendido: descripción correcta y predicción del número de recursos antes de ejecutar | 1 |
| Aplicado con el plan revisado antes de cada cambio, y subred añadida por código sin tocar los recursos existentes | 2 |
| Cambios en el sitio frente a cambios que destruyen: predicciones razonadas y plan leído correctamente | 2 |
| Cambio y grupo de seguridad hechos a mano: qué ve Terraform y qué no, explicado con lo que muestra el plan | 1 |

**Parte B — reto, hasta 4 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Dos entornos con el mismo código sin pisarse, con la predicción inicial contrastada | 2 |
| Instancia de prueba operativa en cada entorno | 1 |
| Cronómetro de destruir/reconstruir, comparado con la estimación del montaje manual, sin recursos huérfanos | 1 |

---

## ✅ Cierre

Ya sabes leer, modificar y reconstruir infraestructura completa desde código, con un plan que revisas antes de aplicar cualquier cambio — y has comprobado con tus propios ojos qué hace Terraform con lo que él no ha creado. La próxima sesión subes un peldaño más en la escalera de responsabilidad: dejas de gestionar instancias del todo, y ejecutas código sin ningún servidor que tú administres.

!!! danger "Antes de salir: destruye todo lo de hoy"
    La limpieza de hoy está casi automatizada, pero hay un paso a mano que no puedes saltarte:

    1. **Borra a mano `grupo-a-mano`** (consola de VPC → Grupos de seguridad). Terraform no lo conoce: si sigue dentro de la VPC cuando `terraform destroy` llegue a ella, se quedará minutos esperando en `Still destroying...`.
    2. Ejecuta `terraform destroy` en cada entorno que hayas desplegado (con los mismos `-var` que has usado al aplicar) — confirma cuando te lo pida, igual que has hecho con `apply`. No dejes ninguno a medias: recuerda que la propia actividad te pedía comprobar que no queda ningún recurso huérfano.
    3. Libera el espacio para las próximas sesiones (la 6.3 necesita construir una imagen de contenedor): `rm -rf ~/recursos/tema6/actividad_6_1/terraform/.terraform`.
    4. Comprueba en **VPC → Sus VPC** que ya no queda ninguna `vpc-actividad61-<tu-identificador>-*`. Los buckets de S3 los dejas: la 6.2 reutiliza el de imágenes.
