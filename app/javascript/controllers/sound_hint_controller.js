import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "hint"]

  connect() {
    this.videoTarget.addEventListener("volumechange", this.hideHintIfSoundEnabled.bind(this))
    this.videoTarget.addEventListener("play", this.hideHintIfSoundEnabled.bind(this))
  }

  hideHintIfSoundEnabled() {
    if (!this.videoTarget.muted && this.videoTarget.volume > 0) {
      this.hintTarget.style.display = "none"
    }
  }

  enableSound() {
    this.videoTarget.muted = false
    this.videoTarget.volume = 1
    this.videoTarget.play()
    this.hintTarget.style.display = "none"
  }
}
