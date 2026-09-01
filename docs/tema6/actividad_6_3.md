# 🧪 Actividad 6.3: Tu imagen, sin servidores

!!! danger "Pendiente — depende de Escaparate"
    **Escaparate ya existe** (repo clonado en `escaparate-app/`), pero esta actividad todavía no está escrita paso a paso. No la publiques ni la des en clase tal cual — lo de abajo ya está confirmado contra el código real.

## Prompt pendiente

**Fuente del código**: usa `escaparate-distribuciones/escaparate-cloud.zip` (fuera del repo público, ver `DISTRIBUCIONES-DOCENTES.md`) como base para construir la imagen Docker — es la distribución que recomienda el compañero para esta actividad (backend contenerizado + RDS/S3 + frontend separado).

**Qué usamos**: el backend de Escaparate, la misma imagen Docker de `soluciones-profesor/01-docker` (ya existe, no hay que crearla de cero), publicada en ECR y desplegada en ECS/Fargate. Hay una plantilla real de referencia en `soluciones-profesor/07-aws/ecs-task-definition.template.json` — mirar solo esa carpeta, no el resto de `soluciones-profesor`.

**Variables mínimas del task/container** (confirmadas en `soluciones-profesor/07-aws/README.md`, ya usadas en 3.2/4.1/5.2 — nada nuevo que aprender aquí):

```text
DB_HOST, DB_PORT=5432, DB_NAME, DB_USER, DB_PASSWORD
APP_STORAGE_TYPE=s3, APP_STORAGE_S3_BUCKET
APP_CORS_ALLOWED_ORIGINS
```

La imagen no lleva credenciales AWS dentro — usa el **task role** de ECS para hablar con S3, el mismo principio de "rol en vez de claves" ya practicado en la 5.2 con `LabInstanceProfile`.

**Idea central**: aquí se reutiliza la misma imagen Docker del backend de Escaparate, pero sin que el alumno administre ningún servidor por debajo — la actividad completa el recorrido del módulo: construir la imagen, publicarla en un registro, desplegarla como servicio gestionado, y comprobar que se puede escalar y actualizar sin cortar el servicio.

**Referencia de la chuleta original** (revalidar el "hito H8" contra `curriculum.md`): fila 6.3.

Cuando Escaparate esté definido, reescribe esta actividad completa siguiendo el mismo patrón que el resto del módulo: Contexto, Qué vas a practicar, Requisitos previos, Parte A guiada + Parte B reto (a prueba de IA), Criterios de evaluación, Cierre con aviso de limpieza de recursos — y regenera sus plantillas docx.
