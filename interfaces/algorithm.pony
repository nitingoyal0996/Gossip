use ".."
use "../structs"
use "../utils"

interface val Algorithm
  fun create_convergence_checker(member: Member): ConvergenceChecker ref
  fun start(member: Member)
  fun process_message(current_state: State, message: Message val): State
  fun prepare_send(current_state: State): (State, Bool)
  fun create_message(current_state: State): Message val
  fun log_receive(logger: Logger tag, id: USize, state: State)
  fun log_send(logger: Logger tag, id: USize, state: State)
