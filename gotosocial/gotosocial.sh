#!/bin/sh

# PROVIDE: gotosocial
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# /usr/local/etc/rc.d/gotosocial
# https://github.com/superseriousbusiness/gotosocial

. /etc/rc.subr

name="gotosocial"
desc="Fast, fun, small ActivityPub server"
rcvar="gotosocial_enable"


load_rc_config $name

: ${gotosocial_enable:="NO"}
: ${gotosocial_dir:="/usr/local/gotosocial"}
: ${gotosocial_certs_dir:="${gotosocial_dir}/storage/certs"}
: ${gotosocial_config_file:="${gotosocial_dir}/config.yaml"}
: ${gotosocial_logfile:="/var/log/gotosocial.log"}
: ${gotosocial_pidfile:="/var/run/gotosocial.pid"}
: ${gotosocial_daemon_user:="gotosocial"}
gotosocial_daemon_group=${gotosocial_daemon_group:-$gotosocial_daemon_user}
: ${gotosocial_chown:=yes}


pidfile="${gotosocial_pidfile}"
procname="/usr/local/bin/gotosocial"
command="/usr/sbin/daemon"
command_args="-o '${gotosocial_logfile}' -p '${pidfile}' -u '${gotosocial_daemon_user}' -t '${desc}' -- ${procname} --config-path ${gotosocial_config_file} server start"
start_precmd="gotosocial_precmd"

gotosocial_precmd()
{
    # Check if user exist
    if id -u $gotosocial_daemon_user > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${gotosocial_daemon_user}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${gotosocial_dir}" ]; then
        mkdir -p "${gotosocial_dir}"
    fi
    if [ ! -d "${gotosocial_certs_dir}" ]; then
        mkdir -p "${gotosocial_certs_dir}"
    fi
    # Check if config file exist
    if [ ! -e "${gotosocial_config_file}" ]; then
        cp /usr/local/share/gotosocial/example/config.yaml "${gotosocial_config_file}"
    fi
    # Chown gotosocial folder
    if checkyesno gotosocial_chown; then
        chown -R "${gotosocial_daemon_user}":"${gotosocial_daemon_group}" "${gotosocial_dir}"
    fi
}

run_rc_command "$1"