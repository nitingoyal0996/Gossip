use ".."
use "collections"   
use "../interfaces"
use "../utils"
use "math"

primitive Imp3DTopology is Topology
  fun apply(members: Array[Member tag], network_logger: NetworkLogger)? =>
    let num_nodes = members.size()
    let size = (num_nodes.f64().pow(1.0/3)).ceil().usize()
    
    network_logger.log_message("Creating Imperfect 3D topology with " + num_nodes.string() + " nodes and grid size " + size.string())

    for i in Range(0, num_nodes) do
      network_logger.log_message("Processing node " + i.string())
      let neighbor_ids = recover trn Array[USize] end
      let neighbors = recover trn Array[Member tag] end
      let x = i % size
      let y = (i / size) % size
      let z = i / (size * size)
      
      // Add neighbors
      try
        if (x > 0) and ((i-1) < num_nodes) then
          neighbors.push(members(i-1)?)
          neighbor_ids.push(i-1)
        end
        if (x < (size - 1)) and ((i+1) < num_nodes) then
          neighbors.push(members(i+1)?)
          neighbor_ids.push(i+1)
        end
        if (y > 0) and ((i-size) < num_nodes) then
          neighbors.push(members(i-size)?)
          neighbor_ids.push(i-size)
        end
        if (y < (size - 1)) and ((i+size) < num_nodes) then
          neighbors.push(members(i+size)?)
          neighbor_ids.push(i+size)
        end
        if (z > 0) and ((i-(size*size)) < num_nodes) then
          neighbors.push(members(i-(size*size))?)
          neighbor_ids.push(i-(size*size))
        end
        if (z < (size - 1)) and ((i+(size*size)) < num_nodes) then
          neighbors.push(members(i+(size*size))?)
          neighbor_ids.push(i+(size*size))
        end
      else
        network_logger.log_message("Error adding regular neighbors for node " + i.string())
        error
      end
      
      // Add one random neighbor
      try
        let random = RandomUtils.create()
        var attempts: USize = 0
        while (neighbors.size() < 7) and (attempts < 10) do
          let random_neighbor = random.get_random_number_in_range(0, num_nodes)
          if (random_neighbor != i) and (not neighbor_ids.contains(random_neighbor)) then
            neighbors.push(members(random_neighbor)?)
            neighbor_ids.push(random_neighbor)
          end
          attempts = attempts + 1
        end
      else
        network_logger.log_message("Error adding random neighbor for node " + i.string())
        error
      end
      
      try
        members(i)?.add_neighbors(consume neighbors)
        network_logger.log_neighbors(i, consume neighbor_ids)
      else
        network_logger.log_message("Error adding neighbors to node " + i.string())
        error
      end
    end

    network_logger.log_message("Imperfect 3D topology creation finished")