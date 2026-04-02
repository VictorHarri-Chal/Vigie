import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { pavs: Array }
  static targets = ["panel", "wasteTypeFilter", "fillLevelFilter", "wasteTypeLabel", "fillLevelLabel", "resetBtn", "statPavs", "statFill", "statIncidents", "searchInput"]

  connect() {
    this.map = L.map("map", { zoomControl: false, minZoom: 12 }).setView([48.8566, 2.3522], 11)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "© OpenStreetMap contributors"
    }).addTo(this.map)

    L.control.zoom({ position: "bottomright" }).addTo(this.map)

    this.markers = []
    this.activeMarker = null
    this.pavsValue.forEach(pav => this.addMarker(pav))

    if (this.markers.length > 0) {
      const group = L.featureGroup(this.markers)
      this.map.fitBounds(group.getBounds(), { padding: [60, 60] })
      this.defaultBounds = group.getBounds()
    }
  }

  disconnect() {
    this.map?.remove()
  }

  addMarker(pav) {
    const color = this.fillColor(pav.fill_percent)
    const marker = L.marker([pav.lat, pav.lng], { icon: this.makeIcon(color, false) })
    marker.pav = pav
    marker.color = color
    marker.addTo(this.map)
    marker.on("click", () => this.openPanel(pav.id, marker))

    this.markers.push(marker)
  }

  makeIcon(color, active) {
    if (active) {
      return L.divIcon({
        html: `<div style="width:30px;height:30px;border-radius:50%;background:${color};border:3px solid #fff;box-shadow:0 0 0 5px rgba(255,255,255,0.25),0 0 0 9px ${color}40,0 6px 24px rgba(0,0,0,0.8);cursor:pointer;"></div>`,
        className: "",
        iconSize: [30, 30],
        iconAnchor: [15, 15]
      })
    }

    return L.divIcon({
      html: `<div style="width:24px;height:24px;border-radius:50%;background:${color};border:3px solid rgba(255,255,255,0.95);box-shadow:0 0 0 5px ${color}40,0 6px 20px rgba(0,0,0,0.75);cursor:pointer;"></div>`,
      className: "",
      iconSize: [24, 24],
      iconAnchor: [12, 12]
    })
  }

  filterMarkers() {
    const wasteType = this.wasteTypeFilterTarget.value
    const fillLevel = this.fillLevelFilterTarget.value
    const visible = []

    this.markers.forEach(marker => {
      const matchesWaste = !wasteType || marker.pav.waste_type === wasteType
      const matchesFill = this.matchesFillLevel(marker.pav.fill_percent, fillLevel)

      if (matchesWaste && matchesFill) {
        marker.addTo(this.map)
        visible.push(marker.pav)
      } else {
        marker.remove()
      }
    })

    this.updateStats(visible)

    const hasFilter = !!this.wasteTypeFilterTarget.value || !!this.fillLevelFilterTarget.value
    this.resetBtnTarget.classList.toggle("hidden", !hasFilter)
    this.resetBtnTarget.classList.toggle("flex", hasFilter)
  }

  search(event) {
    const q = event.target.value.toLowerCase().trim()
    if (!q) return
    const marker = this.markers.find(m =>
      m.pav.name.toLowerCase().includes(q) ||
      m.pav.pav_id.toLowerCase().includes(q)
    )
    if (marker) this.openPanel(marker.pav.id, marker)
  }

  resetFilters() {
    this.wasteTypeFilterTarget.value = ""
    this.fillLevelFilterTarget.value = ""
    this.wasteTypeLabelTarget.textContent = "Tous types"
    this.fillLevelLabelTarget.textContent = "Tous niveaux"

    this.element.querySelectorAll("[data-dropdown-target='option']").forEach(opt => {
      opt.classList.toggle("text-yellow-400", opt.dataset.value === "")
      opt.classList.toggle("text-gray-300", opt.dataset.value !== "")
    })

    this.wasteTypeFilterTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  updateStats(pavs) {
    const fills = pavs.map(p => p.fill_percent).filter(f => f !== null && f !== undefined)
    const avgFill = fills.length > 0 ? Math.round(fills.reduce((a, b) => a + b, 0) / fills.length) : null
    const incidents = pavs.reduce((sum, p) => sum + (p.open_incidents || 0), 0)

    this.statPavsTarget.textContent = pavs.length
    this.statFillTarget.textContent = avgFill !== null ? `${avgFill} %` : "—"
    this.statIncidentsTarget.textContent = incidents
  }

  matchesFillLevel(fill, level) {
    if (!level) return true
    if (level === "unknown") return fill === null || fill === undefined
    if (fill === null || fill === undefined) return false
    if (level === "low") return fill < 50
    if (level === "medium") return fill >= 50 && fill <= 80
    if (level === "high") return fill > 80
    return true
  }

  openPanel(pavId, marker) {
    if (this.activeMarker === marker) {
      this.closePanel()
      return
    }

    if (this.activeMarker) {
      this.activeMarker.setIcon(this.makeIcon(this.activeMarker.color, false))
    }

    marker.setIcon(this.makeIcon(marker.color, true))
    this.activeMarker = marker

    this.map.flyTo([marker.pav.lat, marker.pav.lng], 15, { animate: true, duration: 0.4 })

    const frame = document.querySelector("turbo-frame#pav-panel")
    frame.src = `/pavs/${pavId}`
    this.panelTarget.classList.remove("translate-x-full")
  }

  closePanel() {
    if (this.activeMarker) {
      this.activeMarker.setIcon(this.makeIcon(this.activeMarker.color, false))
      this.activeMarker = null
    }

    this.panelTarget.classList.add("translate-x-full")
    const frame = document.querySelector("turbo-frame#pav-panel")
    if (frame) frame.src = ""

    this.map.zoomOut(1, { animate: true })
  }

  fillColor(percent) {
    if (percent === null || percent === undefined) return "#6b7280"
    if (percent > 80) return "#f87171"
    if (percent > 50) return "#facc15"
    return "#4ade80"
  }
}
