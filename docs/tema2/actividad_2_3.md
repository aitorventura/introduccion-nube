# 🧪 Actividad 2.3: De instancia a plantilla

!!! warning "Descarga la plantilla"
    📄 [Plantilla 2.3 — De instancia a plantilla](plantillas/Actividad_2_3_INU_Plantilla.docx){target="_blank" rel="noopener"}

!!! warning "Descarga los recursos"
    📦 [Recursos de la Actividad 2.3](recursos/actividad_2_3_recursos.zip){target="_blank" rel="noopener"} — lo vas a subir y descomprimir en el Paso 1 de esta actividad.

## Contexto

Hasta ahora has lanzado instancias sueltas, a mano, repitiendo los mismos parámetros cada vez. Hoy conviertes ese proceso manual en algo repetible: instalas una aplicación de gestión de turnos de una peluquería en una instancia, capturas el resultado como tu propia imagen, y empaquetas todo en una plantilla de lanzamiento que puedes usar tantas veces como haga falta.

## Qué vas a practicar

- Automatizar el despliegue de la aplicación con user data, sin conectarte a mano a la instancia.
- Crear tu propia imagen de máquina (AMI) a partir de una instancia ya configurada.
- Construir una plantilla de lanzamiento parametrizada y lanzar varias instancias idénticas desde ella.
- Comparar coste mensual entre familias de instancia para la misma carga.

## Requisitos previos

La VPC de dos zonas de la Actividad 2.1, con su subred pública ya creada — hoy lanzas una instancia nueva sobre ella, no reutilizas la de la Actividad 2.2. Los apuntes de esta sesión — [«Máquinas virtuales»](maquinas-virtuales.md).

---

## Parte A — De instancia manual a imagen propia (guiada)

### Paso 1 — Despliega la app de turnos con user data, solo en los puertos necesarios

Lanza una instancia nueva en tu subred pública, con un grupo de seguridad que abra **únicamente** el puerto 80 (y el 22 restringido a tu IP para poder revisar si algo falla), y con un script de user data que instale y arranque, sin intervención tuya, la app de gestión de turnos de la peluquería. El comando siguiente usa `file://` para leer el script desde donde lo ejecutes — así que hazlo desde tu **CloudShell** (Tema 1), no desde tu ordenador: sube `actividad_2_3_recursos.zip` con **Actions → Upload file** y descomprímelo (`unzip actividad_2_3_recursos.zip`) para tener `instalar-catalogo.sh` ahí mismo, en `recursos/tema2/actividad_2_3/`.

```bash
cd recursos/tema2/actividad_2_3/
aws ec2 run-instances \
  --image-id <ami-base> \
  --instance-type t3.micro \
  --subnet-id <subnet-publica-id> \
  --security-group-ids <sg-minimo> \
  --user-data file://instalar-catalogo.sh
```

![La app de turnos funcionando en el navegador](img/actividad_2_3_paso1.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_2_3_paso1.png`*

**Comprueba**: que la app responde en el puerto 80 sin que te hayas conectado nunca por SSH a instalarla a mano, y que ningún otro puerto además del 80 y el 22 (restringido) está abierto.

**Captura**: tu propia app de turnos funcionando en el navegador, y el grupo de seguridad mostrando solo los puertos estrictamente necesarios.

### Paso 2 — Crea tu propia imagen desde la consola

Con la instancia del Paso 1 ya funcionando y estable, captúrala como AMI propia:

1. En el panel de **Instancias**, selecciona (marca la casilla) tu instancia con el catálogo desplegado.
2. Ve a **Acciones → Imagen y plantillas → Crear imagen**.
3. Dale un nombre que la identifique como tuya, por ejemplo `turnos-app-<tu-identificador>`.
4. Deja el resto de opciones por defecto y haz clic en **Crear imagen**.
5. Ve al menú lateral, a **AMIs** (dentro de Imágenes), y espera a que el estado pase de `pending` a `available` — tarda unos minutos.

![La AMI propia en estado available, con su nombre y tamaño](img/actividad_2_3_paso2.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_2_3_paso2.png`*

**Comprueba**: que la imagen aparece como disponible (`available`) al cabo de unos minutos, y que su tamaño y descripción tienen sentido.

**Captura**: tu propia AMI en estado `available`, con su nombre y tamaño visibles.

---

## Parte B — Plantilla de lanzamiento y comparación de coste (reto)

**Antes de construir nada, predice**: si empaquetas tu propia AMI en una plantilla de lanzamiento y arrancas una instancia desde ella, ¿cuánto crees que va a tardar en estar respondiendo, comparado con el tiempo que tardó la instancia de la Actividad 2.2 (que instalaba el servidor desde cero vía user data sobre una imagen genérica)? Escribe tu predicción y por qué crees eso.

El reto: construye una plantilla de lanzamiento parametrizada con tu propia imagen, lánzale dos instancias idénticas desde ella y demuestra, cronometrando de verdad, si tu predicción se ha cumplido. No hay comandos dados — decide tú qué parámetros lleva la plantilla y cómo mides el tiempo de arranque de forma justa.

Con eso hecho, compara el coste mensual estimado de mantener esta misma carga (una instancia sirviendo la app de turnos, tráfico moderado) en tres familias distintas de instancia, usando la calculadora oficial de AWS, y justifica cuál elegirías para producción y cuál para clase.

**Comprueba**: que las dos instancias lanzadas desde la plantilla responden con la app de turnos sin ninguna configuración adicional, exactamente igual que la instancia original.

**Captura**: el cronómetro real de arranque de las dos instancias, tu predicción escrita de antemano, y la tabla comparativa de coste mensual de las tres familias con su justificación.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| App de turnos desplegada automáticamente con user data, puertos mínimos | 3 |
| Imagen propia creada a partir de la instancia | 4 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Plantilla de lanzamiento funcionando, dos instancias idénticas lanzadas | 2 |
| Comparación de tiempos y de coste entre tres familias, con predicción previa | 1 |

---

## ✅ Cierre

Ya tienes una imagen propia y una plantilla parametrizada — puedes lanzar tantas copias idénticas del catálogo como necesites, sin repetir la instalación ni un solo parámetro a mano. Con esto se cierra el Tema 2: tienes la red, la seguridad y las instancias resueltas. En el Tema 3 vas a decidir dónde guardar los datos de verdad — objetos, ficheros compartidos y una base de datos gestionada— y a montar la primera arquitectura completa de tres capas.

!!! danger "Antes de salir: borra las instancias, no la imagen ni la VPC"
    Termina la instancia del Paso 1 y, si has hecho la Parte B, las dos que has lanzado desde la plantilla — ninguna le sirve a otra actividad después de hoy. Tu AMI propia y la plantilla de lanzamiento puedes dejarlas, apenas tienen coste. **No borres la VPC ni las subredes** — las sigue necesitando el resto del módulo.
