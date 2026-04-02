import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "label", "checkbox"]

  connect() {
    this.boundClose = this.closeOutside.bind(this)
    document.addEventListener("click", this.boundClose)
    this.updateLabel()
  }

  disconnect() {
    document.removeEventListener("click", this.boundClose)
  }

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  change() {
    this.updateLabel()
  }

  updateLabel() {
    const checked = this.checkboxTargets.filter(cb => cb.checked)
    if (checked.length === 0) {
      this.labelTarget.textContent = "Tous les PAVs"
    } else if (checked.length === 1) {
      this.labelTarget.textContent = checked[0].dataset.label
    } else {
      this.labelTarget.textContent = `${checked.length} PAVs`
    }
  }

  closeOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
