use ".."
use "../structs"

interface ref ConvergenceChecker
  fun ref check_convergence(state: State): Bool
