#!/bin/sh

# PROVIDE: listmonk
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# /usr/local/etc/rc.d/listmonk
# https://github.com/knadh/listmonk

. /etc/rc.subr

name="listmonk"
desc="Standalone, self-hosted, newsletter and mailing list manager"
rcvar="listmonk_enable"


load_rc_config $name

: ${listmonk_enable:="NO"}
: ${listmonk_dir:="/usr/local/etc/listmonk"}
: ${listmonk_config_file:="${listmonk_dir}/config.toml"}
: ${listmonk_static_dir:="${listmonk_dir}/static"}
: ${listmonk_logfile:="/var/log/listmonk.log"}
: ${listmonk_pidfile:="/var/run/listmonk.pid"}
: ${listmonk_username:="listmonk"}
listmonk_group=${listmonk_group:-$listmonk_user}


pidfile="${listmonk_pidfile}"
procname="/usr/local/bin/listmonk"
command="/usr/sbin/daemon"
command_args="-o '${listmonk_logfile}' -p '${pidfile}' -u '${listmonk_username}' -t '${desc}' -- ${procname} --config ${listmonk_config_file} --static-dir ${listmonk_static_dir}"
start_precmd="listmonk_precmd"

listmonk_precmd()
{
    # Check if user exist
    if id -u $listmonk_username > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${listmonk_username}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${listmonk_dir}" ]; then
        mkdir -p "${listmonk_dir}"
    fi
    if [ ! -d "${listmonk_static_dir}" ]; then
        mkdir -p "${listmonk_static_dir}"
    fi
    # Check if config file exist
    if [ ! -e "${listmonk_config_file}" ]; then
        ( cd ${listmonk_dir} ; ${procname} --new-config )
    fi
    # Chown listmonk folder
    if checkyesno listmonk_chown; then
        chown "${listmonk_username}":"${listmonk_group}" "${listmonk_dir}"
    fi
}

run_rc_command "$1"