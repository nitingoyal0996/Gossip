use ".."
use "collections"
use "../interfaces"
use "../utils"

primitive LineTopology is Topology
  fun apply(members: Array[Member tag], network_logger: NetworkLogger tag)? =>
    network_logger.log_message("Creating Line topology with " + members.size().string() + " nodes")

    for i in Range(0, members.size()) do
      let neighbors = recover trn Array[Member tag] end
      let neighbors_ids = recover trn Array[USize] end
      
      if i > 0 then
        neighbors.push(members(i-1)?)
        neighbors_ids.push(i-1)
      end
      
      if i < (members.size() - 1) then
        neighbors.push(members(i+1)?)
        neighbors_ids.push(i+1)
      end

      members(i)?.add_neighbors(consume neighbors)
      // network_logger.log_message("Node " + i.string() + " has " + neighbors_ids.size().string() + " neighbors")
      network_logger.log_neighbors(i, consume neighbors_ids)
    end

    network_logger.log_message("Line topology creation complete")
    network_logger.log_message("Topology creation complete")