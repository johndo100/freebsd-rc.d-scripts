#!/bin/sh

# PROVIDE: chihaya
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# /usr/local/etc/rc.d/chihaya
# https://github.com/chihaya/chihaya

. /etc/rc.subr

name=chihaya
rcvar=chihaya_enable
desc="A customizable, multi-protocol BitTorrent Tracker"
load_rc_config ${name}

: ${chihaya_enable:="NO"}
: ${chihaya_dir:="/usr/local/etc/chihaya"}
: ${chihaya_config:="${chihaya_dir}/config.yaml"}
: ${chihaya_logfile:="/var/log/chihaya.log"}
: ${chihaya_pidfile:="/var/run/chihaya.pid"}
: ${chihaya_daemon_user:="chihaya"}
chihaya_daemon_group=${chihaya_daemon_group:-$chihaya_daemon_user}
: ${chihaya_chown:=yes}

chihaya_precmd()
{
    # Check if user exist
    if id -u $chihaya_daemon_user > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${chihaya_daemon_user}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${chihaya_dir}" ]; then
        mkdir -p "${chihaya_dir}"
    fi
    # Chown data folder
    if checkyesno chihaya_chown; then
        chown -R "${chihaya_daemon_user}":"${chihaya_daemon_group}" "${chihaya_dir}"
    fi
}

pidfile="${chihaya_pidfile}"
procname="/usr/local/bin/chihaya"
command="/usr/sbin/daemon"
command_args="-o '${chihaya_logfile}' -p '${pidfile}' -u '${chihaya_daemon_user}' -t '${desc}' ${procname} --config ${chihaya_config}"
start_precmd="chihaya_precmd"

run_rc_command "$1"