use "time"
use "files"

// logs the message activity of network in a csv file
actor Logger
    let file: File
    let _env: Env
    let _logging_enabled: Bool

    new create(env: Env, filename: String, logging_enabled: Bool) =>
        _env = env
        _logging_enabled = logging_enabled
        let path = FilePath(FileAuth(env.root), filename)
        file = File(path)
        if not file.valid() then
            _env.out.print("Error opening log file")
        else
            // Write CSV header
            file.write("Timestamp,NodeID,Action,S,W,Ratio\n")
        end

    be log(node_id: USize, action: String, s: F64, w: F64, ratio: F64) =>
        if _logging_enabled then
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
            match file
            | let f: File => f.write(consume log_entry)
            end
        end

    be log_gossip(node_id: USize, action: String, rumor: String, count: USize) =>
        if _logging_enabled then
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
                            .> append("N/A")
                            .> append("\n")
            end
            match file
            | let f: File => f.write(consume log_entry)
            end
        end

    be close() =>
        file.dispose()

