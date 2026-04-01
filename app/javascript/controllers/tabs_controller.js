import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { activeTab: Number }

  connect() {
    this.showTab(this.activeTabValue)
  }

  switch(event) {
    const index = this.tabTargets.indexOf(event.currentTarget)
    this.showTab(index)
  }

  showTab(index) {
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("border-yellow-400", i === index)
      tab.classList.toggle("text-yellow-400", i === index)
      tab.classList.toggle("border-transparent", i !== index)
      tab.classList.toggle("text-gray-400", i !== index)
    })

    this.panelTargets.forEach((panel, i) => {
      panel.classList.toggle("hidden", i !== index)
    })
  }
}
