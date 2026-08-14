# 🧪 Actividad 3.3: Escaparate en tres capas

!!! warning "Descarga la plantilla"
    📄 [Plantilla 3.3 — Escaparate en tres capas](plantillas/Actividad_3_3_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

Hoy no aprendes ningún servicio nuevo: juntas todo lo que has construido en las dos últimas semanas —red, cómputo, almacenamiento y base de datos— en una única arquitectura de Escaparate completa y funcional. Es la primera vez que ves el sistema entero en marcha, y el diagrama que documentes hoy es el mapa que vas a usar el resto del módulo.

## Qué vas a practicar

- Desplegar la aplicación completa de Escaparate, conectada de verdad a su base de datos.
- Integrar en una sola arquitectura la red, el cómputo, el almacenamiento y la base de datos de las sesiones anteriores.
- Documentar una arquitectura con su diagrama, su coste estimado y sus puntos únicos de fallo.

## Requisitos previos

Todo lo construido en el Tema 2 y en las Actividades 3.1 y 3.2: la VPC con subredes públicas y privadas, la base de datos RDS con sus credenciales en Secrets Manager, y el almacenamiento de objetos y compartido ya configurados.

---

## Parte A — Despliega la arquitectura completa (guiada)

### Paso 1 — Lanza la aplicación en la subred pública, por CLI

Lanza una instancia en tu subred pública con la aplicación completa de Escaparate (no solo el front — el backend que consulta la base de datos), configurada para leer el endpoint de RDS y el secreto de Secrets Manager en el arranque, sin nada escrito a mano dentro de la instancia:

```bash
aws ec2 run-instances \
  --image-id <tu-ami-con-la-app> \
  --subnet-id <subnet-publica-id> \
  --security-group-ids <sg-app-id> \
  --user-data file://arranque-app.sh
```

**Comprueba**: que la aplicación arranca sola y consulta la base de datos sin que te hayas conectado por SSH a configurar nada.
**Captura**: la salida de los logs de arranque mostrando la conexión correcta a RDS.

### Paso 2 — Verifica la cadena completa desde el navegador

Abre la URL del front (S3) y comprueba que ahora sí carga datos reales del catálogo, viniendo de la aplicación y esta a su vez de la base de datos — la misma URL que en la sesión 1 solo mostraba un catálogo vacío o con error.

![El catálogo completo funcionando, con datos e imágenes reales](img/actividad_3_3_paso2.png)

**Comprueba**: que al menos un producto con su imagen (servida desde tu almacenamiento compartido o de objetos) se ve correctamente en el navegador.
**Captura**: `img/actividad_3_3_paso2.png`.

!!! question "Reflexiona"
    Para el front, la fecha de la sesión 1 y la de hoy son la misma URL — no ha cambiado nada de cara al usuario. Pero de puertas para adentro sí ha cambiado todo. ¿Qué le pasaría al front si cambiaras hoy el endpoint de la base de datos sin actualizar la configuración de la aplicación?

---

## Parte B — Documenta la arquitectura de verdad (reto)

No hay pasos guiados para esta parte: el reto es producir tres entregables reales a partir de la arquitectura que acabas de desplegar, no de una plantilla genérica.

**El diagrama**: dibuja la arquitectura completa tal como existe de verdad en tu cuenta —todas las capas, todas las subredes, qué habla con qué—, no un diagrama idealizado de manual.

**El coste**: estima el coste mensual real de mantener esta arquitectura funcionando permanentemente, desglosado por servicio (instancia, RDS, almacenamiento, transferencia), usando la calculadora oficial de AWS.

**Los puntos únicos de fallo**: recorre tu propio diagrama y localiza cada pieza cuya caída, ella sola, tumbaría el sistema completo. No basta con decir "la base de datos" — para cada punto único de fallo que identifiques, explica exactamente qué se rompe y por qué esa pieza en concreto no tiene ningún respaldo ahora mismo.

**Comprueba**: que cada punto único de fallo que documentas corresponde a algo real en tu arquitectura, no a un riesgo genérico copiado de una lista.
**Captura**: el diagrama completo, el desglose de coste por servicio, y la lista de puntos únicos de fallo con su explicación.

---

## Verificación

Para dar por válida la práctica se ejecutará:

```bash
curl -s http://<url-del-front> | grep -i "producto"
aws rds describe-db-instances --db-instance-identifier <tu-instancia-rds>
aws ec2 describe-instances --filters Name=tag:App,Values=escaparate
```

Y debe observarse: el front sirviendo contenido real del catálogo (no vacío ni con error de conexión), la base de datos en marcha y accesible solo desde la aplicación, y el diagrama, el coste y la lista de puntos únicos de fallo documentados en el repositorio.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Aplicación desplegada y conectada de verdad a la base de datos | 3 |
| Catálogo visible con datos e imágenes reales desde el front | 3 |
| Documentación en el repositorio | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Diagrama de arquitectura completo y fiel a lo desplegado | 1 |
| Coste mensual estimado, desglosado por servicio | 1 |
| Puntos únicos de fallo identificados y explicados uno a uno | 1 |

---

## ✅ Cierre

Escaparate ya funciona de principio a fin, con sus tres capas separadas y su base de datos protegida — y tienes en la mano la lista de puntos únicos de fallo que va a marcar el resto del módulo. Con esto se cierra el Tema 3. En el Tema 4 empiezas a resolver esa lista: el primer punto único de fallo que vas a eliminar es que toda la aplicación depende de una única instancia.
