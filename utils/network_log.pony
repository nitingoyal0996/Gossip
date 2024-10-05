use "time"
use "files"
use ".."
use "../interfaces"
use "collections"

actor NetworkLogger
  let file: File
  let _env: Env
  let _logging_enabled: Bool

  new create(env: Env, filename: String, logging_enabled: Bool) =>
    _env = env
    _logging_enabled = logging_enabled
    let path = FilePath(FileAuth(env.root), filename)
    file = File(path)
    if not file.valid() then
      _env.out.print("Error opening network log file")
    else
      // Write CSV header
      file.write("Timestamp,NodeID,Neighbors\n")
    end

  be log_neighbors(i: USize, neighbors_ids: Array[USize] val) =>
    if _logging_enabled then
      let timestamp = Time.millis()
      let neighbor_ids = _join_neighbors(neighbors_ids)
      let log_entry = recover val
        String(256) .> append(timestamp.string())
                    .> append(",")
                    .> append(i.string())
                    .> append(",")
                    .> append("[")
                    .> append(neighbor_ids)
                    .> append("]")
                    .> append("\n")
      end
      match file
      | let f: File => f.write(log_entry)
      end
    end

  fun _join_neighbors(neighbors: Array[USize] val): String =>
    let result = recover trn String(neighbors.size() * 4) end
    for (i, neighbor) in neighbors.pairs() do
      if i > 0 then
        result.append(",")
      end
      result.append(neighbor.string())
    end
    consume result

  be close() =>
    file.dispose()

  be log_message(message: String) =>
    if _logging_enabled then
      let timestamp = Time.millis()
      match file
      | let f: File => f.print(timestamp.string() + "," + message + "\n")
      end
    end