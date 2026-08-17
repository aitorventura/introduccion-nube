# 🧪 Actividad 3.3: Arquitectura de tres capas: front, aplicación y base de datos

!!! warning "Descarga la plantilla"
    📄 [Plantilla 3.3 — Arquitectura de tres capas: front, aplicación y base de datos](plantillas/Actividad_3_3_INU_Plantilla.docx){target="_blank" rel="noopener"}

!!! warning "Descarga los recursos"
    📦 [Recursos de la Actividad 3.3](recursos/actividad_3_3_recursos.zip){target="_blank" rel="noopener"} — lo vas a subir y descomprimir en el Paso 2 de esta actividad.

## Contexto

Una aplicación de reseñas de restaurantes locales necesita sus tres capas de siempre —un front que la gente visita, una aplicación que atiende peticiones, una base de datos que guarda las reseñas— y hoy las despliegas las tres desde cero, en una sola sesión, y las conectas de verdad entre sí. Es la primera vez que ves una arquitectura completa en marcha de principio a fin, y el diagrama que documentes hoy es el mapa que vas a usar el resto del módulo.

## Qué vas a practicar

- Crear una base de datos gestionada con su tabla de datos, un backend que se conecta a ella sin credenciales en el código, y un front estático que consume ese backend.
- Integrar en una sola arquitectura las tres capas —datos, aplicación, front— desplegadas hoy mismo.
- Documentar una arquitectura con su diagrama, su coste estimado y sus puntos únicos de fallo.

## Requisitos previos

Una VPC con subred pública y subred privada (la del Tema 2, o una nueva creada para esta sesión). Los apuntes de esta sesión — [«Primera arquitectura completa»](arquitectura-completa.md).

!!! info "Recursos de apoyo"
    En `recursos/tema3/actividad_3_3/` (dentro del zip que has descargado arriba) tienes todo lo necesario, separado en dos carpetas: `backend/` (`schema.sql` con la tabla `resenas`, `app.py`, `requirements.txt` y `arranque-backend.sh`, el script de user-data que instala, configura y arranca el backend solo) y `front/` (`index.html`, `style.css`, `script.js` y `config.js`, el sitio estático que vas a publicar en S3).

---

## Parte A — Despliega la arquitectura completa (guiada)

### Paso 1 — Crea la base de datos de reseñas

!!! warning "Comprueba el permiso antes de la sesión"
    Que el rol preasignado del Learner Lab pueda leer secretos de Secrets Manager no está garantizado en todos los laboratorios. Compruébalo con antelación: si `aws secretsmanager get-secret-value` te da un error de permisos, avisa para resolverlo antes de que el grupo llegue a este paso.

1. Busca "RDS" en el buscador de servicios → **Bases de datos** → **Crear base de datos**.
2. Elige **Creación estándar**, motor **PostgreSQL**.
3. En **Configuración**, escribe un identificador para tu instancia (por ejemplo `resenas-db-<tu-identificador>`).
4. En **Credenciales**, marca **Gestionar credenciales maestras en AWS Secrets Manager**.
5. Elige la clase de instancia más pequeña disponible (nivel gratuito o equivalente).
6. En **Conectividad**, selecciona tu VPC, tu subred privada, y **No** en acceso público.
7. En el grupo de seguridad, crea uno que solo acepte el puerto 5432 desde el grupo de seguridad de la instancia backend que vas a lanzar en el Paso 2.
8. Crea la base de datos y espera a que su estado pase a `available`.

    ![Instancia RDS en estado available, con su endpoint visible](img/actividad_3_3_paso1_a.png)
    *🖼️ Captura de referencia del profesor — guardar como `img/actividad_3_3_paso1_a.png`*

9. Conéctate a la base de datos (por ejemplo con `psql` desde una instancia temporal en la subred pública) y ejecuta `backend/schema.sql` para crear la tabla `resenas` con sus filas de ejemplo.

**Comprueba**: que la instancia RDS aparece como `available` y que la tabla `resenas` tiene datos.

**Captura**: tu propia instancia RDS en estado `available`, con su endpoint visible.

### Paso 2 — Lanza el backend conectado a la base de datos

1. Desde tu **CloudShell** (Tema 1): sube `actividad_3_3_recursos.zip` con **Actions → Upload file** y descomprímelo (`unzip actividad_3_3_recursos.zip`).
2. Adapta `backend/arranque-backend.sh`: sustituye `<nombre-secreto>` por el nombre del secreto de tu base de datos y `<nombre-bd>` por el nombre real — puedes editarlo con el editor de código integrado de CloudShell (`code backend/arranque-backend.sh`), o con `sed`.
3. Lanza la instancia en tu subred pública, con un grupo de seguridad que permita el puerto 80 desde internet, pasando el script adaptado como datos de usuario. El comando usa `file://`, así que ejecútalo desde el mismo CloudShell, dentro de la carpeta `backend/`:

