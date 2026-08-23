# Recursos de la Actividad 3.2

`escaparate.war` ya está construido e incluido (Java 21, Spring Boot 4.1.0, `2.2.0-SNAPSHOT`). El alumnado no
lo construye, solo lo despliega.

Si Escaparate cambia y hace falta reconstruirlo, desde `escaparate-app/` (con un JDK 21 en el PATH):

```powershell
.\mvnw.cmd clean package -DskipTests
```

El WAR queda en `target/escaparate.war` — cópialo aquí y regenera `actividad_3_2_recursos.zip`.

`01-schema.sql` y `02-data.sql` son copia directa de `escaparate-app/db/`.

No incluyas nunca `soluciones-profesor/` ni `MAPA-DOCENTE.md` del repositorio de Escaparate en ningún zip
que llegue al alumnado (ver `INSTRUCCIONES-HITO9.md` del propio repo).
