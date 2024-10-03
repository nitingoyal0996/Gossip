use ".."
use "../utils"

interface val Topology
  fun apply(members: Array[Member tag], network_logger: NetworkLogger tag)?
