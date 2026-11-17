#!/system/bin/sh

MODULE_ID="ghxnb"
MODULE_AUTHOR="加Q群:1058272764"

LOG_FILE="/data/local/tmp/gamedrive_x.log"
STATE_FILE="/data/local/tmp/.gamedrive_x_state"

MIN_HZ="60.0"
MAX_HZ="120.0"
TOUCH_TIMEOUT=1000

SDK="$(getprop ro.build.version.sdk)"
ANDROID="$(getprop ro.build.version.release)"

log() {
    TS="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "$TS [GAMEDRIVE] $*"
    echo "$TS [GAMEDRIVE] $*" >> "$LOG_FILE" 2>/dev/null
}

notify() {
    cmd notification post -S bigtext -t "$MODULE_NAME" "Tag" "$1" >/dev/null 2>&1
}

set_60hz() {
    settings put system min_refresh_rate  "$MIN_HZ" >/dev/null 2>&1
    settings put system peak_refresh_rate "$MIN_HZ" >/dev/null 2>&1
    log "已切换到 60Hz"
}

set_120hz() {
    settings put system min_refresh_rate  "$MAX_HZ" >/dev/null 2>&1
    settings put system peak_refresh_rate "$MAX_HZ" >/dev/null 2>&1
    log "已切换到 120Hz"
}

render_tuning() {
    log "正在应用渲染 / GPU / CPU 调优..."
    settings put global gfx.disable_frame_pacing 1 >/dev/null 2>&1
    settings put global gfx.swapinterval 0        >/dev/null 2>&1
    cmd device_config put activity_manager max_cached_processes 16 >/dev/null 2>&1
    cmd device_config put activity_manager use_freezer true       >/dev/null 2>&1
    settings put system refresh_rate_policy adaptive              >/dev/null 2>&1
    settings put system refresh_rate_mode 0                       >/dev/null 2>&1
    settings put system display_refresh_rate_mode 0               >/dev/null 2>&1
    settings put system peak_refresh_rate 120                     >/dev/null 2>&1
    settings put system min_refresh_rate 60                       >/dev/null 2>&1
    settings put system enable_optimize_refresh_rate false        >/dev/null 2>&1
    settings put system lockscreen_limit_refresh_rate 0           >/dev/null 2>&1
    settings put system per_app_refresh_rate "com.mobile.legends:120,com.tencent.ig:120" >/dev/null 2>&1
    settings put global thermal_event_log 0                       >/dev/null 2>&1
    settings put global debug.sf.hw 1                             >/dev/null 2>&1
    settings put global debug.sf.vsync_reactor 0                  >/dev/null 2>&1
    settings put global debug.sf.use_buffer_age false             >/dev/null 2>&1
    settings put global debug.sf.late.sf.duration 0               >/dev/null 2>&1
    settings put global debug.sf.early.sf.duration 0              >/dev/null 2>&1
    settings put global force_peak_refresh_rate 0                 >/dev/null 2>&1
    settings put global peak_refresh_rate 0                       >/dev/null 2>&1
    settings put global min_refresh_rate 60                       >/dev/null 2>&1
    settings put global game.dynamic_fps 1                        >/dev/null 2>&1
    settings put global game.dynamic_fps_mode 2                   >/dev/null 2>&1
    settings put global game.min_fps 60                           >/dev/null 2>&1
    settings put global game.max_fps 240                          >/dev/null 2>&1
    settings put global game.performance_level 3                  >/dev/null 2>&1
    settings put global gpu.performance.tuning 1                  >/dev/null 2>&1
    settings put global gpu.frame_pacing 0                        >/dev/null 2>&1
    settings put global scheduler.boost 1                         >/dev/null 2>&1
    settings put global cpu_max_freq.boost 1                      >/dev/null 2>&1
    settings put global thermal_limit.cpu 0                       >/dev/null 2>&1
    settings put global thermal_limit.gpu 0                       >/dev/null 2>&1
    settings put system touch.pressure.scale 0.1                  >/dev/null 2>&1
    settings put system touch.size.scale 0.1                      >/dev/null 2>&1
    settings put global touch.resample 0                          >/dev/null 2>&1
    settings put global device_idle_constants inactive_to 0       >/dev/null 2>&1
    log "渲染调优已应用。"
}

log "动态 FPS 服务启动中..."

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 1
done
sleep 5

render_tuning

EVENTS=""
for DEV in /dev/input/event*; do
    [ -e "$DEV" ] || continue
    INFO="$(getevent -lp "$DEV" 2>/dev/null)"
    case "$INFO" in
        *ABS_MT_POSITION_X*|*BTN_TOUCH*)
            EVENTS="$EVENTS $DEV"
            log "发现触摸设备: $DEV"
            ;;
    esac
done

if [ -z "$EVENTS" ]; then
    log "错误：未找到触摸屏事件设备（需要 root 权限）"
    exit 1
fi

set_60hz
echo "IDLE:0" > "$STATE_FILE"

(
    getevent -lt $EVENTS 2>/dev/null | while IFS= read -r LINE; do
        case "$LINE" in
            *BTN_TOUCH*DOWN*)
                CUR="$(cat "$STATE_FILE" 2>/dev/null)"
                case "$CUR" in
                    TOUCH:*) ;;
                    *)
                        set_120hz
                        echo "TOUCH:$(date +%s%3N)" > "$STATE_FILE"
                        ;;
                esac
                ;;
            *BTN_TOUCH*UP*)
                echo "RELEASE:$(date +%s%3N)" > "$STATE_FILE"
                ;;
        esac
    done
) &

while true; do
    STATE="$(cat "$STATE_FILE" 2>/dev/null)"
    case "$STATE" in
        TOUCH:*|RELEASE:*)
            TS="${STATE#*:}"
            NOW="$(date +%s%3N)"
            if [ $((NOW - TS)) -ge "$TOUCH_TIMEOUT" ]; then
                set_60hz
                echo "IDLE:0" > "$STATE_FILE"
            fi
            ;;
    esac
    sleep 0.2
done