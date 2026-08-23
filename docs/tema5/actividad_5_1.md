# 🧪 Actividad 5.1: Monitorización y diagnóstico con CloudWatch

!!! danger "Pendiente — depende de Escaparate"
    **Escaparate ya existe** (repo clonado en `escaparate-app/`), pero esta actividad todavía no está escrita paso a paso. No la publiques ni la des en clase tal cual.

## Prompt pendiente

**Qué usamos**: Escaparate ya desplegado (con lo construido en los Temas 3 y 4).

**Idea central**: es mejor observar y diagnosticar una arquitectura real ya existente que montar métricas de cero sobre algo nuevo. Confirmado en `soluciones-profesor/07-aws/README.md`: la app no necesita ningún cambio de código para esto — sus logs son simplemente stdout/stderr (los que ya genera el contenedor o el servicio), recogibles como logs de CloudWatch tal cual; y `/api/carga?ms=...`, `/api/salud/*` y las métricas propias de ALB/EC2 son las piezas concretas que se correlacionan para ver comportamiento y carga en el dashboard.

**Referencia de la chuleta original** (revalidar el "hito H7" contra `curriculum.md`): fila 5.1.

Cuando Escaparate esté definido, reescribe esta actividad completa siguiendo el mismo patrón que el resto del módulo: Contexto, Qué vas a practicar, Requisitos previos, Parte A guiada + Parte B reto (a prueba de IA), Criterios de evaluación, Cierre con aviso de limpieza de recursos — y regenera sus plantillas docx.
