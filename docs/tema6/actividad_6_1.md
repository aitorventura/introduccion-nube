# 🧪 Actividad 6.1: Destruir y reconstruir

!!! warning "Descarga la plantilla"
    📄 [Plantilla 6.1 — Destruir y reconstruir](plantillas/Actividad_6_1_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

El profesor te entrega un módulo de Terraform ya escrito que reproduce, en código, la misma VPC básica que montaste a mano en el Tema 2. Hoy la lees, la entiendes, la modificas, y la destruyes y reconstruyes por completo — cronometrando cuánto tarda el código en hacer lo que a ti te llevó una sesión entera a mano.

## Qué vas a practicar

- Leer un módulo de Terraform ya escrito y entender qué infraestructura describe.
- Modificarlo, revisar el plan antes de aplicar, y aplicarlo de verdad.
- Parametrizar el código para desplegar dos entornos distintos con el mismo módulo.
- Medir el tiempo real de destruir y reconstruir una infraestructura completa desde código.

## Requisitos previos

Terraform instalado o disponible en tu entorno de trabajo. El módulo de Terraform que te entrega el profesor. El apunte de esta sesión — «Infraestructura como código» (infraestructura-como-codigo.md).

---

## Parte A — Lee, modifica y aplica con plan (guiada)

### Paso 1 — Lee el módulo antes de tocar nada

Abre los ficheros `.tf` del módulo que te ha entregado el profesor y localiza, sin ejecutar todavía nada:

1. Qué recursos declara (busca los bloques `resource`).
2. Qué variables acepta (busca los bloques `variable`, normalmente en un fichero `variables.tf`).
3. Qué salidas expone al terminar (busca los bloques `output`).

Anota, en tus propias palabras, qué infraestructura completa describe el módulo — sin ejecutarlo, solo leyéndolo.

**Comprueba**: que tu descripción coincide con lo que realmente construiste a mano en el Tema 2 (misma VPC, mismo número de subredes).
**Captura**: tu descripción escrita del módulo, junto a una captura del propio fichero `.tf` con los recursos señalados.

### Paso 2 — Inicializa y aplica por primera vez

```bash
terraform init
terraform plan
```

Lee el plan con atención antes de continuar: cuántos recursos va a crear, y si coincide con tu lectura del Paso 1.

```bash
terraform apply
```

Confirma cuando te lo pida. Al terminar, comprueba en la consola de AWS que la VPC y las subredes existen de verdad.

![La VPC y las subredes creadas por Terraform, visibles en la consola de AWS](img/actividad_6_1_paso2.png)

**Comprueba**: que el número de recursos creados coincide exactamente con lo que mostraba el plan.
**Captura**: la salida de `terraform apply` con el resumen final, y `img/actividad_6_1_paso2.png`.

### Paso 3 — Modifica el módulo para añadir una subred

Añade una quinta subred al módulo (por ejemplo, otra privada en una de las dos zonas), editando el código — no la consola. Antes de aplicar:

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
    En el Tema 2 añadir una subred a mano significaba varios clics en la consola, sin ningún registro de qué habías cambiado ni por qué. Hoy ha quedado como una línea de código, con su commit. Si dentro de tres meses alguien pregunta por qué existe esa quinta subred, ¿qué respuesta te da el código que nunca te habría dado la consola?

---

## Parte B — Parametriza, despliega dos entornos y cronometra (reto)

**Parametriza el módulo**: modifica el código para que el entorno (por ejemplo `dev` o `prod`), el rango de red y el tipo de instancia sean variables, no valores fijos escritos dentro del código. No hay una estructura de variables dada — decide tú qué parámetros necesitas y cómo los organizas.

**Despliega dos entornos con el mismo código**: usando las variables del punto anterior, despliega dos instancias completas de la infraestructura (por ejemplo, `dev` y `prod`) que no choquen entre sí — mismos recursos, rangos y nombres distintos.

**Añade la instancia del catálogo al módulo**: extiende el código para que también despliegue una instancia con el catálogo de Escaparate, usando la misma plantilla de lanzamiento del Tema 2.

**Cronometra destruir y reconstruir**: destruye uno de los dos entornos por completo y vuelve a crearlo desde cero, cronometrando el tiempo real desde el primer comando hasta que la infraestructura vuelve a estar disponible. Compáralo con el tiempo que recuerdes (o hayas documentado) que te costó montar la misma VPC a mano en el Tema 2.

**Comprueba**: que los dos entornos coexisten sin conflicto de nombres ni de rangos, y que tras destruir y reconstruir un entorno, no queda ningún recurso huérfano de la versión anterior.
**Captura**: el código parametrizado; los dos entornos desplegados y visibles en consola; el cronómetro real de destruir/reconstruir, comparado con el tiempo estimado del montaje manual del Tema 2.

---

## Verificación

Para dar por válida la práctica se ejecutará:

```bash
terraform show
terraform state list
```

Sobre cada entorno desplegado. Debe observarse: la infraestructura completa (VPC, subredes, instancia del catálogo) declarada en el estado, los dos entornos sin solapamiento de recursos, y el fichero de código con las variables parametrizadas.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Módulo leído y entendido, descripción correcta antes de ejecutar | 2 |
| Aplicado correctamente, con plan revisado antes de cada cambio | 3 |
| Subred añadida por código, sin tocar recursos existentes | 1 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Módulo parametrizado y dos entornos desplegados sin conflicto, con la instancia del catálogo incluida | 2 |
| Cronómetro de destruir/reconstruir, comparado con el montaje manual | 1 |

---

## ✅ Cierre

Ya sabes leer, modificar y reconstruir infraestructura completa desde código, con un plan que revisas antes de aplicar cualquier cambio — y has medido con tus propios números cuánto se gana en tiempo y en trazabilidad frente a montarlo a mano. La próxima sesión subes un peldaño más en la escalera de responsabilidad: dejas de gestionar instancias del todo, y ejecutas código sin ningún servidor que tú administres.
