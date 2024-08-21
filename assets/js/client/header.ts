export class TournamentHeader extends HTMLElement {
  private canary = document.createElement("div");
  private observer: IntersectionObserver;
  private _internals = this.attachInternals();

  constructor() {
    super();
    this.observer = new IntersectionObserver(([{ isIntersecting }]) => {
      if (isIntersecting) this._internals.states.delete("scrolled");
      else this._internals.states.add("scrolled");
      console.log(this._internals.states);
    });
  }

  connectedCallback() {
    this.canary.setAttribute("data-scroll-canary", "");
    this.parentNode!.insertBefore(this.canary, this);
    this.observer.observe(this.canary);
  }
  disconnectedCallback() {
    this.parentNode!.removeChild(this.canary);
    this.observer.unobserve(this.canary);
  }
}
