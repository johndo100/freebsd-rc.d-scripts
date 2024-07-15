#!/bin/sh

# PROVIDE: glauth
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# mkdir /usr/local/etc/rc.d
# touch /usr/local/etc/rc.d/glauth
# chmod +x /usr/local/etc/rc.d/glauth
# ee /usr/local/etc/rc.d/glauth
# /usr/local/etc/rc.d/glauth
# https://github.com/glauth/glauth

. /etc/rc.subr

name=glauth
rcvar=glauth_enable
desc="Go-lang LDAP Authentication (GLAuth)"
load_rc_config ${name}

: ${glauth_enable:="NO"}
: ${glauth_dir:="/usr/local/etc/glauth"}
: ${glauth_logfile:="/var/log/glauth.log"}
: ${glauth_pidfile:="/var/run/glauth.pid"}
: ${glauth_daemon_user:="glauth"}
glauth_daemon_group=${glauth_daemon_group:-$glauth_daemon_user}
: ${glauth_chown:=yes}
# glauth Environment variables
: ${glauth_config:="${glauth_dir}/glauth.cfg"}

glauth_precmd()
{
    # Check if user exist then create with uid 1000
    if id -u $glauth_daemon_user > /dev/null 2>&1; then
            echo "User is found, continue"
    else
            echo "User is not found, create one"
            pw useradd -n "${glauth_daemon_user}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${glauth_dir}" ]; then
        mkdir -p "${glauth_dir}"
    fi
    # Chown data folder
    if checkyesno glauth_chown; then
        chown -R "${glauth_daemon_user}":"${glauth_daemon_group}" "${glauth_dir}"
    fi
}

pidfile="${glauth_pidfile}"
procname="/usr/local/bin/glauth"
command="/usr/sbin/daemon"
command_args="-o '${glauth_logfile}' -p '${pidfile}' -u '${glauth_daemon_user}' -t '${desc}' '${procname}' -c '${glauth_config}'"
start_precmd="glauth_precmd"

run_rc_command "$1"