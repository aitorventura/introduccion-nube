document.addEventListener("DOMContentLoaded", () => {
  const estado = document.getElementById("estado");
  // API_URL se define en config.js. Todavía no existe ningún backend
  // desplegado -- es normal que esta llamada falle en esta sesión.
  fetch(API_URL + "/api/salud")
    .then((respuesta) => {
      if (!respuesta.ok) throw new Error("El backend no responde correctamente");
      return respuesta.json();
    })
    .then(() => {
      estado.textContent = "✅ Taller operativo.";
    })
    .catch(() => {
      estado.textContent = "⚠️ Todavía no hay backend conectado a este front.";
    });
});
