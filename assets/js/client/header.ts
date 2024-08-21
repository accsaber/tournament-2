export class TournamentHeader extends HTMLElement {
  private canary = document.querySelector("#scroll_canary")!;
  private observer: IntersectionObserver;
  private _internals = this.attachInternals();

  constructor() {
    super();
    this.observer = new IntersectionObserver(([{ isIntersecting }]) => {
      if (isIntersecting) this._internals.states.delete("scrolled");
      else this._internals.states.add("scrolled");
    });
  }

  connectedCallback() {
    this.observer.observe(this.canary);
  }
  disconnectedCallback() {
    this.observer.unobserve(this.canary);
  }
}
