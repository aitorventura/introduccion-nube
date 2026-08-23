# 🧪 Actividad 4.2: Dominio propio y caché en el borde

!!! danger "Pendiente — depende de Escaparate"
    **Escaparate ya existe** (repo clonado en `escaparate-app/`), pero esta actividad todavía no está escrita paso a paso. No la publiques ni la des en clase tal cual.

## Prompt pendiente

**Qué usamos**: la arquitectura de Escaparate ya construida en la 4.1 (balanceador + Auto Scaling Group), variante Desacoplada — el frontend estático (`target/frontend-api/`) ya vive en S3 desde la 3.3.

**Idea central**: Escaparate sigue viviendo detrás de la URL genérica del balanceador de la 4.1 — hoy se le pone un nombre de dominio propio con HTTPS de verdad, y se separa del origen el contenido estático (imágenes de producto, por ejemplo) detrás de una CDN, acercándolo a cada visitante. Usar CloudFront si el Learner Lab lo permite.

**Referencia de la chuleta original** (revalidar el "hito H7" contra `curriculum.md`): fila 4.2.

Cuando Escaparate esté definido, reescribe esta actividad completa siguiendo el mismo patrón que el resto del módulo: Contexto, Qué vas a practicar, Requisitos previos, Parte A guiada + Parte B reto (a prueba de IA), Criterios de evaluación, Cierre con aviso de limpieza de recursos — y regenera sus plantillas docx.
