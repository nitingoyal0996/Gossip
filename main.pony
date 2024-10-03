use "time"
use "random"
use "collections"
use "utils"
use "topologies"
use "algorithms"
use "interfaces"
use "structs"

actor Main
  let _env: Env
  var _start_time: U64 = 0
  var _num_nodes: USize = 0
  var _converged_count: USize = 0
  let _logger: Logger tag
  let _network_logger: NetworkLogger tag

  new create(env: Env) =>
    _env = env
    _logger = Logger(env, "project2_log.csv")
    _network_logger = NetworkLogger(env, "project2_network_log.csv")
    
    try
      let args = env.args
      if args.size() != 4 then
        _env.out.print("Usage: project2 numNodes topology algorithm")
        return
      end

      _num_nodes = args(1)?.usize()?
      let topology = args(2)?
      let algorithm = args(3)?

      let members = create_members(algorithm)
      
      let network = match topology
      | "full" => FullTopology(members, _network_logger)?
      | "3D" => ThreeDTopology(members, _network_logger)?
      | "line" => LineTopology(members, _network_logger)?
      | "imp3D" => Imp3DTopology(members, _network_logger)?
      else
        _env.out.print("Invalid topology")
        return
      end

      _start_time = Time.millis()

      for member in members.values() do
        member.start()
      end
    else
      _env.out.print("Error parsing arguments")
    end

  fun ref create_members(algorithm: String): Array[Member tag] =>
    let members = Array[Member tag]
    
    match algorithm
    | "gossip" =>
      let gossip_algo = GossipAlgorithm("rumor")
      for i in Range(0, _num_nodes) do
        let initial_state = GossipState("", 0)
        let member = GossipMember(i, initial_state, recover Array[Member tag] end, 10, _env, this, _logger, _network_logger)
        members.push(member)
      end
    | "push-sum" =>
      let push_sum_algo = PushSumAlgorithm
      for i in Range(0, _num_nodes) do
        let initial_state = State(i.f64(), 1.0)
        let member = PushSumMember(i, initial_state, recover Array[Member tag] end, _env, this, _logger, _network_logger, 1e-10)
        members.push(member)
      end
    else
      _env.out.print("Invalid algorithm")
    end
    members

  be report_convergence() =>
    _converged_count = _converged_count + 1
    if _converged_count == _num_nodes then
      let convergence_time = Time.millis() - _start_time
      _env.out.print("Convergence time: " + convergence_time.string() + " ms")
      _logger.close()
      _network_logger.close()
    end