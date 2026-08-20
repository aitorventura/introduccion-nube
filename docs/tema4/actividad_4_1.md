# 🧪 Actividad 4.1: Balanceador de carga y Auto Scaling Group

!!! danger "Pendiente — depende de Escaparate"
    Esta actividad depende de **Escaparate**, la aplicación transversal de los temas 3-7, todavía sin definir. No la publiques ni la des en clase tal cual — lo de abajo es el encargo para cuando se escriba de verdad, no contenido listo.

## Prompt pendiente

**Qué usamos**: el backend de Escaparate, replicado detrás de un balanceador de carga con Auto Scaling Group.

**Idea central**: la aplicación necesita endpoints propios para que el balanceador y el grupo de escalado sepan de verdad si una réplica está sana — `/api/instancia` (para ver qué instancia concreta responde en cada petición y comprobar el reparto), `/salud/listo` (health check) y `/carga` (para forzar y demostrar el escalado automático) son las piezas protagonistas.

**Continuación de almacenamiento (misma sesión)**: las imágenes que antes vivían en el disco local de una sola instancia pasan a EFS, compartido entre todas las réplicas mediante una variable `APP_STORAGE_PATH` — el código de la aplicación no debería necesitar cambios para leer/escribir ahí. *Nota: la chuleta original decía "Java no cambia" — es de antes de la decisión de usar Python + Flask como stack estándar del módulo (ver memoria del proyecto); cuando se defina Escaparate, ajustar esta frase al stack real que se elija.*

**Referencia de la chuleta original** (revalidar el "hito H7" contra `curriculum.md`, probablemente RA3e — balanceo de carga y escalado automático): filas "4.1" y "4.1, continuación".

Cuando Escaparate esté definido, reescribe esta actividad completa siguiendo el mismo patrón que el resto del módulo: Contexto, Qué vas a practicar, Requisitos previos, Parte A guiada + Parte B reto (a prueba de IA), Criterios de evaluación, Cierre con aviso de limpieza de recursos — y regenera sus plantillas docx.
