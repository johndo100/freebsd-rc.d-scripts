#!/bin/sh

# PROVIDE: rqbit
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# /usr/local/etc/rc.d/rqbit
# https://github.com/ikatson/rqbit

. /etc/rc.subr

name=rqbit
rcvar=rqbit_enable
desc="a bittorrent client in Rust"
load_rc_config ${name}

: ${rqbit_enable:="NO"}
: ${rqbit_dir:="/usr/local/rqbit"}
: ${rqbit_downloads_dir:="${rqbit_dir}/Downloads"}
: ${rqbit_logfile:="/var/log/rqbit.log"}
: ${rqbit_pidfile:="/var/run/rqbit.pid"}
: ${rqbit_daemon_user:="rqbit"}
rqbit_daemon_group=${rqbit_daemon_group:-$rqbit_daemon_user}
: ${rqbit_chown:=yes}
# rqbit Environment variables
: ${rqbit_log_level:="info"}
: ${rqbit_force_tracker_interval:=""}
: ${rqbit_http_api_listen_addr:="0.0.0.0:3030"}
: ${rqbit_peer_connect_timeout:="2s"}
: ${rqbit_peer_read_write_timeout:="10s"}
: ${rqbit_worker_threads:=""}
: ${rqbit_tcp_listen_min_port:="4240"}
: ${rqbit_tcp_listen_max_port:="4260"}

rqbit_precmd()
{
    # Check if user exist
    if id -u $rqbit_daemon_user > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${rqbit_daemon_user}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${rqbit_dir}" ]; then
        mkdir -p "${rqbit_dir}"
    fi
    # Chown data folder
    if checkyesno rqbit_chown; then
        chown -R "${rqbit_daemon_user}":"${rqbit_daemon_group}" "${rqbit_dir}"
    fi
}

pidfile="${rqbit_pidfile}"
procname="/usr/local/bin/rqbit"
command="/usr/sbin/daemon"
command_args="-o '${rqbit_logfile}' -p '${pidfile}' -u '${rqbit_daemon_user}' -t '${desc}' ${procname} --http-api-listen-addr ${rqbit_http_api_listen_addr} server start ${rqbit_downloads_dir}"
start_precmd="rqbit_precmd"

run_rc_command "$1"