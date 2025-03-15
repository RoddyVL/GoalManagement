import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  toggle(event) {
    const checkbox = event.target
    const stepId = checkbox.dataset.stepId
    const status = checkbox.checked ? 1 : 0

    // Envoi d'une requête PATCH pour mettre à jour le statut du step
    fetch(`/steps/${stepId}/toggle_status`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify({ status: status })
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Erreur lors de la mise à jour du statut.')
      }
      return response.json()
    })
    .then(data => {
      console.log('Statut mis à jour avec succès:', data)
    })
    .catch(error => {
      console.error('Erreur:', error)
      // Réinitialiser l'état de la checkbox en cas d'erreur
      checkbox.checked = !checkbox.checked
    })
  }
}
