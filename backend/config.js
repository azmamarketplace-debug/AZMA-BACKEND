/* ==============
   API CONFIG 
================ */
const API_BASE = "https://azma-backend-production.up.railway.app/api";

/* =========================
   OPTIONAL HELPERS
========================= */
function getAPI(url) {
  return `${API_BASE}${url}`;
}