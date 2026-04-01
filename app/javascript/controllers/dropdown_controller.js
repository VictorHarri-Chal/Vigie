import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "label", "input", "option"]

  connect() {
    this._closeHandler = this._handleOutsideClick.bind(this)
    this._otherOpenHandler = (e) => {
      if (e.detail.source !== this.element) this.menuTarget.classList.add("hidden")
    }
    document.addEventListener("click", this._closeHandler)
    document.addEventListener("dropdown:open", this._otherOpenHandler)
  }

  disconnect() {
    document.removeEventListener("click", this._closeHandler)
    document.removeEventListener("dropdown:open", this._otherOpenHandler)
  }

  toggle(event) {
    event.stopPropagation()
    if (this.menuTarget.classList.contains("hidden")) {
      document.dispatchEvent(new CustomEvent("dropdown:open", { detail: { source: this.element } }))
    }
    this.menuTarget.classList.toggle("hidden")
  }

  select(event) {
    const { value, label } = event.currentTarget.dataset
    this.inputTarget.value = value
    this.labelTarget.textContent = label
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.menuTarget.classList.add("hidden")

    this.optionTargets.forEach(opt => {
      opt.classList.toggle("text-yellow-400", opt.dataset.value === value)
      opt.classList.toggle("text-gray-300", opt.dataset.value !== value)
    })
  }

  _handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
