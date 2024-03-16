#!/bin/sh

# PROVIDE: distribyted
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# /usr/local/etc/rc.d/distribyted
# https://github.com/distribyted/distribyted
# Need to install fusefs-libs
# pkg install fusefs-libs

. /etc/rc.subr

name="distribyted"
desc="Torrent client with on-demand file downloading as a filesystem"
rcvar="distribyted_enable"

load_rc_config $name

: ${distribyted_enable:="NO"}
: ${distribyted_dir:="/usr/local/etc/distribyted/data"}
: ${distribyted_config_file:="${distribyted_dir}/config/config.yaml"}
: ${distribyted_config_folder:="${distribyted_dir}/config"}
: ${distribyted_metadata:="/usr/local/etc/distribyted/data/metadata"}
: ${distribyted_fuse:="/usr/local/etc/distribyted/data/mount"}
: ${distribyted_log:="/usr/local/etc/distribyted/data/logs"}
: ${distribyted_server:="/usr/local/etc/distribyted/data/served-folders/server"}
: ${distribyted_http_port:=4444}
: ${distribyted_webdav_port:=36911}
: ${distribyted_logfile:="/var/log/distribyted.log"}
: ${distribyted_pidfile:="/var/run/distribyted.pid"}
: ${daemon_user:="distribyted"}
daemon_group=${daemon_group:-$daemon_user}
: ${distribyted_chown:=yes}

pidfile="${distribyted_pidfile}"
procname="/usr/local/bin/distribyted"
command="/usr/sbin/daemon"
command_args="-o '${distribyted_logfile}' -p '${pidfile}' -u '${daemon_user}' -t '${desc}' -- ${procname} --config '${distribyted_config_file}' --http-port '${distribyted_http_port}' --webdav-port '${distribyted_webdav_port}'"
start_precmd="distribyted_precmd"

distribyted_precmd()
{
    # Check if user exist
    if id -u $daemon_user > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${daemon_user}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${distribyted_dir}" ]; then
        mkdir -p "${distribyted_dir}"
    fi
    if [ ! -d "${distribyted_config_folder}" ]; then
        mkdir -p "${distribyted_config_folder}"
    fi
    if [ ! -d "${distribyted_metadata}" ]; then
        mkdir -p "${distribyted_metadata}"
    fi
    if [ ! -d "${distribyted_fuse}" ]; then
        mkdir -p "${distribyted_fuse}"
    fi
    if [ ! -d "${distribyted_log}" ]; then
        mkdir -p "${distribyted_log}"
    fi
    if [ ! -d "${distribyted_server}" ]; then
        mkdir -p "${distribyted_server}"
    fi
    # Check if config file exist
    if [ ! -e "${distribyted_config_file}" ]; then
        cp /usr/local/share/distribyted/templates/config_template.yaml "${distribyted_config_file}"
    fi
    # Chown distribyted folder
    if checkyesno distribyted_chown; then
        chown -R "${daemon_user}":"${daemon_group}" "${distribyted_dir}"
    fi
}

run_rc_command "$1"