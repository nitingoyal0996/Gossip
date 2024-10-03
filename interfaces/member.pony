use ".."
use "../structs"
use "../utils"

interface Member
  fun ref get_id(): USize
  be add_neighbors(new_neighbors: Array[Member tag] val)
  be start()
  be receive(message: Message val)
  be send()