export default class LocalDateTime extends HTMLElement {
  constructor() {
    super();
  }
  connectedCallback() {
    const shadow = this.attachShadow({ mode: "open" });
    const content = this.textContent ?? "";
    shadow.textContent = new Date(content).toLocaleString();
  }
}
