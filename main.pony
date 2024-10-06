use "files"
use "time"
use "random"
use "collections"
use "utils"
use "topologies"
use "interfaces"
use "structs"

actor Main
  let _env: Env
  var _start_time: U64 = 0
  var _num_nodes: USize = 0
  var _converged_count: USize = 0
  var _logger: Logger tag
  var _network_logger: NetworkLogger tag
  var _logging_enabled: Bool = false

  new create(env: Env) =>
    _env = env
    _logger = Logger(env, "logs/default_log.csv", false)
    _network_logger = NetworkLogger(env, "logs/default_network_log.csv", false)

    try
      let args = env.args
      if (args.size() < 4) or (args.size() > 5) then
        _env.out.print("Usage: project2 numNodes topology algorithm [logging]")
        error
      end
      _num_nodes = args(1)?.usize()?
      let topology = args(2)?
      let algorithm = args(3)?
      _logging_enabled = if args.size() == 5 then args(4)? == "on" else false end

      let timestamp = Time.millis().string()
      let prefix = "logs/" + _num_nodes.string() + "_" + topology + "_" + algorithm + "_" + consume timestamp

      _logger = Logger(env, prefix + "_log.csv", _logging_enabled)
      _network_logger = NetworkLogger(env, prefix + "_network_log.csv", _logging_enabled)

      let members = create_members(algorithm)

      let network = match topology
      | "full" => FullTopology(members, _network_logger)?
      | "3D" => ThreeDTopology(members, _network_logger)?
      | "line" => LineTopology(members, _network_logger)?
      | "imp3D" => Imp3DTopology(members, _network_logger)?
      else
        _env.out.print("Invalid topology")
        error
      end

      _start_time = Time.millis()
      // choose random member to start
      // _env.out.print("Choosing random member to start")
      let rand = Rand(Time.nanos().u64())
      let real_fraction = rand.real() // Fraction in [0, 1)
      // Scale and pick an index using a more precise calculation
      let scaled_fraction = real_fraction * (members.size().f64()*1000.0)
      let index = (scaled_fraction % members.size().f64()).usize()
      
      let random_member = members(index)?
      // _env.out.print("Random member @ index: " + index.string() + " starting now")
      random_member.start()
    else
      _env.out.print("Error initializing the simulation")
    end

  fun ref create_members(algorithm: String): Array[Member tag] =>
    let members = Array[Member tag]
    
    match algorithm
    | "gossip" =>
      for i in Range(0, _num_nodes) do
        let initial_state = GossipState("rumor", 0)
        let member = GossipMember(i, initial_state, recover Array[Member tag] end, _env, this, _logger, _network_logger)
        members.push(member)
      end
    | "push-sum" =>
      for i in Range(0, _num_nodes) do
        let initial_state = State(i.f64(), 1.0)
        let member = PushSumMember(i, initial_state, recover Array[Member tag] end, _env, this, _logger, _network_logger)
        members.push(member)
      end
    else
      _env.out.print("Invalid algorithm")
    end
    members

  be report_convergence() =>
    let convergence_time = Time.millis() - _start_time
    _env.out.print("Convergence time: " + convergence_time.string() + " ms")
    _logger.close()
    _network_logger.close()
    // Remove default log files
    let auth = FileAuth(_env.root)
    let default_log = FilePath(auth, "logs/default_log.csv")
    let default_network_log = FilePath(auth, "logs/default_network_log.csv")

    if default_log.exists() then
      if not default_log.remove() then
        _env.out.print("Error removing default log file")
      end
    end

    if default_network_log.exists() then
      if not default_network_log.remove() then
        _env.out.print("Error removing default network log file")
      end
    end
    _env.exitcode(0)
    _env.out.print("Simulation complete. Exiting...")