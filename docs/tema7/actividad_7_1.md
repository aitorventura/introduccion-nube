# 🧪 Actividad 7.1: Auditoría y mejora

!!! warning "Descarga la plantilla"
    📄 [Plantilla 7.1 — Auditoría y mejora](plantillas/Actividad_7_1_INU_Plantilla.docx){target="_blank" rel="noopener"}

## Contexto

Esta es la última actividad del módulo, y no construyes nada nuevo: auditas una arquitectura deliberadamente mal diseñada —la prepara el profesor, o es la de otro equipo— con los seis pilares del marco Well-Architected, y presentas una propuesta de mejora con su coste estimado.

## Qué vas a practicar

- Auditar una arquitectura completa con los seis pilares, encontrando hallazgos reales, no genéricos.
- Priorizar hallazgos por impacto y esfuerzo de corrección.
- Consultar y contrastar recomendaciones automáticas de optimización.
- Presentar una versión mejorada con su coste estimado.

## Requisitos previos

Acceso a la arquitectura que vas a auditar (la prepara el profesor, o es la de otro equipo del curso). Los apuntes de esta sesión — [«Well-Architected: los seis pilares»](well-architected.md).

---

## Parte A — Audita con los seis pilares (guiada)

### Paso 1 — Recorre la arquitectura pilar por pilar

Antes de buscar fallos concretos, dibuja o recupera el diagrama completo de la arquitectura que vas a auditar (igual que hiciste con la tuya propia en la Actividad 3.3). Para cada uno de los seis pilares de los apuntes de hoy, recórrela y anota, sin filtrar todavía, cualquier cosa que te llame la atención — no descartes nada en esta primera pasada.

**Comprueba**: que has anotado al menos algo para cada uno de los seis pilares, no solo para los más evidentes (seguridad y coste suelen saltar a la vista; fiabilidad y sostenibilidad requieren mirar con más atención).

**Captura**: tus notas iniciales, organizadas por pilar.

### Paso 2 — Consulta las recomendaciones automáticas desde la consola

1. Busca "Trusted Advisor" en el buscador de servicios de la cuenta donde vive la arquitectura a auditar.
2. Revisa las recomendaciones que aparezcan en las categorías de coste, rendimiento, seguridad y tolerancia a fallos (el nivel de detalle disponible depende del plan de soporte de la cuenta).
3. Si tienes acceso a **Compute Optimizer**, revisa también sus recomendaciones de ajuste de tamaño de instancia.

![Recomendaciones automáticas visibles en Trusted Advisor o Compute Optimizer](img/actividad_7_1_paso2.png)
*🖼️ Captura de referencia del profesor — guardar como `img/actividad_7_1_paso2.png`*

Para cada recomendación que veas, anota si la aplicarías tal cual, o si hay una razón de contexto por la que no —como la del ejemplo de los apuntes de hoy sobre la CPU baja en horario fuera de clase.

**Comprueba**: que para cada recomendación automática tienes una decisión razonada (aplicar o descartar), no una lista sin analizar.

**Captura**: tus propias recomendaciones visibles en Trusted Advisor o Compute Optimizer, y tu tabla de recomendaciones con su decisión justificada.

### Paso 3 — Prioriza tres hallazgos

De todo lo que has anotado en el Paso 1, elige los **tres hallazgos** que consideres más importantes, y para cada uno documenta:

1. Qué pilar afecta.
2. Qué impacto tiene si no se corrige (sé concreto: qué falla, para quién, con qué frecuencia).
3. Qué esfuerzo estimado cuesta corregirlo.
4. Por qué has priorizado este hallazgo por encima de otros que también anotaste.

**Comprueba**: que los tres hallazgos están priorizados con un criterio explícito (impacto frente a esfuerzo), no simplemente en el orden en que los encontraste.

**Captura**: la ficha de los tres hallazgos priorizados, con impacto, esfuerzo y justificación de la prioridad.

!!! question "Reflexiona"
    De los tres hallazgos que has priorizado, ¿cuál habrías encontrado tú mismo si nadie te hubiera dado el marco de los seis pilares como guía? Y al revés: ¿cuál de los seis pilares te ha costado más encontrar algo que auditar, y por qué crees que es precisamente ese el que más se pasa por alto en la práctica?

---

## Parte B — Presenta la mejora (reto)

No hay procedimiento dado: a partir de los tres hallazgos priorizados, diseña y presenta una versión mejorada de la arquitectura que los resuelva. Tiene que incluir, como mínimo:

- El diagrama de la arquitectura mejorada, con los cambios señalados frente a la original.
- La estimación de coste mensual de la versión mejorada, comparada con la original — una mejora que dispara el coste sin justificación no es una buena propuesta.
- Para cada recomendación automática del Paso 2 que hayas decidido aplicar, cómo queda reflejada en la versión mejorada; para cada una que hayas descartado, la justificación de por qué no aplica a este caso.

**Comprueba**: que cada uno de los tres hallazgos priorizados en la Parte A tiene una solución concreta y visible en el diagrama mejorado, no una mención genérica.

**Captura**: el diagrama de la arquitectura mejorada, la comparación de coste antes/después, y la tabla final de recomendaciones aplicadas/descartadas con su justificación.

---

## Criterios de evaluación

**Parte A — hasta 7 puntos**

| Apartado | Puntos |
|---|---|
| Auditoría completa de los seis pilares, con hallazgos reales | 4 |
| Recomendaciones automáticas consultadas y contrastadas con criterio propio | 2 |
| Tres hallazgos priorizados con impacto, esfuerzo y justificación | 1 |

**Parte B — reto, hasta 3 puntos adicionales (máximo total: 10)**

| Apartado | Puntos |
|---|---|
| Arquitectura mejorada que resuelve los tres hallazgos, con coste comparado | 2 |
| Recomendaciones automáticas aplicadas o descartadas, justificadas una a una | 1 |

---

## ✅ Cierre del módulo

Has recorrido el ciclo completo: desde publicar un front estático en la primera sesión hasta auditar con un marco profesional una arquitectura entera en la última. Todo lo que has construido —red, cómputo, almacenamiento, base de datos, alta disponibilidad, gobierno, automatización— es exactamente lo que se espera que sepas mover con soltura en un puesto que trabaje con infraestructura en la nube. Lo que has hecho aquí, en la industria, se llama simplemente "trabajar en la nube" — y ya sabes hacerlo.