```bash
cd recursos/tema3/actividad_3_3/backend/
aws ec2 run-instances \
  --image-id <ami-amazon-linux> \
  --subnet-id <subnet-publica-id> \
  --security-group-ids <sg-backend-id> \
  --user-data file://arranque-backend.sh
```

4. Espera a que arranque y comprueba `http://<ip-publica-backend>/salud` desde el navegador — debe responder `OK`.

**Comprueba**: que `/salud` responde `OK` y que `/api/resenas` devuelve las reseñas en JSON, sin que te hayas conectado por SSH a configurar nada.

**Captura**: la salida de los logs de arranque (`/var/log/resenas-backend.log`) mostrando la conexión correcta a RDS.

### Paso 3 — Publica el front estático apuntando al backend

1. Edita `front/config.js`: sustituye `<ip-publica-backend>` por la IP pública real de tu instancia del Paso 2.
2. Crea un bucket S3 nuevo, habilita **Alojamiento de sitios web estáticos** en sus propiedades, y sube los cuatro ficheros de `front/`.
3. Abre la URL del sitio web del bucket en el navegador.

![La aplicación de reseñas funcionando de principio a fin, con datos reales](img/actividad_3_3_paso3.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_3_3_paso3.png`*

**Comprueba**: que la página carga y muestra las reseñas reales, viniendo del front (S3) a través del backend (EC2) hasta la base de datos (RDS).

**Captura**: tu propia aplicación de reseñas funcionando de principio a fin, con datos reales.

!!! question "Reflexiona"
    El front en S3 y el backend en EC2 son dos orígenes distintos para el navegador — por eso ha hecho falta habilitar CORS en el backend. ¿Qué error verías en la consola del navegador si no lo hubieras habilitado, y por qué ese error no tiene nada que ver con que la base de datos esté mal configurada?

---

## Parte B — Documenta la arquitectura de verdad (reto)

No hay pasos guiados para esta parte: el reto es producir tres entregables reales a partir de la arquitectura que acabas de desplegar, no de una plantilla genérica.

**El diagrama**: dibuja la arquitectura completa tal como existe de verdad en tu cuenta —las tres capas, todas las subredes, qué habla con qué—, no un diagrama idealizado de manual.

**El coste**: estima el coste mensual real de mantener esta arquitectura funcionando permanentemente, desglosado por servicio (instancia backend, RDS, almacenamiento S3, transferencia), usando la calculadora oficial de AWS.

**Los puntos únicos de fallo**: recorre tu propio diagrama y localiza cada pieza cuya caída, ella sola, tumbaría el sistema completo. No basta con decir "la base de datos" — para cada punto único de fallo que identifiques, explica exactamente qué se rompe y por qué esa pieza en concreto no tiene ningún respaldo ahora mismo.

**Comprueba**: que cada punto único de fallo que documentas corresponde a algo real en tu arquitectura, no a un riesgo genérico copiado de una lista.

**Captura**: el diagrama completo, el desglose de coste por servicio, y la lista de puntos únicos de fallo con su explicación.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Base de datos creada y backend conectado de verdad, sin credenciales en el código | 3 |
| Front estático publicado y mostrando reseñas reales a través del backend | 4 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Diagrama de arquitectura completo y fiel a lo desplegado | 1 |
| Coste mensual estimado, desglosado por servicio | 1 |
| Puntos únicos de fallo identificados y explicados uno a uno | 1 |

---

## ✅ Cierre

Has desplegado una arquitectura de tres capas completa en una sola sesión, con sus tres capas separadas y su base de datos protegida — y tienes en la mano la lista de puntos únicos de fallo que va a marcar el resto del módulo. Con esto se cierra el Tema 3. En el Tema 4 empiezas a resolver esa lista: el primer punto único de fallo que vas a eliminar es que toda la aplicación depende de una única instancia.

!!! danger "Antes de salir: borra la base de datos RDS y la instancia backend"
    Igual que en la Actividad 3.2, la instancia RDS es lo que más factura por hora — bórrala en cuanto termines. Termina también la instancia backend. El bucket del front puedes dejarlo o vaciarlo y borrarlo, su coste es prácticamente nulo. **No borres la VPC ni las subredes del Tema 2** — las sigue necesitando el resto del módulo.
