use "random"
use "time"
use "collections"
use "utils"
use "structs"
use "interfaces"

actor GossipMember is Member
  let _id: USize
  var _state: GossipState
  var _neighbors: Array[Member tag] iso
  let _env: Env
  let _main: Main tag
  let _logger: Logger tag
  let _network_logger: NetworkLogger tag
  let _threshold: F64 = 10

  new create(id: USize, initial_state: GossipState, neighbors: Array[Member tag] iso, env: Env, main: Main tag, logger: Logger tag, network_logger: NetworkLogger tag) =>
    _id = id
    _state = initial_state
    _neighbors = consume neighbors
    _env = env
    _main = main
    _logger = logger
    _network_logger = network_logger

  fun ref get_id(): USize => _id

  be add_neighbors(new_neighbors: Array[Member tag] val) =>
    for neighbor in new_neighbors.values() do
      _neighbors.push(neighbor)
    end

  be start() =>
    _network_logger.log_message("Gossip Node " + _id.string() + " started")
    send()

  be receive(message: Message val) =>
    let received_rumor = message.get_gossip_data()
    if received_rumor == _state.rumor then
      _state = GossipState(_state.rumor, _state.count + 1)
      // _logger.log_gossip(_id, "RECEIVE", _state.rumor, _state.count.usize())
      if _state.count >= _threshold then
        _main.report_convergence()
      else
        send()
      end
    end

  be send() =>
    if (_neighbors.size() > 0) then
      let rand = Rand(Time.nanos().u64())
      let real_fraction = rand.real()
      let scaled_fraction = real_fraction * (_neighbors.size().f64() * 1000.0)
      let index = (scaled_fraction.usize() % _neighbors.size())
      // _network_logger.log_message("Random chosen index: " + index.string())
      // _logger.log_gossip(_id, "SEND", _state.rumor, _state.count.usize())
      // _network_logger.log_message("Sent to Node " + _id.string() + "'s "+ index.string() + " neighbor")
      try
        let message = GossipMessage(_state.rumor)
        _neighbors(index)?.receive(message)
      end
    end

class val GossipMessage is Message
  let _rumor: String

  new val create(rumor: String) =>
    _rumor = rumor

  fun get_data(): (F64, F64) =>
    (0, 0) // Gossip doesn't use numerical data, so we return (0, 0)

  fun get_gossip_data(): String =>
    _rumor