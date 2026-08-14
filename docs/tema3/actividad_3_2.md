# 🧪 Actividad 3.2: Migración a base de datos gestionada con RDS

!!! warning "Descarga la plantilla"
    📄 [Plantilla 3.2 — Migración a base de datos gestionada con RDS](plantillas/Actividad_3_2_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

El catálogo de Escaparate necesita una base de datos de verdad, y hoy la vas a montar como servicio gestionado en vez de instalarla tú mismo. La condición que la hace realista: ni una sola credencial escrita en el código de la aplicación.

## Qué vas a practicar

- Crear una base de datos PostgreSQL gestionada en subred privada, con sus credenciales fuera del código.
- Conectar una aplicación a esa base de datos resolviendo el secreto en tiempo de ejecución.
- Provocar y medir una conmutación por error real.
- Clasificar patrones de acceso entre los tres modelos de base de datos sin necesidad de montarlos.

## Requisitos previos

La VPC con subred privada del Tema 2, y una instancia en marcha para conectar el catálogo. El apunte de esta sesión — «Bases de datos gestionadas» (bases-datos-gestionadas.md).

---

## Parte A — RDS sin credenciales en el código (guiada)

### Paso 1 — Crea la base de datos desde la consola

!!! warning "Comprueba el permiso antes de la sesión"
    Que el rol preasignado del Learner Lab pueda leer secretos de Secrets Manager no está garantizado en todos los laboratorios. Compruébalo con antelación: si `aws secretsmanager get-secret-value` te da un error de permisos, avisa para resolverlo antes de que el grupo llegue a este paso.

1. Busca "RDS" en el buscador de servicios → **Bases de datos** → **Crear base de datos**.
2. Elige **Creación estándar**, motor **PostgreSQL**.
3. En **Configuración**, escribe un identificador para tu instancia (por ejemplo `escaparate-db-<tu-identificador>`).
4. En **Credenciales**, marca **Gestionar credenciales maestras en AWS Secrets Manager** en lugar de escribir tú una contraseña.
5. Elige la clase de instancia más pequeña disponible (nivel gratuito o equivalente).
6. En **Conectividad**, selecciona tu VPC, tu subred privada, y **No** en acceso público.
7. En el grupo de seguridad, crea uno nuevo o usa uno existente que solo acepte el puerto 5432 desde el grupo de seguridad de tu instancia de aplicación.
8. Crea la base de datos y espera a que su estado pase a `available` (tarda varios minutos).

![Instancia RDS en estado available, con su endpoint visible](img/actividad_3_2_paso1_a.png)

9. Busca "Secrets Manager" en el buscador de servicios y comprueba que existe un secreto asociado a tu base de datos, generado automáticamente — no lo abras para copiar el valor, solo confirma que está ahí.

![Secreto de la base de datos listado en Secrets Manager, sin mostrar su valor](img/actividad_3_2_paso1_b.png)

**Comprueba**: que la instancia RDS aparece como `available`, y que en Secrets Manager existe un secreto asociado a ella que tú no has escrito a mano.
**Captura**: `img/actividad_3_2_paso1_a.png` y `img/actividad_3_2_paso1_b.png`.

### Paso 2 — Conecta el catálogo resolviendo el secreto en tiempo de ejecución

Desde tu instancia de aplicación, recupera el secreto por CLI y úsalo para conectar, sin guardarlo nunca en un fichero del repositorio:

```bash
aws secretsmanager get-secret-value --secret-id <nombre-del-secreto> --query SecretString --output text
```

Usa el valor devuelto para configurar la conexión del catálogo a la base de datos (variable de entorno, no fichero versionado), y comprueba que el catálogo consulta datos reales desde RDS.

![El catálogo mostrando datos reales servidos desde RDS](img/actividad_3_2_paso2.png)

**Comprueba**: que el catálogo muestra datos que vienen de la base de datos, y que en ningún fichero del repositorio aparece la contraseña en texto plano.
**Captura**: `img/actividad_3_2_paso2.png`, y un `grep` sobre el repositorio que no encuentra ninguna credencial en texto plano.

!!! question "Reflexiona"
    Si mañana cambia la contraseña de la base de datos (por ejemplo, por rotación automática), ¿qué parte de tu configuración tendrías que tocar para que el catálogo siga funcionando? Compáralo con lo que habría pasado si la contraseña estuviera escrita directamente en el código.

---

## Parte B — Interrupción real y bases de datos sin montar (reto)

**Provoca una conmutación por error de verdad**: activa Multi-AZ sobre tu instancia RDS y fuerza una conmutación (por ejemplo, reiniciando con conmutación forzada desde la consola). Mide con precisión cuánto tiempo real está el catálogo sin poder consultar la base de datos, desde el primer error hasta la primera consulta correcta tras la conmutación. No hay un procedimiento dado para medirlo — decide tú cómo capturar el instante exacto en que falla y en que se recupera.

**Clasifica sin montar nada**: para cada uno de estos tres patrones de acceso, decide qué modelo de base de datos (relacional, clave-valor o documental) encaja mejor, y justifica por qué los otros dos encajan peor:

1. El carrito de compra temporal de un usuario, que se borra solo a los 30 minutos de inactividad.
2. El catálogo de productos, donde una camiseta tiene talla y color, y un libro tiene autor e ISBN — atributos completamente distintos de un producto a otro.
3. El histórico de pedidos, donde cada informe cruza cliente, pedido y líneas de pedido con consultas complejas.

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
| Catálogo conectado sin credenciales en el código | 3 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Conmutación por error provocada y medida con precisión | 2 |
| Clasificación de los tres patrones de acceso, justificada | 1 |

---

## ✅ Cierre

Ya tienes una base de datos gestionada, protegida en subred privada, con sus credenciales fuera de tu código y de tu vista — y sabes exactamente cuánto dura de verdad una conmutación por error, no solo lo que dice la teoría. La próxima sesión juntas todas las piezas del módulo hasta ahora —red, cómputo, almacenamiento, base de datos— en la primera arquitectura completa de Escaparate.
