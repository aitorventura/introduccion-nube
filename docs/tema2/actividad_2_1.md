# 🧪 Actividad 2.1: Tu propia VPC en dos zonas

!!! warning "Descarga la plantilla"
    📄 [Plantilla 2.1 — Tu propia VPC en dos zonas](plantillas/Actividad_2_1_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

Vas a diseñar la red que alojará una aplicación de reserva de pistas deportivas municipales — es solo el escenario de ambientación de la sesión, no hace falta que construyas esa aplicación. Ese lugar no puede ser una única subred pública abierta a todo el mundo. Hoy diseñas y construyes tu propia red virtual, repartida en dos zonas de disponibilidad, con subredes públicas y privadas bien diferenciadas.

## Qué vas a practicar

- Repartir un rango CIDR `/16` en subredes públicas y privadas para dos zonas de disponibilidad.
- Construir una VPC en consola siguiendo exactamente el diseño que has dibujado en papel.
- Verificar qué conectividad existe de verdad, y comprobar que la que no debería existir, efectivamente no existe.

## Requisitos previos

El apunte de esta sesión — «Diseño de la red virtual» (vpc-diseno.md). No necesitas nada de sesiones anteriores: hoy construyes la red desde cero.

---

## Parte A — Diseñar y construir la VPC (guiada)

### Paso 1 — Diseña el reparto en papel

Antes de abrir la consola, dibuja una tabla con cuatro columnas para un rango `10.0.0.0/16`: nombre de subred, CIDR, zona de disponibilidad y tipo (pública/privada). Necesitas como mínimo cuatro subredes: una pública y una privada en cada una de las dos zonas.

**Comprueba**: que ninguno de los rangos que has repartido se solapa con otro, y que cada subred cabe dentro del `/16` de la VPC.
**Captura**: la tabla de diseño completa, con los cuatro rangos y sus zonas.

### Paso 2 — Crea la VPC y las subredes desde la consola

Es tu primera VPC, así que constrúyela desde la consola, paso a paso:

1. Busca "VPC" en el buscador de servicios y entra en el panel de VPC.
2. Haz clic en **Crear VPC**.
3. Elige la opción **Solo VPC** (no el asistente "VPC y más", para controlar tú cada pieza).
4. En **Bloque de dirección IPv4**, escribe `10.0.0.0/16`.
5. Dale un nombre reconocible (por ejemplo `pistas-vpc-<tu-identificador>`) y crea la VPC.

![VPC creada con el rango 10.0.0.0/16](img/actividad_2_1_paso2_a.png)

6. En el menú lateral, entra en **Subredes** → **Crear subred**.
7. Selecciona la VPC que acabas de crear.
8. Añade las cuatro subredes de tu tabla del Paso 1, una a una: para cada una, escribe su nombre, elige su zona de disponibilidad y su bloque CIDR exacto — usa el botón **Añadir nueva subred** para no tener que repetir el asistente cuatro veces.
9. Haz clic en **Crear subred**.

![Las cuatro subredes creadas, con su CIDR y zona visibles](img/actividad_2_1_paso2_b.png)

**Comprueba**: en el panel de subredes de la consola, que ves las cuatro con los CIDR y zonas de tu diseño, sin ninguna de más ni de menos.
**Captura**: `img/actividad_2_1_paso2_a.png` y `img/actividad_2_1_paso2_b.png`.

### Paso 3 — Convierte en públicas solo las subredes que deben serlo, por CLI

Ahora repite un patrón que vas a necesitar automatizar más adelante: crea la pasarela de internet, asóciala a la VPC, y añade la ruta `0.0.0.0/0` solo en la tabla de rutas de las dos subredes públicas, esta vez por CLI:

```bash
aws ec2 create-internet-gateway
aws ec2 attach-internet-gateway --vpc-id <vpc-id> --internet-gateway-id <igw-id>
aws ec2 create-route-table --vpc-id <vpc-id>
aws ec2 create-route --route-table-id <rt-id> --destination-cidr-block 0.0.0.0/0 --gateway-id <igw-id>
aws ec2 associate-route-table --route-table-id <rt-id> --subnet-id <subnet-publica-id>
```

Entra en el panel de VPC → **Tablas de rutas** en la consola y compara visualmente las dos: la asociada a tus subredes públicas debe mostrar la ruta `0.0.0.0/0 → igw-...`; la principal, la que siguen usando tus subredes privadas, no.

![Tabla de rutas pública (con ruta a la pasarela) junto a la privada (sin ella)](img/actividad_2_1_paso3.png)

**Comprueba**: que las dos subredes privadas siguen usando la tabla de rutas principal (sin la ruta a la pasarela), y que solo las dos públicas tienen la ruta `0.0.0.0/0`.
**Captura**: `img/actividad_2_1_paso3.png`.

!!! question "Reflexiona"
    Imagina que lanzas una instancia en una de tus subredes privadas y compruebas que no sale a internet. Antes de tocar nada más: ¿falta una ruta en la tabla de rutas, falta una regla de un grupo de seguridad, o falta la pasarela en sí? Nómbralo con precisión — la próxima sesión vas a diagnosticar averías reales de este mismo tipo.

---

## Parte B — Demuestra que tu red hace lo que dices que hace (reto)

El diseño de la Parte A queda sobre el papel hasta que lo pones a prueba de verdad. El reto: demuestra, con evidencia real y no solo con el diagrama, que tu subred pública tiene salida a internet, que tu subred privada **no** la tiene, y que ambas sí pueden hablar entre sí dentro de la VPC. Cómo lo demuestras —qué lanzas, qué comandos usas, en qué orden— lo decides tú; no hay una receta para esta parte.

Antes de comprobar que la subred privada no sale a internet, predice por escrito qué mensaje de error o comportamiento exacto esperas ver. Comprueba después si tu predicción se ha cumplido.

Cuando tengas la evidencia, documenta el diagrama de red completo (las cuatro subredes, la pasarela, lo que hayas usado para probar la conectividad) y justifica por escrito el reparto de rangos que elegiste en el Paso 1: por qué ese tamaño de subred y no otro, por qué esa distribución entre las dos zonas.

**Comprueba**: que el diagrama documentado coincide exactamente con lo que existe en tu cuenta (mismos CIDR, mismas zonas).
**Captura**: la evidencia de los tres comportamientos demostrados, tu predicción escrita de antemano, y el diagrama de red final.

---

## Verificación

Para dar por válida la práctica se ejecutará:

```bash
aws ec2 describe-vpcs --filters Name=cidr,Values=10.0.0.0/16
aws ec2 describe-route-tables --filters Name=vpc-id,Values=<vpc-id>
aws ec2 describe-subnets --filters Name=vpc-id,Values=<vpc-id>
```

Y debe observarse: una VPC `10.0.0.0/16` con cuatro subredes en dos zonas de disponibilidad distintas, dos tablas de rutas diferenciadas (una con ruta a la pasarela, otra sin ella), y el diagrama de red documentado en el repositorio con la justificación del reparto de rangos.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| VPC y cuatro subredes creadas siguiendo el diseño en papel | 3 |
| Subredes públicas y privadas correctamente diferenciadas por tabla de rutas | 3 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Conectividad demostrada con evidencia real (pública sí, privada no, entre ellas sí) | 2 |
| Diagrama de red y justificación del reparto de rangos | 1 |

---

## ✅ Cierre

Ya tienes el terreno construido: una VPC con subredes públicas y privadas repartidas en dos zonas, con la separación garantizada por la tabla de rutas y no solo por convención. En la próxima sesión vas a poner grupos de seguridad y NACL sobre esta misma red, y vas a encontrarte —a propósito— con una versión rota de todo esto que tendrás que arreglar contrarreloj.
