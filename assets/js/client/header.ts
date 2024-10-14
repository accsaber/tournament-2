export class TournamentHeader extends HTMLElement {
  private canary = document.querySelector("#scroll_canary")!;
  private observer: IntersectionObserver;
  private _internals = this.attachInternals();
  private navbox = this.querySelector("dialog")!;
  private menuToggle = this.querySelector(".menu-toggle")!;
  private close = this.querySelector(".close")!;

  constructor() {
    super();
    this.observer = new IntersectionObserver(([{ isIntersecting }]) => {
      if (isIntersecting) this._internals.states.delete("scrolled");
      else this._internals.states.add("scrolled");
    });
  }

  connectedCallback() {
    this.observer.observe(this.canary);

    this.menuToggle.addEventListener("click", () => {
      this.navbox.showModal();
    });

    this.close.addEventListener("click", () => this.navbox.close());
  }
  disconnectedCallback() {
    this.observer.unobserve(this.canary);
  }
}
