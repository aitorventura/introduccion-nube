# 🧪 Actividad 4.2: Dominio propio y caché en el borde

!!! warning "Descarga la plantilla"
    📄 [Plantilla 4.2 — Dominio propio y caché en el borde](plantillas/Actividad_4_2_INU_Plantilla.docx){target="_blank" rel="noopener"}

!!! warning "Descarga los recursos"
    📦 [Recursos de la Actividad 4.1](recursos/actividad_4_1_recursos.zip){target="_blank" rel="noopener"} — hoy reutilizas la subcarpeta `estaticos/` de ese mismo zip; si ya lo descomprimiste en la Actividad 4.1 no hace falta que lo repitas.

!!! danger "Prerrequisito de infraestructura, no solo de permisos"
    Esta actividad necesita un dominio o subdominio ya delegado hacia tu Learner Lab — el profesor tiene que haberlo preparado antes de la sesión, porque registrar un dominio nuevo no suele estar permitido ni tiene sentido dentro del laboratorio. Sin ese subdominio ya delegado no vas a poder validar el certificado. Confirma con el profesor que tienes el tuyo antes de empezar.

## Contexto

Encuestas en Vivo sigue viviendo detrás de la URL genérica del balanceador de la Actividad 4.1. Hoy le pones un nombre propio con HTTPS de verdad, y separas del origen el contenido estático del evento —el programa y las imágenes de patrocinadores— detrás de una CDN, acercándolos a cada asistente.

## Qué vas a practicar

- Publicar la aplicación bajo un dominio o subdominio propio, con un certificado gestionado.
- Configurar HTTPS en el borde, sobre el balanceador de la sesión anterior.
- Distribuir contenido estático y de imágenes por una CDN, y medir la diferencia real entre caché fría y caliente.
- Calcular el ahorro económico de servir contenido desde el borde en vez de siempre desde el origen.

## Requisitos previos

El subdominio delegado por el profesor. El balanceador de carga y el grupo de escalado de la Actividad 4.1, en marcha. Los ficheros estáticos de ejemplo del evento (`index.html` y las imágenes de programa y patrocinadores), en `recursos/tema4/actividad_4_1/estaticos/` — descárgalos del enlace de arriba, no los programas tú. El apunte de esta sesión — «DNS, HTTPS y distribución de contenido» (dns-https-cdn.md).

---

## Parte A — Dominio propio y HTTPS (guiada)

### Paso 1 — Solicita el certificado desde la consola

1. Busca "Certificate Manager" en el buscador de servicios → **Solicitar un certificado** → **Solicitar un certificado público**.
2. Escribe tu subdominio completo (por ejemplo `encuestas-<tu-identificador>.tudominio.es`).
3. Método de validación: **Validación DNS**.
4. Solicita el certificado.
5. Entra en el certificado recién creado: para su dominio, verás un botón **Crear registro en Route 53** (si tu zona ya está en Route 53) o el CNAME exacto que tienes que añadir a mano.
6. Añade ese registro a tu zona DNS.

    ![Certificado en estado Pending validation, con el registro CNAME de validación mostrado](img/actividad_4_2_paso1_a.png)
    *🖼️ Captura de referencia del profesor — guardar como `img/actividad_4_2_paso1_a.png`*

7. Espera unos minutos y recarga la página del certificado.

![Certificado en estado Issued](img/actividad_4_2_paso1_b.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_4_2_paso1_b.png`*

**Comprueba**: que el certificado pasa de estado `Pending validation` a `Issued` tras añadir el registro de validación.

**Captura**: tu propio certificado en estado `Pending validation` con el registro CNAME mostrado, y el mismo certificado ya en estado `Issued`.

### Paso 2 — Asocia el certificado al balanceador y crea el registro por CLI

Añade un *listener* HTTPS al balanceador con el certificado del Paso 1, esta vez por CLI:

```bash
aws elbv2 create-listener \
  --load-balancer-arn <lb-arn> \
  --protocol HTTPS --port 443 \
  --certificates CertificateArn=<certificado-arn> \
  --default-actions Type=forward,TargetGroupArn=<target-group-arn>
```

Después, crea el registro `Alias` de tu subdominio apuntando al balanceador desde la consola de Route 53: entra en tu zona → **Crear registro** → activa **Alias** → destino: tu balanceador de carga.

![Registro Alias del subdominio apuntando al balanceador](img/actividad_4_2_paso2_a.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_4_2_paso2_a.png`*

Abre `https://<tu-subdominio>` en el navegador.

![Encuestas en Vivo cargando por HTTPS sobre el subdominio propio, con el candado de conexión segura](img/actividad_4_2_paso2_b.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_4_2_paso2_b.png`*

**Comprueba**: que `https://<tu-subdominio>` carga la aplicación con el candado de conexión segura, sin ningún aviso de certificado no válido.

**Captura**: tu propio registro Alias apuntando al balanceador, y Encuestas en Vivo cargando por HTTPS sobre tu subdominio, con el candado de conexión segura.

!!! question "Reflexiona"
    El certificado está instalado en el balanceador, no en cada instancia. Si mañana el grupo de escalado automático termina una instancia y lanza otra nueva para reemplazarla, ¿tienes que volver a instalar el certificado en la instancia nueva? Justifica tu respuesta con lo que viste en el apunte sobre dónde vive el cifrado.

---

## Parte B — CDN de verdad, con medidas reales (reto)

Sube el contenido de `recursos/tema4/actividad_4_1/estaticos/` (la página del programa y las imágenes de patrocinadores) a un bucket S3 que sirva de origen, y configura una distribución CDN delante de ese contenido. No hay procedimiento dado para lo que viene a continuación — decide tú cómo medir y cómo demostrar cada comportamiento:

**Mide la diferencia real entre caché fría y caliente**: la primera petición a un recurso tras crear la distribución, y una petición inmediatamente posterior al mismo recurso. Demuestra la diferencia de tiempos con datos, no con una estimación.

**Comprueba el comportamiento del TTL**: cambia el contenido de un fichero ya cacheado en el origen, y confirma que un visitante sigue viendo la versión antigua mientras no expire el TTL ni fuerces una invalidación.

**Invalida y confirma el cambio**: fuerza la invalidación de ese mismo recurso, y demuestra que a partir de ese momento se sirve la versión nueva.

**Calcula el ahorro económico**: estima cuánta transferencia de salida se evita el origen (S3) al servir el contenido desde el borde en vez de desde el origen cada vez, para un volumen de tráfico razonable, y tradúcelo a euros al mes con la calculadora oficial de AWS.

**Comprueba**: que puedes demostrar, con evidencia y no solo con la teoría, los tres comportamientos (caché fría/caliente, TTL respetado, invalidación efectiva).

**Captura**: los tiempos medidos de caché fría y caliente; la prueba de que el contenido antiguo se sirvió hasta la invalidación; el cálculo del ahorro mensual con su justificación.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Certificado emitido y HTTPS funcionando sobre subdominio propio | 6 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| CDN configurada delante del contenido estático y las imágenes | 1 |
| Caché fría/caliente y comportamiento del TTL demostrados con datos reales | 1 |
| Invalidación efectiva demostrada y ahorro económico calculado | 1 |

---

## ✅ Cierre

Encuestas en Vivo ya tiene nombre propio, conexión cifrada de extremo a extremo hasta el borde, y contenido servido cerca de cada asistente en vez de siempre desde la misma región. Con esto se cierra el Tema 4. En el Tema 5 dejas de construir infraestructura nueva por un rato: te toca vigilar lo que ya tienes, controlar quién puede tocarlo, y entender cuánto está costando de verdad.
