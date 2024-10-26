export type LUID = number;

export type Message<K extends string, T> = {
  _type: K;
} & T;

export type BSPlusEvent<K extends string, T> = Message<
  "_event",
  {
    _event: K;
  } & Record<K, T>
>;

export type RoomJoinedEvent = BSPlusEvent<"RoomJoined", undefined>;
export type RoomStateEvent = BSPlusEvent<
  "RoomState",
  "SelectingSong" | "WarmingUp" | "Playing" | "Results"
>;
export type ScoreEvent = BSPlusEvent<
  "Score",
  {
    LUID: LUID;
    Score: number;
    Accuracy: number;
    Combo: number;
    MissCount: number;
    Failed: boolean;
    Deleted: boolean;
    Spectating: boolean;
  }
>;

export interface Player {
  LUID: LUID;
  UserID: string;
  UserName: string;
  Spectating: boolean;
}

export type PlayerJoinedEvent = BSPlusEvent<"PlayerJoined", Player>;

export type PlayerUpdatedEvent = BSPlusEvent<
  "PlayerUpdated",
  { LUID: LUID } & Partial<Player>
>;
export type PlayerLeftEvent = BSPlusEvent<
  "PlayerLeaved",
  { LUID: LUID } & Partial<Player>
>;

type BSPlusEventMessage =
  | RoomJoinedEvent
  | RoomStateEvent
  | ScoreEvent
  | PlayerJoinedEvent
  | PlayerUpdatedEvent;

export default BSPlusEventMessage;
