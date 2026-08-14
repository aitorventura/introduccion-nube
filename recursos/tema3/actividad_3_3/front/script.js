// Pide las reseñas al backend (API_URL viene de config.js) y las pinta
// en la página. Es la parte que demuestra la cadena completa: front
// estático en S3 haciendo fetch() a un backend en EC2, que a su vez
// consulta la base de datos en RDS.

const estado = document.getElementById("estado");
const lista = document.getElementById("lista-resenas");

fetch(API_URL)
  .then((respuesta) => {
    if (!respuesta.ok) {
      throw new Error(`El backend respondió con estado ${respuesta.status}`);
    }
    return respuesta.json();
  })
  .then((resenas) => {
    estado.remove();
    resenas.forEach((resena) => {
      const item = document.createElement("li");
      item.className = "resena";
      item.innerHTML = `
        <h2>${resena.restaurante}</h2>
        <p>${resena.comentario}</p>
        <p><span class="puntuacion">${resena.puntuacion}/5</span>
           &middot; <span class="fecha">${resena.fecha}</span></p>
      `;
      lista.appendChild(item);
    });
  })
  .catch((error) => {
    estado.textContent = `No se han podido cargar las reseñas: ${error.message}`;
    estado.classList.add("error");
  });
