#!/bin/sh

# PROVIDE: flaresolverr
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# /usr/local/etc/rc.d/flaresolverr
# https://github.com/FlareSolverr/FlareSolverr

. /etc/rc.subr

name=flaresolverr
rcvar=flaresolverr_enable
desc="Proxy server to bypass Cloudflare protection"
load_rc_config ${name}

: ${flaresolverr_enable:="NO"}
: ${flaresolverr_dir:="/usr/local/etc/flaresolverr"}
: ${flaresolverr_logfile:="/var/log/flaresolverr.log"}
: ${flaresolverr_pidfile:="/var/run/flaresolverr.pid"}
: ${flaresolverr_username:="flaresolverr"}
flaresolverr_group=${flaresolverr_group:-$flaresolverr_user}
: ${flaresolverr_chown:=yes}
# flaresolverr Environment variables
: ${flaresolverr_log_level:="info"}
: ${flaresolverr_log_html:="false"}
: ${flaresolverr_captcha_solver:="none"}
: ${flaresolverr_tz:="UTC"}
: ${flaresolverr_lang:="none"}
: ${flaresolverr_headless:="true"}
: ${flaresolverr_browser_timeout:="40000"}
: ${flaresolverr_test_url:="https://www.google.com"}
: ${flaresolverr_port:="8191"}
: ${flaresolverr_host:="0.0.0.0"}
: ${flaresolverr_prometheus_enabled:="false"}
: ${flaresolverr_prometheus_port:="8192"}

export_variable()
{
	_var="flaresolverr_$(echo $1 | tr A-Z a-z)"
	eval _val="\$${_var}"
	[ -z "${_val}" ] || export "${1}"="${_val}"
}

export_variables()
{
	for _v in $@; do
		export_variable "${_v}"
	done
}

flaresolverr_precmd()
{
    # Check if user exist
    if id -u $flaresolverr_username > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${flaresolverr_username}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${flaresolverr_dir}" ]; then
        mkdir -p "${flaresolverr_dir}"
    fi
    # Chown data folder
    if checkyesno flaresolverr_chown; then
        chown -R "${flaresolverr_username}":"${flaresolverr_group}" "${flaresolverr_dir}"
    fi
    # export variables
	export_variables LOG_LEVEL LOG_HTML CAPTCHA_SOLVER TZ LANG HEADLESS BROWSER_TIMEOUT TEST_URL PORT HOST PROMETHEUS_ENABLED PROMETHEUS_PORT
}

pidfile="${flaresolverr_pidfile}"
py_script="${flaresolverr_dir}/src/flaresolverr.py"
python="/usr/local/bin/python3.9"
command="/usr/sbin/daemon"
command_args="-o '${flaresolverr_logfile}' -P '${pidfile}' -u '${flaresolverr_username}' -t '${desc}' ${python} ${py_script}"
start_precmd="flaresolverr_precmd"

run_rc_command "$1"