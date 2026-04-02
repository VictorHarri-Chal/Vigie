import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas"]
  static values = { config: Object }

  connect() {
    this.chart = new Chart(this.canvasTarget, this.configValue)
  }

  disconnect() {
    this.chart?.destroy()
  }
}
