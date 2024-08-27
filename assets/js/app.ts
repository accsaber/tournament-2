import { TournamentHeader } from "./client/header";

customElements.define("tournament-header", TournamentHeader);

window.addEventListener("phx:silent_new_url", (e) => {
  if (!(e instanceof CustomEvent)) return;
  const to = e.detail.to;
  if (typeof to !== "string") return;
  history.replaceState(history.state, "", to);
});
