import type BSPlusEventMessage from "./event";

export default class BSPlusClient {
  socket: WebSocket;
  open: boolean = false;
  callback: (e: BSPlusEventMessage) => void = () => { };

  constructor(url = "ws://127.0.0.1:2948/socket") {
    this.socket = new WebSocket(url);
    this.socket.addEventListener("open", () => this.handleOpen());
    this.socket.addEventListener("close", () => this.handleClose());
    this.socket.addEventListener("message", (e) => this.handleMessage(e));
  }

  private handleOpen() {
    this.open = true;
    console.info("Connected to overlay socket");
  }

  private handleClose() {
    this.open = true;
    console.info("Disconnected from overlay socket");
  }

  private handleMessage(event: MessageEvent<unknown>) {
    const raiseInvalidBody = () => {
      throw new Error("Invalid event body");
    };
    if (typeof event.data !== "string") raiseInvalidBody();
    const unparsedData = event.data as string;

    const data = JSON.parse(unparsedData);
    const messageType = String(data._type || raiseInvalidBody());

    switch (messageType) {
      case "event":
        this.callback(data);
        break;
      default:
        console.warn(`Received unknown message type '${messageType}'`);
    }
  }
}
