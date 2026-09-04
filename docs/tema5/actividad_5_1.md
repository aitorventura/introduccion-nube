# 🧪 Actividad 5.1: Monitorización y diagnóstico con CloudWatch

!!! danger "Pendiente — depende de Escaparate"
    **Escaparate ya existe** (repo clonado en `escaparate-app/`), pero esta actividad todavía no está escrita paso a paso. No la publiques ni la des en clase tal cual.

## Prompt pendiente

**Qué usamos**: Escaparate ya desplegado (con lo construido en los Temas 3 y 4). El Cierre de la 4.2 borra el balanceador y el grupo de destino (es la única pieza de la 4.1 sin estado de pausa barato) y deja el ASG a capacidad 0 y la RDS detenida — como primer paso de esta actividad, hay que arrancar la RDS, recrear el balanceador y el grupo de destino, y subir el ASG de nuevo a mínima/deseada 2 antes de montar ninguna métrica.

!!! note "Al escribir esta actividad: mueve el script de recreación del ALB aquí"
    El script vive de momento en `recursos/tema4/actividad_4_1/recrear-alb.sh` (lo usa también el Cierre de la 4.2 para dejar constancia de dónde está). Cuando escribas esta actividad de verdad, cópialo (o muévelo) a `recursos/tema5/actividad_5_1/recrear-alb.sh` y empaquétalo en el zip de recursos de la 5.1, como primer paso explícito de un "Paso 0" — así el alumno lo tiene ya descargado junto con el resto de recursos de la sesión, sin ir a buscarlo a la carpeta de la 4.1.

**Fuente del código**: ya no hace falta clonar/compilar desde `escaparate-app/` — usa `escaparate-distribuciones/escaparate-desacoplado.zip` (fuera del repo público, ver `DISTRIBUCIONES-DOCENTES.md` en esa misma carpeta), que es la distribución que recomienda el compañero para esta actividad. Es funcionalmente idéntica a lo que ya usamos en 3.3/4.1, solo que empaquetada como distribución fija en vez de clonada del repo completo.

**Idea central**: es mejor observar y diagnosticar una arquitectura real ya existente que montar métricas de cero sobre algo nuevo. Confirmado en `soluciones-profesor/07-aws/README.md`: la app no necesita ningún cambio de código para esto — sus logs son simplemente stdout/stderr (los que ya genera el contenedor o el servicio), recogibles como logs de CloudWatch tal cual; y `/api/carga?ms=...`, `/api/salud/*` y las métricas propias de ALB/EC2 son las piezas concretas que se correlacionan para ver comportamiento y carga en el dashboard.

**Referencia de la chuleta original** (revalidar el "hito H7" contra `curriculum.md`): fila 5.1.

Cuando Escaparate esté definido, reescribe esta actividad completa siguiendo el mismo patrón que el resto del módulo: Contexto, Qué vas a practicar, Requisitos previos, Parte A guiada + Parte B reto (a prueba de IA), Criterios de evaluación, Cierre con aviso de limpieza de recursos — y regenera sus plantillas docx.
