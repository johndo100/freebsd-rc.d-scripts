#!/bin/sh

# PROVIDE: privtracker
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# /usr/local/etc/rc.d/privtracker
# https://github.com/meehow/privtracker

. /etc/rc.subr

name=privtracker
rcvar=privtracker_enable
desc="Private BitTorrent tracker for everyone"
load_rc_config ${name}

: ${privtracker_enable:="NO"}
: ${privtracker_dir:="/usr/local/privtracker"}
: ${privtracker_logfile:="/var/log/privtracker.log"}
: ${privtracker_pidfile:="/var/run/privtracker.pid"}
: ${privtracker_daemon_user:="privtracker"}
privtracker_daemon_group=${privtracker_daemon_group:-$privtracker_daemon_user}
: ${privtracker_chown:=yes}
# privtracker Environment variables
: ${privtracker_port:="1337"}
: ${privtracker_domain:=""}


export_variable()
{
	_var="privtracker_$(echo $1 | tr A-Z a-z)"
	eval _val="\$${_var}"
	[ -z "${_val}" ] || export "${1}"="${_val}"
}

export_variables()
{
	for _v in $@; do
		export_variable "${_v}"
	done
}

privtracker_precmd()
{
    # Check if user exist
    if id -u $privtracker_daemon_user > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${privtracker_daemon_user}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${privtracker_dir}" ]; then
        mkdir -p "${privtracker_dir}"
    fi
    # Chown data folder
    if checkyesno privtracker_chown; then
        chown -R "${privtracker_daemon_user}":"${privtracker_daemon_group}" "${privtracker_dir}"
    fi
    # Export variables
	export_variables PORT DOMAIN
}

pidfile="${privtracker_pidfile}"
procname="/usr/local/bin/privtracker"
command="/usr/sbin/daemon"
command_args="-o '${privtracker_logfile}' -p '${pidfile}' -u '${privtracker_daemon_user}' -t '${desc}' ${procname}"
start_precmd="privtracker_precmd"

run_rc_command "$1"