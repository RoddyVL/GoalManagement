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
}
