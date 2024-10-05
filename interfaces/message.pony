use ".."

interface val Message
  fun get_data(): (F64, F64)
  fun get_gossip_data(): String