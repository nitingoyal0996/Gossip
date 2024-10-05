use ".."
use "collections"   
use "../interfaces"
use "../utils"
use "math"
use "random"
use "time"

primitive Imp3DTopology is Topology
  fun apply(members: Array[Member tag], network_logger: NetworkLogger)? =>
    let num_nodes = members.size()
    let size = (num_nodes.f64().pow(1.0/3)).ceil().usize()
    
    network_logger.log_message("Creating Imperfect 3D topology with " + num_nodes.string() + " nodes and grid size " + size.string())

    for i in Range(0, num_nodes) do
      // network_logger.log_message("Processing node " + i.string())
      let neighbor_ids = recover trn Array[USize] end
      let neighbors = recover trn Array[Member tag] end
      let x = i % size
      let y = (i / size) % size
      let z = i / (size * size)
      
      // Add grid neighbors (up to 6)
      try
        if (x > 0) and ((i-1) < num_nodes) then
          neighbors.push(members(i-1)?)
          neighbor_ids.push(i-1)
        end
        if (x < (size - 1)) and ((i+1) < num_nodes) then
          neighbors.push(members(i+1)?)
          neighbor_ids.push(i+1)
        end
        if (y > 0) and ((i-size) >= 0) and ((i-size) < num_nodes) then
          neighbors.push(members(i-size)?)
          neighbor_ids.push(i-size)
        end
        if (y < (size - 1)) and ((i+size) < num_nodes) then
          neighbors.push(members(i+size)?)
          neighbor_ids.push(i+size)
        end
        if (z > 0) and ((i-(size*size)) >= 0) and ((i-(size*size)) < num_nodes) then
          neighbors.push(members(i-(size*size))?)
          neighbor_ids.push(i-(size*size))
        end
        if (z < (size - 1)) and ((i+(size*size)) < num_nodes) then
          neighbors.push(members(i+(size*size))?)
          neighbor_ids.push(i+(size*size))
        end
      else
        network_logger.log_message("Error adding grid neighbors for node " + i.string())
        error
      end
      
      // Add one random neighbor
      try
        var attempts: USize = 0
        while (attempts < num_nodes) do
          let rand = Rand(Time.nanos().u64())
          let real_fraction = rand.real()
          let scaled_fraction = real_fraction * (members.size().f64() * 1000.0)
          let random_neighbor = (scaled_fraction.usize() % num_nodes)
          
          // network_logger.log_message("Attempting to add random neighbor " + random_neighbor.string() + " to node " + i.string())
          if (random_neighbor != i) and (not neighbor_ids.contains(random_neighbor)) then
            try
              neighbors.push(members(random_neighbor)?)
              neighbor_ids.push(random_neighbor)
              // network_logger.log_message("Successfully added random neighbor " + random_neighbor.string() + " to node " + i.string())
              break
            else
              network_logger.log_message("Error accessing member at index " + random_neighbor.string() + " for node " + i.string())
              error
            end
          end
          attempts = attempts + 1
        end
        if attempts >= num_nodes then
          network_logger.log_message("Could not add random neighbor for node " + i.string() + " after " + attempts.string() + " attempts")
        end
      else
        network_logger.log_message("Error in random number generation for node " + i.string())
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