# 🧪 Actividad 3.2: Migración a base de datos gestionada con RDS

!!! warning "Descarga la plantilla"
    📄 [Plantilla 3.2 — Migración a base de datos gestionada con RDS](plantillas/Actividad_3_2_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

El sistema de reservas de una biblioteca de barrio necesita una base de datos de verdad para su catálogo de libros y sus préstamos, y hoy la vas a montar como servicio gestionado en vez de instalarla tú mismo. La condición que la hace realista: ni una sola credencial escrita en el código de la aplicación.

## Qué vas a practicar

- Crear una base de datos PostgreSQL gestionada en subred privada, con sus credenciales fuera del código.
- Conectar una aplicación a esa base de datos resolviendo el secreto en tiempo de ejecución.
- Provocar y medir una conmutación por error real.
- Clasificar patrones de acceso entre los tres modelos de base de datos sin necesidad de montarlos.

## Requisitos previos

La VPC con subred privada del Tema 2, y una instancia en marcha en subred pública para conectar la aplicación de la biblioteca. El apunte de esta sesión — «Bases de datos gestionadas» (bases-datos-gestionadas.md).

!!! info "Recursos de apoyo"
    En `recursos/tema3/actividad_3_2/` tienes los cuatro ficheros que necesitas para esta actividad: `schema.sql` (la tabla `libros` con datos de ejemplo), `app.py` (la aplicación Flask que consulta el catálogo), `requirements.txt` (sus dependencias) y `arranque-app.sh` (el script de user-data que instala todo, resuelve el secreto de Secrets Manager y arranca la aplicación sola en el primer arranque de la instancia).

---

## Parte A — RDS sin credenciales en el código (guiada)

### Paso 1 — Crea la base de datos desde la consola

!!! warning "Comprueba el permiso antes de la sesión"
    Que el rol preasignado del Learner Lab pueda leer secretos de Secrets Manager no está garantizado en todos los laboratorios. Compruébalo con antelación: si `aws secretsmanager get-secret-value` te da un error de permisos, avisa para resolverlo antes de que el grupo llegue a este paso.

1. Busca "RDS" en el buscador de servicios → **Bases de datos** → **Crear base de datos**.
2. Elige **Creación estándar**, motor **PostgreSQL**.
3. En **Configuración**, escribe un identificador para tu instancia (por ejemplo `biblioteca-db-<tu-identificador>`).
4. En **Credenciales**, marca **Gestionar credenciales maestras en AWS Secrets Manager** en lugar de escribir tú una contraseña.
5. Elige la clase de instancia más pequeña disponible (nivel gratuito o equivalente).
6. En **Conectividad**, selecciona tu VPC, tu subred privada, y **No** en acceso público.
7. En el grupo de seguridad, crea uno nuevo o usa uno existente que solo acepte el puerto 5432 desde el grupo de seguridad de tu instancia de aplicación.
8. Crea la base de datos y espera a que su estado pase a `available` (tarda varios minutos).

![Instancia RDS en estado available, con su endpoint visible](img/actividad_3_2_paso1_a.png)

9. Busca "Secrets Manager" en el buscador de servicios y comprueba que existe un secreto asociado a tu base de datos, generado automáticamente — no lo abras para copiar el valor, solo confirma que está ahí.

![Secreto de la base de datos listado en Secrets Manager, sin mostrar su valor](img/actividad_3_2_paso1_b.png)

10. Conéctate a la base de datos (por ejemplo desde tu instancia, con `psql`) y ejecuta `schema.sql` de `recursos/tema3/actividad_3_2/` para crear la tabla `libros` con sus filas de ejemplo.

**Comprueba**: que la instancia RDS aparece como `available`, que en Secrets Manager existe un secreto asociado a ella que tú no has escrito a mano, y que la tabla `libros` tiene datos.
**Captura**: `img/actividad_3_2_paso1_a.png` y `img/actividad_3_2_paso1_b.png`.

### Paso 2 — Conecta la aplicación resolviendo el secreto en tiempo de ejecución

1. Adapta `arranque-app.sh` de `recursos/tema3/actividad_3_2/`: sustituye `<nombre-secreto>` por el nombre real de tu secreto y `<nombre-bd>` por el nombre de tu base de datos.
2. Lanza (o reutiliza) tu instancia de aplicación en la subred pública, pegando el script adaptado como datos de usuario. El script instala las dependencias, escribe la aplicación, recupera el secreto por CLI y arranca la aplicación sola — sin que te conectes por SSH a configurar nada.
3. Abre la URL pública de la instancia en el puerto 80 y comprueba que la aplicación muestra el catálogo de libros con datos reales de RDS.

```bash
aws secretsmanager get-secret-value --secret-id <nombre-del-secreto> --query SecretString --output text
```

![La aplicación mostrando el catálogo de libros con datos reales servidos desde RDS](img/actividad_3_2_paso2.png)

**Comprueba**: que la aplicación muestra datos que vienen de la base de datos, y que en ningún fichero del repositorio aparece la contraseña en texto plano.
**Captura**: `img/actividad_3_2_paso2.png`, y un `grep` sobre el repositorio que no encuentra ninguna credencial en texto plano.

!!! question "Reflexiona"
    Si mañana cambia la contraseña de la base de datos (por ejemplo, por rotación automática), ¿qué parte de tu configuración tendrías que tocar para que la aplicación siga funcionando? Compáralo con lo que habría pasado si la contraseña estuviera escrita directamente en el código.

---

## Parte B — Interrupción real y bases de datos sin montar (reto)

**Provoca una conmutación por error de verdad**: activa Multi-AZ sobre tu instancia RDS y fuerza una conmutación (por ejemplo, reiniciando con conmutación forzada desde la consola). Mide con precisión cuánto tiempo real está la aplicación sin poder consultar la base de datos, desde el primer error hasta la primera consulta correcta tras la conmutación. No hay un procedimiento dado para medirlo — decide tú cómo capturar el instante exacto en que falla y en que se recupera.

**Clasifica sin montar nada**: para cada uno de estos tres patrones de acceso, decide qué modelo de base de datos (relacional, clave-valor o documental) encaja mejor, y justifica por qué los otros dos encajan peor:

1. La sesión temporal de un usuario que consulta el catálogo desde el navegador, que se borra sola a los 30 minutos de inactividad.
2. El catálogo de la biblioteca, donde un libro tiene autor e ISBN, una revista tiene periodicidad y número, y un DVD tiene duración y clasificación por edad — atributos completamente distintos de un ítem a otro.
3. El histórico de préstamos, donde cada informe cruza socio, préstamo y ejemplar con consultas complejas.

**Comprueba**: que tu medición de interrupción tiene un instante de inicio y uno de fin claramente identificados, no una estimación aproximada.
**Captura**: el cronómetro o registro de la interrupción real, y la tabla de los tres patrones de acceso con el modelo elegido y su justificación.

---

## Verificación

Para dar por válida la práctica se ejecutará:

```bash
aws rds describe-db-instances --db-instance-identifier <tu-instancia-rds>
aws secretsmanager describe-secret --secret-id <nombre-del-secreto>
```

Y debe observarse: la instancia RDS en subred privada, con Multi-AZ activo, credenciales gestionadas por Secrets Manager, y ningún fichero del repositorio con una contraseña en texto plano.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| RDS creada en subred privada, credenciales por Secrets Manager | 3 |
| Aplicación conectada sin credenciales en el código | 3 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Conmutación por error provocada y medida con precisión | 2 |
| Clasificación de los tres patrones de acceso, justificada | 1 |

---

## ✅ Cierre

Ya tienes una base de datos gestionada, protegida en subred privada, con sus credenciales fuera de tu código y de tu vista — y sabes exactamente cuánto dura de verdad una conmutación por error, no solo lo que dice la teoría. La próxima sesión despliegas una arquitectura de tres capas completa desde cero: front, aplicación y base de datos trabajando juntas por primera vez.
