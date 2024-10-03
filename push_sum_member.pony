use "random"
use "time"
use "collections"
use "utils"
use "algorithms"
use "structs"
use "interfaces"

actor PushSumMember is Member
  let _id: USize
  var _state: State
  var _neighbors: Array[Member tag] iso
  let _env: Env
  let _main: Main tag
  let _logger: Logger tag
  let _network_logger: NetworkLogger tag
  let _random: RandomUtils
  var _converged: Bool
  var _last_ratio: F64
  let _epsilon: F64

  new create(id: USize, initial_state: State, neighbors: Array[Member tag] iso, env: Env, main: Main tag, logger: Logger tag, network_logger: NetworkLogger tag, epsilon: F64) =>
    _id = id
    _state = initial_state
    _neighbors = consume neighbors
    _env = env
    _main = main
    _logger = logger
    _network_logger = network_logger
    _random = RandomUtils.create()
    _converged = false
    _last_ratio = 0
    _epsilon = epsilon

  fun ref get_id(): USize => _id

  be add_neighbors(new_neighbors: Array[Member tag] val) =>
    for neighbor in new_neighbors.values() do
      _neighbors.push(neighbor)
    end

  be start() =>
    _network_logger.log_message("Push-Sum Node " + _id.string() + " started")
    send()

  be receive(message: Message val) =>
    match message
    | let psm: PushSumMessage val =>
      if not _converged then
        let result = psm.get_data()
        match result
        | (let received_s: F64, let received_w: F64) =>
          _state = State(_state.s + received_s, _state.w + received_w)
          _logger.log(_id, "RECEIVE", _state.s, _state.w)
          
          let new_ratio = _state.s / _state.w
          if (_last_ratio - new_ratio).abs() < _epsilon then
            _converged = true
            _main.report_convergence()
          else
            _last_ratio = new_ratio
            send()
          end
        end
      end
    end

  be send() =>
    if (not _converged) and (_neighbors.size() > 0) then
      let index = _random.get_random_number_in_range(0, _neighbors.size() - 1)
      let half_s = _state.s / 2
      let half_w = _state.w / 2
      _state = State(half_s, half_w)
      _logger.log(_id, "SEND", _state.s, _state.w)
      
      try
        let message = PushSumMessage(half_s, half_w)
        _neighbors(index)?.receive(message)
      end
    end