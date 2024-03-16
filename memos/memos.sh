#!/bin/sh

# PROVIDE: memos
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# /usr/local/etc/rc.d/memos
# https://github.com/usememos/memos

. /etc/rc.subr

name="memos"
desc="An open source, lightweight note-taking service"
rcvar="memos_enable"


load_rc_config $name

: ${memos_enable:="NO"}
: ${memos_dir:="/usr/local/memos"}
: ${memos_chdir:="${memos_dir}"}
: ${memos_data_dir:="/var/opt/memos"}
# will change to enviroment variable soon
: ${memos_mode:="prod"}
: ${memos_port:="5230"}
: ${memos_logfile:="/var/log/memos.log"}
: ${memos_pidfile:="/var/run/memos.pid"}
: ${daemon_user:="memos"}
daemon_group=${daemon_group:-$daemon_user}
: ${memos_chown:=yes}


pidfile="${memos_pidfile}"
procname="/usr/local/bin/memos"
command="/usr/sbin/daemon"
command_args="-o '${memos_logfile}' -p '${pidfile}' -u '${daemon_user}' -t '${desc}' ${procname} -m ${memos_mode} -p ${memos_port}"
start_precmd="memos_precmd"

memos_precmd()
{
    # Check if user exist
    if id -u $daemon_user > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${daemon_user}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${memos_dir}" ]; then
        mkdir -p "${memos_dir}"
    fi
    if [ ! -d "${memos_data_dir}" ]; then
        mkdir -p "${memos_data_dir}"
    fi
    # Chown memos folder
    if checkyesno memos_chown; then
        chown -R "${daemon_user}":"${daemon_group}" "${memos_dir}"
        chown -R "${daemon_user}":"${daemon_group}" "${memos_data_dir}"
    fi
}

run_rc_command "$1"