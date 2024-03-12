#!/bin/sh

# PROVIDE: mailygo
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# /usr/local/etc/rc.d/mailygo
# https://git.jlel.se/jlelse/MailyGo

. /etc/rc.subr

name=mailygo
rcvar=mailygo_enable
load_rc_config ${name}

: ${mailygo_enable:="NO"}
: ${mailygo_smtp_user:="no-reply@example.com"}
: ${mailygo_smtp_pass:="SuperSecret"}
: ${mailygo_smtp_host:="smtp.example.com"}
: ${mailygo_smtp_port:="587"}
: ${mailygo_email_from:="no-reply@example.com"}
: ${mailygo_email_to:="recepient@example.com"}
: ${mailygo_allowed_to:="recepient1@example.com,recepient2@example.com"}
: ${mailygo_port:="8080"}
: ${mailygo_honeypots:="_t_email"}
: ${mailygo_google_api_key:=""}
: ${mailygo_blacklist:="gambling,casino"}
: ${mailygo_logfile:="/var/log/mailygo.log"}
: ${mailygo_pidfile:="/var/run/mailygo.pid"}
: ${mailygo_username:="mailygo"}
mailygo_group=${mailygo_group:-$mailygo_user}

export_variable()
{
	_var="mailygo_$(echo $1 | tr A-Z a-z)"
	eval _val="\$${_var}"
	[ -z "${_val}" ] || export "${1}"="${_val}"
}

export_variables()
{
	for _v in $@; do
		export_variable "${_v}"
	done
}

mailygo_precmd()
{
    # Check if user exist
    if id -u $mailygo_username > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${mailygo_username}" -u 1000  -m
    fi
	export_variables SMTP_USER SMTP_PASS SMTP_HOST SMTP_PORT EMAIL_FROM EMAIL_TO ALLOWED_TO PORT HONEYPOTS GOOGLE_API_KEY BLACKLIST
}

pidfile="${mailygo_pidfile}"
procname="/usr/local/bin/mailygo"
command="/usr/sbin/daemon"
command_args="-o '${mailygo_logfile}' -p '${pidfile}' -u '${mailygo_username}' -t '${desc}' -- ${procname}"
start_precmd="mailygo_precmd"

run_rc_command "$1"