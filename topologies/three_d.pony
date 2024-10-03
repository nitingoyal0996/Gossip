use ".."
use "collections"
use "../interfaces"
use "../utils"
use "math"

primitive ThreeDTopology is Topology
  fun apply(members: Array[Member tag], network_logger: NetworkLogger)? =>
    let num_nodes = members.size()
    let grid_size = (num_nodes.f64().pow(1.0/3)).ceil().usize()

    network_logger.log_message("Creating 3D topology with " + num_nodes.string() + " nodes and grid size " + grid_size.string())

    for i in Range(0, num_nodes) do
      let z = i / (grid_size * grid_size)
      let y = (i / grid_size) % grid_size
      let x = i % grid_size

      let neighbors = get_neighbors(x, y, z, grid_size, num_nodes)
      let neighbor_members = recover trn Array[Member tag] end
      let neighbor_ids = recover trn Array[USize] end

      for neighbor in neighbors.values() do
        let neighbor_id = ((neighbor._1) + ((neighbor._2) * grid_size) + ((neighbor._3) * (grid_size * grid_size)))
        if neighbor_id < num_nodes then
          neighbor_members.push(members(neighbor_id)?)
          neighbor_ids.push(neighbor_id)
        end
      end

      members(i)?.add_neighbors(consume neighbor_members)
      network_logger.log_message("Node " + i.string() + " has " + neighbor_ids.size().string() + " neighbors")
      network_logger.log_neighbors(i, consume neighbor_ids)
    end

  fun get_neighbors(x: USize, y: USize, z: USize, grid_size: USize, num_nodes: USize): Array[(USize, USize, USize)] =>
    let neighbors = Array[(USize, USize, USize)]

    // Check for neighbors in the x direction
    if x > 0 then
      neighbors.push((x-1, y, z))  // left neighbor
    end
    if x < (grid_size - 1) then
      neighbors.push((x+1, y, z))  // right neighbor
    end

    // Check for neighbors in the y direction
    if y > 0 then
      neighbors.push((x, y-1, z))  // down neighbor
    end
    if y < (grid_size - 1) then
      neighbors.push((x, y+1, z))  // up neighbor
    end

    // Check for neighbors in the z direction
    if z > 0 then
      neighbors.push((x, y, z-1))  // back neighbor
    end
    if z < (grid_size - 1) then
      neighbors.push((x, y, z+1))  // front neighbor
    end

    neighbors