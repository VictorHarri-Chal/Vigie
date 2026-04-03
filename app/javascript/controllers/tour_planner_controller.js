import { Controller } from "@hotwired/stimulus"

const OSRM_URL = "https://router.project-osrm.org/trip/v1/driving"

export default class extends Controller {
  static values = { pavs: Array }
  static targets = ["threshold", "thresholdLabel", "count", "distance", "routeList", "calculateBtn"]

  connect() {
    this.map = L.map("route-map", { zoomControl: false, minZoom: 10 }).setView([48.8566, 2.3522], 11)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "© OpenStreetMap contributors"
    }).addTo(this.map)

    L.control.zoom({ position: "bottomright" }).addTo(this.map)

    this.markers = []
    this.selected = new Set()
    this.routeLayer = null

    this.pavsValue.forEach(pav => this.addMarker(pav))

    if (this.markers.length > 0) {
      this.map.fitBounds(
        L.featureGroup(this.markers).getBounds(),
        { paddingTopLeft: [300, 60], paddingBottomRight: [60, 60] }
      )
    }

    this.applyThreshold()
  }

  disconnect() {
    this.map?.remove()
  }

  addMarker(pav) {
    const marker = L.marker([pav.lat, pav.lng], { icon: this.markerIcon(pav, false) })
    marker.pav = pav
    marker.addTo(this.map)
    marker.on("click", () => this.toggleMarker(pav, marker))
    this.markers.push(marker)
  }

  thresholdChanged() {
    this.thresholdLabelTarget.textContent = `${this.thresholdTarget.value} %`
    this.applyThreshold()
  }

  applyThreshold() {
    const threshold = parseInt(this.thresholdTarget.value)
    this.selected.clear()
    this.clearRoute()

    this.markers.forEach(marker => {
      const fill = marker.pav.fill_percent
      const include = fill !== null && fill !== undefined && fill >= threshold
      if (include) this.selected.add(marker.pav.id)
      marker.setIcon(this.markerIcon(marker.pav, include))
    })

    this.updatePanel()
  }

  toggleMarker(pav, marker) {
    if (this.selected.has(pav.id)) {
      this.selected.delete(pav.id)
    } else {
      this.selected.add(pav.id)
    }
    marker.setIcon(this.markerIcon(pav, this.selected.has(pav.id)))
    this.clearRoute()
    this.updatePanel()
  }

  async calculate() {
    const pavs = this.markers.filter(m => this.selected.has(m.pav.id)).map(m => m.pav)
    if (pavs.length < 2) return

    this.setLoading(true)

    try {
      const coords = pavs.map(p => `${p.lng},${p.lat}`).join(";")
      const res = await fetch(
        `${OSRM_URL}/${coords}?roundtrip=false&source=first&destination=last&geometries=geojson&overview=full`
      )
      if (!res.ok) throw new Error()
      const data = await res.json()
      if (data.code !== "Ok") throw new Error()

      const trip = data.trips[0]

      const ordered = new Array(pavs.length)
      data.waypoints.forEach((wp, i) => { ordered[wp.waypoint_index] = pavs[i] })

      this.clearRoute()

      this.routeLayer = L.geoJSON(
        { type: "Feature", geometry: trip.geometry },
        { style: { color: "#7c3aed", weight: 4, dashArray: "6 10", opacity: 0.85 } }
      ).addTo(this.map)

      this.animateRoute()

      this.map.fitBounds(this.routeLayer.getBounds(), {
        paddingTopLeft: [300, 60], paddingBottomRight: [60, 60]
      })

      ordered.forEach((pav, i) => {
        const marker = this.markers.find(m => m.pav.id === pav.id)
        if (marker) marker.setIcon(this.numberedIcon(i + 1, this.fillColor(pav.fill_percent)))
      })

      const distMeters = trip.distance
      this.distanceTarget.textContent = distMeters < 1000
        ? `${Math.round(distMeters)} m`
        : `${(distMeters / 1000).toFixed(1)} km`

      this.routeListTarget.innerHTML = ordered.map((pav, i) => {
        const fill = pav.fill_percent !== null && pav.fill_percent !== undefined
          ? `${Math.round(pav.fill_percent)} %`
          : "—"
        const color = this.fillColor(pav.fill_percent)
        return `
          <div class="flex items-center gap-3 py-2.5 border-b border-gray-800/60 last:border-0">
            <span class="w-5 h-5 rounded-full flex items-center justify-center shrink-0 text-xs font-bold" style="background:${color}22;color:${color}">${i + 1}</span>
            <div class="min-w-0 flex-1">
              <p class="text-xs font-medium text-white truncate">${pav.name}</p>
              <p class="text-xs text-gray-500">${fill}</p>
            </div>
          </div>
        `
      }).join("")
    } catch {
      this.routeListTarget.innerHTML = `<p class="text-xs text-red-400 text-center py-6">Impossible de calculer la route — réessayez</p>`
    } finally {
      this.setLoading(false)
    }
  }

  animateRoute() {
    if (!document.getElementById("route-dash-anim")) {
      const style = document.createElement("style")
      style.id = "route-dash-anim"
      style.textContent = "@keyframes route-dash { to { stroke-dashoffset: -16; } }"
      document.head.appendChild(style)
    }
    this.routeLayer.eachLayer(layer => {
      const el = layer.getElement()
      if (el) el.style.animation = "route-dash 1s linear infinite"
    })
  }

  clearRoute() {
    if (!this.routeLayer) return
    this.routeLayer.remove()
    this.routeLayer = null
    this.markers.forEach(m => m.setIcon(this.markerIcon(m.pav, this.selected.has(m.pav.id))))
    this.distanceTarget.textContent = "—"
    this.routeListTarget.innerHTML = `<p class="text-xs text-gray-600 text-center py-6">Ajustez le seuil puis cliquez sur Calculer</p>`
  }

  updatePanel() {
    const disabled = this.selected.size < 2
    this.countTarget.textContent = this.selected.size
    this.calculateBtnTarget.disabled = disabled
    this.calculateBtnTarget.classList.toggle("opacity-40", disabled)
    this.calculateBtnTarget.classList.toggle("cursor-not-allowed", disabled)
    this.calculateBtnTarget.classList.toggle("cursor-pointer", !disabled)
  }

  setLoading(loading) {
    this.calculateBtnTarget.classList.toggle("opacity-60", loading)
    this.calculateBtnTarget.textContent = loading ? "Calcul en cours…" : "Calculer l'itinéraire"
    if (loading) {
      this.calculateBtnTarget.disabled = true
    } else {
      this.updatePanel()
    }
  }

  markerIcon(pav, selected) {
    const color = selected ? this.fillColor(pav.fill_percent) : "#374151"
    const size   = selected ? 22 : 16
    const border = selected ? "3px solid rgba(255,255,255,0.9)" : "2px solid rgba(255,255,255,0.15)"
    const shadow = selected
      ? `0 0 0 4px ${color}40, 0 4px 16px rgba(0,0,0,0.7)`
      : "0 2px 8px rgba(0,0,0,0.5)"
    return L.divIcon({
      html: `<div style="width:${size}px;height:${size}px;border-radius:50%;background:${color};border:${border};box-shadow:${shadow};cursor:pointer;"></div>`,
      className: "",
      iconSize: [size, size],
      iconAnchor: [size / 2, size / 2]
    })
  }

  numberedIcon(n, color) {
    return L.divIcon({
      html: `<div style="width:26px;height:26px;border-radius:50%;background:${color};border:3px solid rgba(255,255,255,0.9);box-shadow:0 0 0 4px ${color}40,0 4px 16px rgba(0,0,0,0.7);display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:700;color:rgba(0,0,0,0.75);cursor:pointer;">${n}</div>`,
      className: "",
      iconSize: [26, 26],
      iconAnchor: [13, 13]
    })
  }

  fillColor(percent) {
    if (percent === null || percent === undefined) return "#6b7280"
    if (percent > 80) return "#f87171"
    if (percent > 50) return "#facc15"
    return "#4ade80"
  }
}
