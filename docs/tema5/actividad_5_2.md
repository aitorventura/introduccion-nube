# 🧪 Actividad 5.2: Gestión de credenciales y políticas IAM

!!! danger "Pendiente — depende de Escaparate"
    **Escaparate ya existe** (repo clonado en `escaparate-app/`), pero esta actividad todavía no está escrita paso a paso. No la publiques ni la des en clase tal cual — lo de abajo ya está confirmado contra el código real.

## Prompt pendiente

**Fuente del código**: usa `escaparate-distribuciones/escaparate-cloud.zip` (fuera del repo público, ver `DISTRIBUCIONES-DOCENTES.md` en esa misma carpeta) — ya trae `S3Storage`/`S3Config` y el AWS SDK incluidos, no hace falta clonar/compilar desde `escaparate-app/`. Confirmado: el `pom.xml`, el esquema y los controladores son idénticos a lo ya usado en 3.2/3.3/4.1, esta distribución solo añade la pieza de S3 encima.

**Qué usamos**: Escaparate, moviendo sus imágenes de EFS a S3 — confirmado, la clase se llama de verdad `S3Storage` (implementa la misma interfaz `AlmacenamientoImagenes` que `FileSystemStorage`, así que el cambio es solo de configuración):

```bash
export APP_STORAGE_TYPE=s3
export APP_STORAGE_S3_BUCKET=<bucket-privado>
```

El bucket es y sigue siendo **privado** — el navegador nunca habla con S3 directamente, sigue pidiendo `GET /api/productos/{id}/imagen` como siempre; es la aplicación la que recupera el objeto de S3 y se lo devuelve. Esto es importante para la actividad: da un ejemplo real y verificable de "acceso sin exponer nada al público" que no depende de configurar ACLs ni políticas de bucket público.

**Idea central**: es el momento perfecto para practicar acceso a S3 sin credenciales embebidas — la app ya usa la cadena de credenciales estándar del AWS SDK (nunca hay `APP_AWS_ACCESS_KEY` en el código ni en `application.yml`), así que en EC2 basta con darle a la instancia el rol de IAM (`LabInstanceProfile` en el Learner Lab) para que `S3Storage` funcione sin ninguna clave estática.

**Referencia de la chuleta original** (revalidar el "hito H8" contra `curriculum.md`, probablemente RA2 — gestión de accesos con IAM, adaptado a las limitaciones del Learner Lab): fila 5.2.

Cuando Escaparate esté definido, reescribe esta actividad completa siguiendo el mismo patrón que el resto del módulo: Contexto, Qué vas a practicar, Requisitos previos, Parte A guiada + Parte B reto (a prueba de IA), Criterios de evaluación, Cierre con aviso de limpieza de recursos — y regenera sus plantillas docx.
