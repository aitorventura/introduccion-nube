# 🧪 Actividad 3.3: Arquitectura de tres capas: front, aplicación y base de datos

!!! danger "Pendiente — depende de Escaparate"
    **Escaparate ya existe** (repo clonado en `escaparate-app/`, ver `MAPA-DOCENTE.md`), pero esta actividad todavía no está escrita paso a paso. No la publiques ni la des en clase tal cual — lo de abajo ya está confirmado contra el código real, no es contenido listo.

## Prompt pendiente

**Qué usamos**: Escaparate en su variante **Desacoplada** (disponible desde el `frontend-api` de Maven) — front estático servido desde S3, backend Spring en EC2, base de datos ya en RDS de la 3.2.

**Cómo se genera de verdad** (confirmado en `README.md`): el frontend se compila apuntando a la URL pública real del backend, no a `localhost`:

```bash
./mvnw clean package "-Dfrontend.api.base=https://API-PUBLICA/api"
```

El contenido de `target/frontend-api/` se sube tal cual a un bucket S3 (web estático); el backend necesita la variable `APP_CORS_ALLOWED_ORIGINS=https://ORIGEN-FRONTEND` para aceptar las peticiones desde ese origen — sin ella, el navegador bloquea las llamadas por CORS y es un fallo real, no hipotético, que el alumno puede provocar y arreglar él mismo.

**Idea central**: es la primera vez que se ve la arquitectura completa de Escaparate en marcha de principio a fin — front, aplicación y base de datos desplegados y conectados de verdad en una sola sesión. El diagrama que se documente aquí es el que se va a reutilizar el resto del módulo.

**Referencia de la chuleta original** (revalidar el "hito H7" contra `curriculum.md`): fila 3.3.

Cuando Escaparate esté definido, reescribe esta actividad completa siguiendo el mismo patrón que el resto del módulo: Contexto, Qué vas a practicar, Requisitos previos, Parte A guiada + Parte B reto (a prueba de IA), Criterios de evaluación, Cierre con aviso de limpieza de recursos — y regenera sus plantillas docx.
