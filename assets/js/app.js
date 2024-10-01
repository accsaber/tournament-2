// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "topbar";
import { TournamentHeader } from "./client/header";
import "./client/analytics";
import LocalDateTime from "./client/local-timestamp";
import * as bert from "./bert";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  ?.getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  decode: (rawPayload, callback) => {
    console.log(rawPayload);
    let [join_ref, ref, topic, event, payload] = bert.decode(rawPayload);
    return callback({ join_ref, ref, topic, event, payload });
  },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()

window.liveSocket = liveSocket;

customElements.define("tournament-header", TournamentHeader);
customElements.define("local-datetime", LocalDateTime);

window.addEventListener("phx:silent_new_url", (e) => {
  if (!(e instanceof CustomEvent)) return;
  const to = e.detail.to;
  if (typeof to !== "string") return;
  history.replaceState(history.state, "", to);
});
