#!/bin/sh

# PROVIDE: mailbear
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# /usr/local/etc/rc.d/mailbear
# https://github.com/DenBeke/mailbear

. /etc/rc.subr

name="mailbear"
desc="Self hosted forms backend"
rcvar="mailbear_enable"

load_rc_config $name

: ${mailbear_enable:="NO"}
: ${mailbear_dir:="/usr/local/etc/mailbear"}
: ${mailbear_chdir:="${mailbear_dir}"}
: ${mailbear_config_file:="${mailbear_dir}/config.yml"}
: ${mailbear_logfile:="/var/log/mailbear.log"}
: ${mailbear_pidfile:="/var/run/mailbear.pid"}
: ${mailbear_username:="mailbear"}
mailbear_group=${mailbear_group:-$mailbear_user}
: ${mailbear_chown:=yes}

pidfile="${mailbear_pidfile}"
procname="/usr/local/bin/mailbear"
command="/usr/sbin/daemon"
command_args="-o '${mailbear_logfile}' -p '${pidfile}' -u '${mailbear_username}' -t '${desc}' -- ${procname}"
start_precmd="mailbear_precmd"

mailbear_precmd()
{
    # Check if user exist
    if id -u $mailbear_username > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${mailbear_username}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${mailbear_dir}" ]; then
        mkdir -p "${mailbear_dir}"
    fi
    # Check if config file exist
    if [ ! -e "${mailbear_config_file}" ]; then
        cp /usr/local/share/mailbear/config_sample.yml "${mailbear_config_file}"
    fi
    # Chown config file
    if checkyesno mailbear_chown; then
        chown "${mailbear_username}":"${mailbear_group}" "${mailbear_config_file}"
    fi
}

run_rc_command "$1"