use ".."
use "collections"
use "../interfaces"
use "../utils"

primitive FullTopology is Topology
  fun apply(members: Array[Member tag], network_logger: NetworkLogger tag)? =>
    network_logger.log_message("Creating Full topology with " + members.size().string() + " nodes")

    for i in Range(0, members.size()) do
      let neighbors_members = recover trn Array[Member tag] end
      let neighbors_ids = recover trn Array[USize] end
      
      for j in Range(0, members.size()) do
        if i != j then
          neighbors_members.push(members(j)?)
          neighbors_ids.push(j)
        end
      end

      members(i)?.add_neighbors(consume neighbors_members)
      // network_logger.log_message("Node " + i.string() + " has " + neighbors_ids.size().string() + " neighbors")
      network_logger.log_neighbors(i, consume neighbors_ids)
    end

    network_logger.log_message("Full topology creation complete")
    network_logger.log_message("Topology creation complete")