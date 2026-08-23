# 🧪 Actividad 4.1: Balanceador de carga y Auto Scaling Group

!!! danger "Pendiente — depende de Escaparate"
    **Escaparate ya existe** (repo clonado en `escaparate-app/`, ver `MAPA-DOCENTE.md`), pero esta actividad todavía no está escrita paso a paso. No la publiques ni la des en clase tal cual — lo de abajo ya está confirmado contra el código real, no es contenido listo.

## Prompt pendiente

**Qué usamos**: el backend de Escaparate (variante Desacoplada de la 3.3), replicado detrás de un balanceador de carga con Auto Scaling Group.

**Idea central**: la aplicación ya tiene, de fábrica, los endpoints exactos que necesita un balanceador/ASG — no hay que añadir nada:

- `GET /api/salud/listo` — health check del Target Group: `200` si PostgreSQL responde, `503 {"estado":"degradado"}` si no. Confirmado como recomendación oficial en `soluciones-profesor/07-aws/README.md`.
- `GET /api/instancia` — devuelve host, versión y tipo de almacenamiento de la réplica que ha respondido: se usa para comprobar a ojo el reparto entre instancias detrás del balanceador.
- `GET /api/carga?ms=1000` — genera carga de CPU controlada durante ese tiempo, pensada explícitamente para disparar el escalado y observarlo con métricas.

**Continuación de almacenamiento (misma sesión)**: las imágenes viven en `FileSystemStorage` (disco local de una sola instancia) — con dos o más réplicas detrás del balanceador, un producto subido a una instancia "desaparece" al servirlo otra, un fallo real y observable, no simulado. Se resuelve montando EFS en cada instancia (por ejemplo en `/mnt/escaparate/uploads`) y apuntando ahí con `APP_STORAGE_PATH` — confirmado en el propio código: no existe una clase `EfsStorage`, porque para Java EFS es simplemente un sistema de ficheros montado, sin ningún cambio de código.

**Referencia de la chuleta original** (revalidar el "hito H7" contra `curriculum.md`, probablemente RA3e — balanceo de carga y escalado automático): filas "4.1" y "4.1, continuación".

Cuando Escaparate esté definido, reescribe esta actividad completa siguiendo el mismo patrón que el resto del módulo: Contexto, Qué vas a practicar, Requisitos previos, Parte A guiada + Parte B reto (a prueba de IA), Criterios de evaluación, Cierre con aviso de limpieza de recursos — y regenera sus plantillas docx.
