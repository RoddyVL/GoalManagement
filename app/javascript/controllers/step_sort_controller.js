import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  connect() {
    this.sortable = new Sortable(this.element, {
      animation: 150,
      ghostClass: "bg-light",
      onEnd: this.reorder.bind(this),
    });
  }

  reorder(event) {
    const stepId = event.item.dataset.id;
    const newIndex = event.newIndex + 1; // Priorité basée sur l'index

    fetch(`/steps/${stepId}/reorder`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ priority: newIndex }),
    });
  }

  updateNote(event) {
    const stepId = event.target.dataset.stepId;
    const note = event.target.value;

    fetch(`/steps/${stepId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ step: { note: note } })
    })
    .then(response => {
      if (!response.ok) throw new Error("Erreur lors de la mise à jour");
      return response.json();
    })
    .then(data => console.log("Note mise à jour", data))
    .catch(error => console.error("Erreur:", error));
  }
}
