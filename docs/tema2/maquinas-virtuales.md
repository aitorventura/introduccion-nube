<a id="maquinas-virtuales"></a>

# 🧩 3. Máquinas virtuales

---

En las dos sesiones anteriores has lanzado instancias sueltas, una a una, cada vez con los mismos parámetros repetidos a mano: la imagen, el tipo, la subred, el grupo de seguridad. Funciona para dos instancias de prueba, pero no escala — y hoy es el día en que dejas de repetir ese proceso manualmente. Vas a entender qué decide realmente el rendimiento y el precio de una instancia, cómo se empaqueta un servidor entero en una imagen reutilizable, y cómo se guarda toda esa receta en una plantilla que vas a lanzar tantas veces como haga falta, sin volver a teclear los mismos parámetros.

---

## 🧭 Familias y tamaños de instancia

Cuando lanzas una instancia EC2 eliges un **tipo**, con un nombre como `t3.micro` o `m5.large`. Ese nombre no es arbitrario: la letra inicial indica la **familia** (para qué está optimizada), y el número final indica el **tamaño** (cuánta CPU y memoria trae).

| Familia | Optimizada para | Ejemplo de uso en Escaparate |
|---|---|---|
| `t` (general, ráfaga) | Cargas variables, con picos ocasionales | Instancia de la aplicación en desarrollo o pruebas |
| `m` (general, equilibrada) | CPU y memoria en proporción estándar | Instancia de la aplicación en producción |
| `c` (cómputo) | Mucha CPU, poca memoria relativa | Procesamiento intensivo, no lo usarás en este módulo |
| `r` (memoria) | Mucha memoria, poca CPU relativa | Bases de datos en memoria, no lo usarás en este módulo |

!!! example "Elegir tamaño no es "cuanto más grande, mejor""
    Una `t3.micro` cuesta una fracción de lo que cuesta una `m5.large`, y para servir el front estático de Escaparate durante una clase de treinta alumnos es más que suficiente. Sobredimensionar una instancia es tirar presupuesto del laboratorio a la basura sin ninguna mejora perceptible — vas a comparar el coste real de tres familias en la Actividad 2.3.

El propio nombre `t3.micro` te dice ya el 80 % de lo que necesitas: familia de uso general con ráfagas, tamaño mínimo. No hace falta memorizar el catálogo entero — elige la familia según qué exige la carga, y el tamaño según cuánto tráfico esperas de verdad.

---

## 🧩 Imágenes de máquina

Una **AMI** (*Amazon Machine Image*) es la fotografía completa de un disco de arranque: sistema operativo, paquetes instalados, configuración — todo lo que hace falta para que una instancia nueva arranque ya lista, sin repetir la instalación desde cero. AWS te ofrece AMIs públicas (Amazon Linux, Ubuntu...) como punto de partida, pero también puedes crear las tuyas propias a partir de una instancia que ya has configurado.

```mermaid
flowchart LR
    A["Instancia base<br/>(AMI pública)"] --> B["Instalas y configuras<br/>lo que necesitas"]
    B --> C["Creas tu propia AMI"]
    C --> D["Lanzas N instancias idénticas<br/>desde tu AMI"]
```

Esa es exactamente la secuencia que vas a seguir en la Actividad 2.3: arrancar de una imagen pública, instalar lo necesario para servir el catálogo de Escaparate, y capturar el resultado como tu propia imagen — para no tener que repetir la instalación la próxima vez que necesites otra instancia igual.

---

## 🔧 Almacenamiento asociado

Cada instancia EC2 lleva asociado al menos un volumen de disco — un **EBS** (*Elastic Block Store*), que existe como recurso independiente de la instancia, aunque normalmente vaya pegado a ella. Esa independencia importa: por defecto, si terminas la instancia, el volumen raíz se borra con ella, pero puedes configurarlo para que sobreviva. Vas a ver la familia de almacenamiento en bloque con más detalle en el Tema 3 — por ahora basta con que sepas que el disco de tu instancia no es "parte" indivisible de ella, es una pieza aparte que se conecta.

---

## ⚙️ Ciclo de vida: parar no es terminar

Una instancia EC2 pasa por varios estados, y confundir dos de ellos es el error de facturación más común entre quien empieza con AWS: **parar** (*stop*) y **terminar** (*terminate*) no son lo mismo, ni de lejos.

| Estado | Qué pasa con la instancia | Qué pasa con el disco | ¿Sigue facturando cómputo? |
|---|---|---|---|
| En marcha (*running*) | Activa, consumiendo recursos | Activo | Sí |
| Parada (*stopped*) | Apagada, pero sigue existiendo | Sigue existiendo (y facturándose aparte) | No el cómputo, pero sí el almacenamiento |
| Terminada (*terminated*) | Eliminada por completo, no se puede recuperar | Se borra (salvo que lo hayas configurado para persistir) | No, nada |

!!! danger "Parar no vacía tu factura, solo la reduce"
    Una instancia parada dentro del Learner Lab deja de facturar cómputo, pero el volumen de disco asociado sigue existiendo y sigue teniendo un coste, por pequeño que sea. El ritual de apagado del final de cada sesión significa *parar* lo que quieras conservar para la próxima clase, y *terminar* de verdad lo que ya no necesitas — no es lo mismo, y confundirlo es tirar crédito sin darte cuenta.

---

## 📊 User data y plantillas de lanzamiento

Ya usaste **user data** en la actividad de la sesión pasada: un script que se ejecuta automáticamente la primera vez que arranca una instancia, sin que tengas que conectarte a mano. Hoy subes un escalón más: una **plantilla de lanzamiento** (*launch template*) que empaqueta *todos* los parámetros de una instancia —imagen, tipo, subred, grupo de seguridad, user data— en un único recurso reutilizable.

```mermaid
flowchart TD
    LT["📋 Plantilla de lanzamiento<br/>imagen + tipo + red + user data"] --> I1["Instancia 1"]
    LT --> I2["Instancia 2"]
    LT --> I3["Instancia N..."]
```

!!! tip "Por qué esto es la base de todo lo que viene después"
    Una plantilla de lanzamiento parametrizada es exactamente lo que va a usar el grupo de escalado automático del Tema 4 para decidir "necesito una instancia más, ¿con qué características la lanzo?" — sin plantilla, no hay escalado automático posible. Lo que hoy parece solo una comodidad para no repetir parámetros a mano es, en dos sesiones, el mecanismo que sostiene la alta disponibilidad de Escaparate.

---

## ✅ Ideas clave

??? tip "Abrir resumen"

    - El tipo de instancia combina familia (letra, para qué está optimizada) y tamaño (número, cuánta CPU/memoria) — más grande no siempre es mejor, es más caro sin necesidad si no lo justifica la carga.
    - Una AMI es la fotografía completa de un disco de arranque, lista para lanzar instancias idénticas sin reinstalar nada.
    - El almacenamiento (EBS) es un recurso independiente conectado a la instancia, no una parte indivisible de ella.
    - Parar (*stop*) conserva la instancia y el disco, sin facturar cómputo; terminar (*terminate*) la elimina por completo. Confundirlos es un error de facturación habitual.
    - User data automatiza el arranque de una sola instancia; una plantilla de lanzamiento empaqueta todos los parámetros para lanzar muchas instancias idénticas — y es la base del escalado automático que verás en el Tema 4.

Con esto ya tienes las piezas para la Actividad 2.3 — De instancia a plantilla.
