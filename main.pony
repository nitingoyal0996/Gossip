use "collections"
use "random"
use "time"
use @printf[I32](format: Pointer[U8] tag, ...)

actor Main
  let _env: Env
  new create(env: Env) =>
  
    _env = env
    try
      let args = env.args
      if args.size() != 4 then
        env.out.print("Usage: project2 numNodes topology algorithm")
        error
      end

      let numNodes = args(1)?.usize()?
      let topology = args(2)?
      let algorithm = args(3)?

      let actors = Array[Member tag](numNodes)
      let rng = Rand

      // Create actors
      for i in Range(0, numNodes) do
        let neighbors = recover iso Array[Member tag](numNodes - 1) end
        actors.push(Member(i, i.f64(), 1.0, consume neighbors))
      end
      setup_full_topology(actors)?
      // Set up topology
      // match topology
      // | "full" => setup_full_topology(actors)?
      // | "3D" => setup_3d_topology(actors)
      // | "line" => setup_line_topology(actors)?
      // | "imp3D" => setup_imp3d_topology(actors)
      // else
      //   env.out.print("Invalid topology. Use 'full', '3D', 'line', or 'imp3D'.")
      //   error
      // end

      let start_time = Time.nanos()

      // Start the algorithm
      match algorithm
      | "gossip" =>
        let starter = actors(rng.int(numNodes.u64()).usize())?
        starter.start_gossip("Initial rumor", start_time)
      | "push-sum" =>
        let starter = actors(rng.int(numNodes.u64()).usize())?
        starter.start_push_sum(start_time)
      else
        env.out.print("Invalid algorithm. Use 'gossip' or 'push-sum'.")
        error
      end
    else
      env.out.print("An error occurred during initialization.")
    end

  fun format_array(arr: Array[U64] val): String =>
      var result_string: String = "["
      var first: Bool = true
      for value in arr.values() do
          if not first then
              result_string = result_string + ", " // Add comma between elements
          else
              first = false
          end
          result_string = result_string + value.string()
      end
      result_string = result_string + "]" // Close the bracket
      result_string

  fun setup_full_topology(actors: Array[Member tag]) ? =>
    for i in Range(0, actors.size()) do
      for j in Range(0, actors.size()) do
        if i != j then
          actors(i)?.add_neighbor(actors(j)?)
        end
      end
      // log the neighbors ids assigned to actor i for debugging
      // let neighbors = actors(i)?.get_neighbors()
      // _env.out.print("Total Assigned Neighbours: %d".cstring() + neighbors.size().string())
      // var members_string = "["
      // for k in Range(0, neighbors.size()) do
      //   members_string = members_string + neighbors(k)?.id().string()
      //   if k < (neighbors.size() - 1) then
      //     members_string = members_string + ", "
      //   end
      // end
      // _env.out.print("Member %d neighbors: %s".cstring() + i.string() + members_string)
    end
