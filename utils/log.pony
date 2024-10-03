use "time"
use "files"

// create a logging actor that manages the time based logging of messages from multiple actors into a single file

actor Logger
    let file: File
    let _env: Env

    new create(env: Env, filename: String) =>
        _env = env
        let path = FilePath(FileAuth(env.root), filename)
        file = File(path)
        if not file.valid() then
            _env.out.print("Error opening log file")
        else
            // Write CSV header
            file.write("Timestamp,NodeID,Action,S,W,Ratio\n")
        end

    be log(node_id: USize, action: String, s: F64, w: F64, ratio: F64) =>
        let timestamp = Time.millis()
        let log_entry = recover val
            String(256) .> append(timestamp.string())
                        .> append(",")
                        .> append(node_id.string())
                        .> append(",")
                        .> append(action)
                        .> append(",")
                        .> append(s.string())
                        .> append(",")
                        .> append(w.string())
                        .> append(",")
                        .> append(ratio.string())
                        .> append("\n")
        end
        file.write(consume log_entry)

    be log_gossip(node_id: USize, action: String, rumor: String, count: USize) =>
        let timestamp = Time.millis()
        let log_entry = recover val
            String(256) .> append(timestamp.string())
                        .> append(",")
                        .> append(node_id.string())
                        .> append(",")
                        .> append(action)
                        .> append(",")
                        .> append(rumor)
                        .> append(",")
                        .> append(count.string())
                        .> append(",")
                        .> append("N/A")  // We use "N/A" for the 'w' column in Gossip
                        .> append("\n")
        end
        file.write(consume log_entry)

    be close() =>
        file.dispose()

