# 🧪 Actividad 3.1: S3, EBS y EFS: tres soluciones de almacenamiento

!!! warning "Descarga la plantilla"
    📄 [Plantilla 3.1 — S3, EBS y EFS: tres soluciones de almacenamiento](plantillas/Actividad_3_1_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

Escaparate tiene ahora mismo tres necesidades de almacenamiento distintas, y cada una pide una familia diferente: proteger el front que ya publicaste en S1, ampliar el disco de una instancia que se ha quedado corta, y compartir las imágenes de producto entre varias instancias a la vez. Hoy resuelves las tres, cada una con la herramienta que le corresponde.

## Qué vas a practicar

- Activar versionado y una regla de ciclo de vida sobre un bucket S3 ya existente.
- Ampliar el volumen de disco de una instancia en marcha.
- Crear un sistema de archivos compartido (EFS) y montarlo desde dos instancias distintas.
- Elegir familia y clase de almacenamiento razonando por coste según el patrón de acceso.

## Requisitos previos

El bucket del front de Escaparate de la Actividad 1.1. Al menos una instancia en marcha (puedes reutilizar la de la Actividad 2.2 o 2.3). El apunte de esta sesión — «Servicios de almacenamiento» (almacenamiento.md).

---

## Parte A — Resuelve las tres necesidades de almacenamiento (guiada)

### Paso 1 — Protege el front con versionado y ciclo de vida, desde la consola

1. Entra en el bucket del front de la Actividad 1.1 → pestaña **Propiedades**.
2. Busca **Versionado del bucket** → **Editar** → **Habilitar** → **Guardar cambios**.

![Versionado habilitado en las propiedades del bucket](img/actividad_3_1_paso1_a.png)

3. En el menú lateral del bucket, entra en **Administración** → **Reglas de ciclo de vida** → **Crear regla de ciclo de vida**.
4. Dale un nombre a la regla, y en su ámbito elige aplicarla a todos los objetos del bucket.
5. En las acciones, marca **Mover versiones no actuales a otra clase de almacenamiento**, elige la clase de acceso infrecuente, y define tras cuántos días se aplica (por ejemplo, 30).
6. Crea la regla.

![Regla de ciclo de vida configurada, moviendo versiones antiguas a acceso infrecuente](img/actividad_3_1_paso1_b.png)

7. Sube una versión nueva de algún fichero del front (por ejemplo, cambia una línea de `index.html` y vuelve a subirlo con `aws s3 cp`).
8. En el bucket, activa el interruptor **Mostrar versiones** para comprobar que la versión anterior sigue existiendo, no se ha sobrescrito de verdad.

![Listado de versiones del fichero, mostrando al menos dos](img/actividad_3_1_paso1_c.png)

**Comprueba**: en el panel de versiones del bucket, que ves al menos dos versiones del mismo fichero.
**Captura**: `img/actividad_3_1_paso1_a.png`, `img/actividad_3_1_paso1_b.png` y `img/actividad_3_1_paso1_c.png`.

### Paso 2 — Amplía el disco de una instancia por CLI

Una instancia se ha quedado corta de espacio. Amplía el tamaño de su volumen EBS por CLI, sin tocar la consola:

```bash
aws ec2 modify-volume --volume-id <volume-id> --size <nuevo-tamaño-gb>
```

**Comprueba**: que `aws ec2 describe-volumes-modifications --volume-id <volume-id>` muestra el cambio en estado `optimizing` o `completed`.
**Captura**: la salida de `describe-volumes-modifications`.

### Paso 3 — Comparte las imágenes del catálogo con EFS

1. Busca "EFS" en el buscador de servicios → **Crear sistema de archivos**.
2. En **Personalizar**, elige tu VPC.
3. En el paso de puntos de montaje, deja uno por cada zona de disponibilidad de tu VPC (dos), cada uno en su subred correspondiente.
4. Crea o selecciona un grupo de seguridad que permita el puerto NFS (2049) solo desde el grupo de seguridad de tus instancias — no desde `0.0.0.0/0`.
5. Termina el asistente y crea el sistema de archivos.

![Sistema de archivos EFS creado, con sus dos puntos de montaje](img/actividad_3_1_paso3_a.png)

6. Desde cada una de las dos instancias, instala el cliente NFS si hace falta y monta el sistema de archivos usando el punto de montaje de su propia zona (la consola te da el comando de montaje exacto en la pestaña **Adjuntar** del sistema de archivos).
7. Desde la primera instancia, sube una imagen de producto al directorio montado.
8. Desde la segunda instancia, comprueba que la imagen ya está ahí, sin haberla copiado tú a mano.

![El mismo fichero visible desde las dos instancias tras montar el EFS](img/actividad_3_1_paso3_b.png)

**Comprueba**: que la imagen subida desde la primera instancia aparece inmediatamente visible desde la segunda, sin ningún paso de sincronización manual.
**Captura**: `img/actividad_3_1_paso3_a.png` y `img/actividad_3_1_paso3_b.png`.

!!! question "Reflexiona"
    Has resuelto la misma pregunta —"¿dónde guardo esto?"— de tres formas distintas en la misma sesión. Si mañana necesitaras guardar los informes de ventas mensuales de Escaparate, que solo lee un proceso una vez al mes, ¿cuál de las tres familias elegirías y por qué esa y no las otras dos?

---

## Parte B — El salto: recuperar, ampliar en caliente y decidir por coste (reto)

Tres retos, cada uno más exigente que su equivalente de la Parte A. No hay comandos dados para ninguno — solo el objetivo.

**Recupera lo irrecuperable**: borra "por accidente" un objeto del bucket versionado del Paso 1, y recupéralo sin perder ni una versión. Documenta cómo lo has hecho.

**Amplía en caliente de verdad**: en la Parte A ampliaste el tamaño del volumen desde el lado de AWS, pero el sistema de ficheros de dentro de la instancia todavía no lo sabe — el disco del sistema operativo sigue viendo el tamaño antiguo hasta que tú se lo dices. Consíguelo **sin reiniciar la instancia ni cortar el servicio**, y demuestra con un comando dentro de la instancia que el nuevo espacio ya está disponible para escribir.

**Decide por coste, no por costumbre**: para tres casos de uso (los informes mensuales de la reflexión anterior, el propio front de Escaparate, y una copia de seguridad diaria de la base de datos que verás en la próxima sesión), elige la familia y la clase de almacenamiento más adecuada, calculando el coste estimado por GB almacenado y por operación de lectura/escritura con la calculadora oficial de AWS. Justifica cada elección — la respuesta "S3 estándar para todo" no vale como justificación.

**Comprueba**: que el objeto recuperado tiene exactamente el mismo contenido que antes de borrarlo, y que el nuevo espacio de disco es utilizable de verdad (por ejemplo, escribiendo un fichero de prueba que supere el tamaño original).
**Captura**: el objeto recuperado y su historial de versiones; el comando dentro de la instancia mostrando el nuevo tamaño disponible; la tabla de coste por caso de uso con su justificación.

---

## Verificación

Para dar por válida la práctica se ejecutará:

```bash
aws s3api list-object-versions --bucket <tu-bucket>
aws ec2 describe-volumes --volume-ids <volume-id>
aws efs describe-file-systems
```

Y debe observarse: el bucket con versionado activo y regla de ciclo de vida configurada, el volumen con el tamaño ampliado y el sistema de ficheros interno ya extendido, y el EFS con puntos de montaje activos en las dos zonas.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Versionado y ciclo de vida activos sobre el bucket del front | 2 |
| Disco ampliado por CLI, cambio verificado | 1 |
| EFS creado y montado desde dos instancias, con fichero compartido visible | 3 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Objeto recuperado sin pérdida y disco extendido en caliente, sin cortar servicio | 2 |
| Decisión de familia/clase por coste, justificada para los tres casos | 1 |

---

## ✅ Cierre

Ya sabes elegir familia de almacenamiento según el patrón de acceso, no por costumbre, y sabes que ampliar un disco en AWS es solo la mitad del trabajo — la otra mitad vive dentro del sistema operativo. La próxima sesión dejas de guardar datos sueltos: montas una base de datos relacional gestionada, y conectas el catálogo a ella sin escribir ni una sola credencial en el código.
