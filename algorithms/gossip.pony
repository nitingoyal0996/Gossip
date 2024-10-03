use ".."
use "../interfaces"
use "../structs"
use "../utils"

class val GossipAlgorithm is Algorithm
  let _rumor: String

  new val create(rumor: String) =>
    _rumor = rumor

  fun create_convergence_checker(member: Member): ConvergenceChecker ref =>
    GossipConvergenceChecker

  fun start(member: Member) =>
    member.send()

  fun process_message(current_state: GossipState, message: Message val): GossipState =>
    State(current_state.rumor, current_state.count + 1)

  fun prepare_send(current_state: GossipState): (GossipState, Bool) =>
    (current_state, true)

  fun create_message(current_state: GossipState): Message val =>
    GossipMessage(_rumor)

  fun log_receive(logger: Logger tag, id: USize, state: GossipState) =>
    logger.log_gossip(id, "RECEIVE", state.count.usize())

  fun log_send(logger: Logger tag, id: USize, state: GossipState) =>
    // we propagate the rumor and not the count
    logger.log_gossip(id, "SEND", state.rumor.usize())

class GossipConvergenceChecker is ConvergenceChecker
  let _threshold: F64 = 10

  fun ref check_convergence(state: State): Bool =>
    state.count >= _threshold

class val GossipMessage is Message
  let _rumor: String

  new val create(rumor: String) =>
    _rumor = rumor

  fun get_data(): String =>
    _rumor