use "random"
use "time"
use "collections"

// Define a new State structure
struct State
  var s: F64
  var w: F64

  // Define an apply method to initialize State
  new create(state_s: F64, state_w: F64) =>
    this.s = state_s
    this.w = state_w

actor Member
  let _id: USize
  var _s: F64
  var _w: F64
  var _neighbors: Array[Member tag] iso
  var _rumor_count: USize = 0
  var _last_push_sum_time: U64 = 0
  var _unchanged_count: USize = 0

  new create(id: USize, s: F64, w: F64, neighbors: Array[Member tag] iso) =>
    _id = id
    _s = s
    _w = w
    _neighbors = consume neighbors

  be add_neighbor(neighbor: Member tag) =>
    _neighbors.push(neighbor)

  be start_gossip(rumor: String, start_time: U64) =>
    receive_gossip(rumor, start_time)

  be receive_gossip(rumor: String, start_time: U64) =>
    _rumor_count = _rumor_count + 1
    if _rumor_count < 10 then
      let message = GossipMessage(rumor, start_time)
      spread_message(message)
    elseif _rumor_count == 10 then
      @printf("Node %d converged. Time: %d ns\n".cstring(), _id, Time.nanos() - start_time)
    end
  be start_push_sum(start_time: U64) =>
    push_sum(start_time)

  be receive_push_sum(s': F64, w': F64, start_time: U64) =>
    let old_ratio = _s / _w
    _s = _s + s'
    _w = _w + w'
    let new_ratio = _s / _w

    if (old_ratio - new_ratio).abs() < 1e-10 then
      _unchanged_count = _unchanged_count + 1
    else
      _unchanged_count = 0
    end

    if _unchanged_count >= 3 then
      @printf("Node %d converged. Time: %d ns, final ratio: %f\n".cstring(), _id, Time.nanos() - start_time, new_ratio)
    else
      push_sum(start_time)
    end

  fun ref push_sum(start_time: U64) =>
    _s = _s / 2
    _w = _w / 2
    let message = PushSumMessage(_s, _w, start_time)
    spread_message(message)

  fun ref spread_message(message: Message) =>
    if _neighbors.size() > 0 then
      let index = Rand.int(_neighbors.size().u64()).usize()
      try
        match message
        | let gm: GossipMessage =>
          _neighbors(index)?.receive_gossip(gm.rumor, gm.start_time)
        | let psm: PushSumMessage =>
          _neighbors(index)?.receive_push_sum(psm.s, psm.w, psm.start_time)
        end
      end
    end

interface Message
  fun apply(member: Member)

class GossipMessage is Message
  let rumor: String
  let start_time: U64

  new create(r: String, st: U64) =>
    rumor = r
    start_time = st

  fun apply(member: Member) =>
    member.receive_gossip(rumor, start_time)

class PushSumMessage is Message
  let s: F64
  let w: F64
  let start_time: U64

  new create(state_s: F64, state_w: F64, st: U64) =>
    s = state_s
    w = state_w
    start_time = st

  fun apply(member: Member) =>
    member.receive_push_sum(s, w, start_time)