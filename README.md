# Introducción a la Nube Pública — Apuntes y actividades

Sitio de apuntes y actividades del módulo optativo **Introducción a la Nube Pública**, construido con [MkDocs Material](https://squidfunk.github.io/mkdocs-material/). Se imparte sobre **AWS Academy Learner Lab**. Teoría y actividades giran en torno a un proyecto compartido, **Escaparate** (catálogo de productos), el mismo que se trabaja en Despliegue de Aplicaciones Web — allí desplegado a mano, aquí en su versión gestionada.

## Puesta en marcha

```bash
pip install -r requirements.txt
mkdocs serve
```

Abre la URL que te indique la terminal (por defecto `http://127.0.0.1:8000`).

## Temario

- **Tema 1 — Introducción a la nube pública**: modelos de servicio, infraestructura global, responsabilidad compartida, consola y CLI.
- **Tema 2 — Redes virtuales y cómputo**: diseño de la VPC, seguridad de red, instancias e imágenes propias.
- **Tema 3 — Almacenamiento, datos y primera arquitectura**: bloque/objetos/ficheros compartidos, bases de datos gestionadas, arquitectura de tres capas.
- **Tema 4 — Alta disponibilidad y entrega de contenido**: balanceo y escalado automático, DNS gestionado, HTTPS y CDN.
- **Tema 5 — Gobierno de la nube**: monitorización y diagnóstico, identidad y permisos, economía de la nube.
- **Tema 6 — Automatización y modelos de ejecución**: infraestructura como código, serverless, contenedores gestionados.
- **Tema 7 — Arquitectura bien diseñada**: los seis pilares, auditoría y propuesta de mejora.

## Qué incluye

```
mkdocs.yml              — configuración completa (tema, extensiones markdown, plugins)
requirements.txt         — mkdocs + mkdocs-material + mkdocs-pdf
.gitignore               — excluye soluciones del profesor y la carpeta site/
overrides/partials/      — pie de página con licencia CC BY-NC-SA
docs/
  index.md               — portada del módulo
  curriculum.md           — currículo oficial (RA + criterios + contenidos básicos)
  cierre.md               — cierre del módulo
  css/extra.css           — estilos: pestañas coloreadas (.tabs-colored), footer, marco de imágenes
  temaN/
    index.md              — índice de tema (RA, criterios, contenidos, actividades)
    *.md                   — un fichero por apartado de teoría
    actividad_N_M.md       — un fichero por actividad
    plantillas/            — aquí van los .docx que descargan los alumnos
    img/                   — capturas e imágenes de este tema
    diapositivas/          — PDF (y opcionalmente PPTX) de las diapositivas de cada apartado
```

## Estructura por tema (repítela para cada tema nuevo)

Cada tema es una carpeta `docs/temaN/` con:

- `index.md` — cabecera con el RA, lista de criterios de evaluación (✅ una por línea) y el
  índice de apartados + actividades, en el orden en que se deben estudiar.
- Un `.md` por apartado de teoría, con el embed del PDF de diapositivas al principio.
- Un `actividad_N_M.md` por actividad, intercalado en el `nav` de `mkdocs.yml` justo después
  del apartado de teoría al que corresponde.
- `plantillas/`, `img/`, `diapositivas/` — mismos nombres en todos los temas, para que todo
  el sitio sea uniforme.

Recuerda añadir cada página nueva al bloque `nav:` de `mkdocs.yml`, o no aparecerá en el menú
lateral aunque el fichero exista.

## Convenciones de estilo (para que el contenido nuevo case con el resto)

**Pestañas:** envuélvelas siempre en `<div class="tabs-colored" markdown>` — sin el wrapper
no tienen color:

```markdown
<div class="tabs-colored" markdown>

=== "🔵 Opción A"
    Contenido A.

=== "🟢 Opción B"
    Contenido B.

</div>
```

**Diagramas Mermaid:** usa `flowchart LR/TD` con nodos simples + emoji. No uses `classDef` ni
colores personalizados en los nodos: rompe la consistencia visual del sitio.

**Admonitions:** `!!! info` para definiciones, `!!! tip` para matices, `!!! warning` para
errores frecuentes, `!!! example` para casos concretos. No satures: 2-3 seguidos como máximo.

**Densidad:** no más de 4-5 líneas de texto seguido sin un elemento visual (tabla, diagrama,
admonition, código o pestañas). Tampoco encadenes elementos visuales sin una frase que los
introduzca.

**Formas verbales:** pretérito perfecto compuesto ("ha coincidido", "has fallado"), no
pretérito indefinido ("coincidió", "fallaste"), salvo hechos históricos con fecha concreta.

**Soluciones del profesor:** nunca van en `docs/` (se publicarían en la web). Genera los
`.docx`/`.pptx` de soluciones y los scripts que los generan en una carpeta de trabajo aparte,
fuera del repo (por ejemplo `C:\Users\TuUsuario\docxgen`), y usa el patrón de nombre
`Actividad_X_Y_Solucion.docx`. Las plantillas en blanco que sí ve el alumno van dentro del
repo, en `docs/temaX/plantillas/`.

**Actividades a prueba de IA:** contexto personal e irrepetible, razonamiento explícito
obligatorio, preguntas de "qué pasaría si", errores deliberados para detectar, comparación
justificada de alternativas. El objetivo es que un alumno no pueda aprobar usando IA sin
entender la materia.
