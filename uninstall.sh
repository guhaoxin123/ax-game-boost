#!/system/bin/sh

MODULE_ID="ghxnb"
MODULE_AUTHOR="加Q群:1058272764"
LOG_FILE="/data/local/tmp/RUN.log"
STATE_FILE="/data/local/tmp/.RUN_state"

SDK="$(getprop ro.build.version.sdk)"
ANDROID="$(getprop ro.build.version.release)"

log() {
    TS="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "$TS [游戏优化] $*"
    echo "$TS [游戏优化] $*" >> "$LOG_FILE" 2>/dev/null
}

notify() {
    cmd notification post -S bigtext -t "ghxnb" "Tag" "$1" >/dev/null 2>&1
}

banner() {
    echo "========================================"
    echo "         游戏优化"
    echo "         $1"
    echo "========================================"
}

remove_driver() {
    echo ""
    echo "========== 移除 游戏优化 =========="
    echo "[移除] game_driver_opt_in_apps"
    settings delete global game_driver_opt_in_apps >/dev/null 2>&1
    echo "[移除] game_driver_opt_out_apps"
    settings delete global game_driver_opt_out_apps >/dev/null 2>&1
    if [ "$SDK" -ge 31 ]; then
        echo "[移除] updatable_driver_production_opt_in_apps"
        settings delete global updatable_driver_production_opt_in_apps >/dev/null 2>&1
        echo "[移除] updatable_driver_production_opt_out_apps"
        settings delete global updatable_driver_production_opt_out_apps >/dev/null 2>&1
    fi
    echo ""
    echo "========== 验证 =========="
    echo "[GAME DRIVER OPT-IN]"
    settings get global game_driver_opt_in_apps
    echo ""
    echo "[GAME DRIVER OPT-OUT]"
    settings get global game_driver_opt_out_apps
    if [ "$SDK" -ge 31 ]; then
        echo ""
        echo "[UPDATABLE DRIVER OPT-IN]"
        settings get global updatable_driver_production_opt_in_apps
        echo ""
        echo "[UPDATABLE DRIVER OPT-OUT]"
        settings get global updatable_driver_production_opt_out_apps
    fi
}

banner "卸载 / 恢复"
log "Android : $ANDROID"
log "SDK     : $SDK"

remove_driver
rm -f "$STATE_FILE" 2>/dev/null

echo ""
echo "========================================"
echo " 游戏优化 卸载完成"
echo " Android : $ANDROID"
echo " SDK     : $SDK"
echo "========================================"
echo "[信息] Game Driver 偏好已重置。"
echo "[信息] Android 现在可以使用默认配置。"
echo "baybay"
notify "已恢复默认 - 请检查开发者选项"