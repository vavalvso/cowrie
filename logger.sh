pkill -f "docker logs"

echo "Starting the logger"

docker logs -f honeypot_cowrie 2>&1 | sed -u "s/b''//g; s/'//g; s/\"//g" | awk -W interactive '
function get_target() {
    tgt = "UNKNOWN"
    if (match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[: ,][0-9]+/)) {
        tgt = substr($0, RSTART, RLENGTH)
        gsub(/,/, ":", tgt); gsub(/ /, ":", tgt)
    } else if (match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)) {
        tgt = substr($0, RSTART, RLENGTH)
    }

    if (tgt != "UNKNOWN" && tgt !~ /:[0-9]+$/) {
        if (match($0, /port [0-9]+/)) {
            p = substr($0, RSTART+5, RLENGTH-5)
            tgt = tgt ":" p
        }
    }
    return tgt
}

/login attempt|public key/ {
    target = get_target()
    out = ""

    if ($0 ~ /public key/) {
        user = "unknown"
        for(i=1; i<=NF; i++) {
            if($i == "user" || $i == "for") user = $(i+1)
        }
        out = "From: " target " | --> [SSH-KEY for: " user "]"
    } else if (match($0, /\[([^\]]+)\/([^\]]*)\]/)) {
        data = substr($0, RSTART+1, RLENGTH-2)
        split(data, pair, "/")
        out = "From: " target " | --> Login: [" pair[1] "]  Password: [" pair[2] "]"
    }

    if (out != "" && !seen_login[out]++) {
        print out >> "/root/cyber_node/all_logins.txt"
        fflush("/root/cyber_node/all_logins.txt")
    }
}

/CMD:/ {
    target = get_target()
    idx = index($0, "CMD:")
    if (idx > 0) {
        cmd = substr($0, idx + 5)
        out_file = "From: " target " | Typed: " cmd

        if (!seen_cmd[out_file]++) {
            print out_file >> "/root/cyber_node/all_commands.txt"
            fflush("/root/cyber_node/all_commands.txt")
        }
    }
} ' &
