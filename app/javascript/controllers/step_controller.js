import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"];

  toggleStatus(event) {
    const stepId = event.target.dataset.stepId; // Récupère l'ID du step
    const checked = event.target.checked; // Vérifie si la case est cochée
    const url = `/steps/${stepId}/toggle_status`;

    fetch(url, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ status: checked ? 1 : 0 }) // Met à jour le statut
    })
    .then(response => response.json())
    .then(data => {
      console.log("Step mis à jour:", data);
    })
    .catch(error => console.error("Erreur:", error));
  }
}
