use ".."
use "../interfaces"
use "../structs"
use "../utils"

class val PushSumAlgorithm is Algorithm
  let _epsilon: F64 = 1e-10
  let _consecutive_rounds: USize = 3

  new val create() =>
    None

  fun create_convergence_checker(member: Member): ConvergenceChecker ref =>
    PushSumConvergenceChecker(_epsilon, _consecutive_rounds)

  fun start(member: Member) =>
    member.send()

  fun process_message(current_state: State, message: Message val): State =>
    match message.get_data()
    | (let received_s: F64, let received_w: F64) =>
      State(current_state.s + received_s, current_state.w + received_w)
    else
      current_state
    end

  fun prepare_send(current_state: State): (State, Bool) =>
    let new_s = current_state.s / 2
    let new_w = current_state.w / 2
    (State(new_s, new_w), true)

  fun create_message(current_state: State): Message val =>
    PushSumMessage(current_state.s / 2, current_state.w / 2)

  fun log_receive(logger: Logger tag, id: USize, state: State) =>
    logger.log(id, "RECEIVE", state.s, state.w)

  fun log_send(logger: Logger tag, id: USize, state: State) =>
    logger.log(id, "SEND", state.s, state.w)

class PushSumConvergenceChecker is ConvergenceChecker
  let _epsilon: F64
  let _consecutive_rounds: USize
  var _last_ratio: F64 = 0
  var _unchanged_count: USize = 0

  new create(epsilon: F64, consecutive_rounds: USize) =>
    _epsilon = epsilon
    _consecutive_rounds = consecutive_rounds

  fun ref check_convergence(state: State): Bool =>
    let current_ratio = state.s / state.w
    if (current_ratio - _last_ratio).abs() < _epsilon then
      _unchanged_count = _unchanged_count + 1
    else
      _unchanged_count = 0
    end
    _last_ratio = current_ratio
    _unchanged_count >= _consecutive_rounds

class val PushSumMessage is Message
  let _s: F64
  let _w: F64

  new val create(s: F64, w: F64) =>
    _s = s
    _w = w

  fun get_data(): (String | (F64, F64)) =>
    (_s, _w)