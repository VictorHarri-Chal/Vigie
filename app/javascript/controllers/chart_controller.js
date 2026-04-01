import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { data: Array }
  static targets = ["canvas"]

  connect() {
    const labels = this.dataValue.map(d => d.date)
    const data = this.dataValue.map(d => d.fill_percent)

    this.chart = new Chart(this.canvasTarget, {
      type: "line",
      data: {
        labels,
        datasets: [{
          data,
          borderColor: "#facc15",
          backgroundColor: "rgba(250, 204, 21, 0.08)",
          borderWidth: 2,
          tension: 0.3,
          fill: true,
          pointRadius: 2,
          pointBackgroundColor: "#facc15"
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: "#1f2937",
            borderColor: "#374151",
            borderWidth: 1,
            titleColor: "#9ca3af",
            bodyColor: "#f9fafb",
            callbacks: {
              label: ctx => `${ctx.parsed.y} %`
            }
          }
        },
        scales: {
          x: {
            ticks: { color: "#6b7280", maxTicksLimit: 6 },
            grid: { color: "#1f2937" }
          },
          y: {
            min: 0,
            max: 100,
            ticks: { color: "#6b7280", callback: v => `${v}%` },
            grid: { color: "#1f2937" }
          }
        }
      }
    })
  }

  disconnect() {
    this.chart?.destroy()
  }
}
