use "random"
use "time"
use "collections"
use "utils"
use "algorithms"
use "structs"
use "interfaces"

actor GossipMember is Member
  let _id: USize
  var _state: GossipState
  var _rumor: String
  var _count: USize
  var _neighbors: Array[Member tag] iso
  let _threshold: USize
  let _env: Env
  let _main: Main tag
  let _logger: Logger tag
  let _network_logger: NetworkLogger tag
  let _random: RandomUtils
  var _converged: Bool

  new create(id: USize, state: GossipState, neighbors: Array[Member tag] iso, threshold: USize, env: Env, main: Main tag, logger: Logger tag, network_logger: NetworkLogger tag) =>
    _id = id
    _state = state
    _rumor = state.rumor
    _count = 0
    _neighbors = consume neighbors
    _threshold = threshold
    _env = env
    _main = main
    _logger = logger
    _network_logger = network_logger
    _random = RandomUtils.create()
    _converged = false

  fun ref get_id(): USize => _id

  be add_neighbors(new_neighbors: Array[Member tag] val) =>
    for neighbor in new_neighbors.values() do
      _neighbors.push(neighbor)
    end

  be start() =>
    _network_logger.log_message("Gossip Node " + _id.string() + " started")
    send()

  be receive(message: Message val) =>
    match message
    | let gm: GossipMessage val =>
      let received_rumor = gm.get_data()
      if (received_rumor == _rumor) and (not _converged) then
        _count = _count + 1
        _logger.log_gossip(_id, "RECEIVE", _rumor, _count)
        
        if _count >= _threshold then
          _converged = true
          _main.report_convergence()
        else
          send()
        end
      end
    end

  be send() =>
    if (not _converged) and (_neighbors.size() > 0) then
      let index = _random.get_random_number_in_range(0, _neighbors.size() - 1)
      _logger.log_gossip(_id, "SEND", _rumor, _count)
      
      try
        let message = GossipMessage(_rumor)
        _neighbors(index)?.receive(message)
      end
    end