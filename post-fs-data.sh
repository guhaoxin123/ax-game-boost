#!/system/bin/sh

LOG_FILE="/data/local/tmp/gamedrive_x.log"

log() {
    TS="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "$TS [GAMEDRIVE] $*"
    echo "$TS [GAMEDRIVE] $*" >> "$LOG_FILE" 2>/dev/null
}

SDK="$(getprop ro.build.version.sdk)"
log "post-fs-data 已触发（SDK=$SDK）"