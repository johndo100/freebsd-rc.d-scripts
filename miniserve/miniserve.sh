#!/bin/sh

# PROVIDE: miniserve
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# /usr/local/etc/rc.d/miniserve
# https://github.com/svenstaro/miniserve

. /etc/rc.subr

name=miniserve
rcvar=miniserve_enable
desc="a CLI tool to serve files and dirs over HTTP"
load_rc_config ${name}

: ${miniserve_enable:="NO"}
: ${miniserve_dir:="/usr/local/www/miniserve"}
: ${miniserve_logfile:="/var/log/miniserve.log"}
: ${miniserve_pidfile:="/var/run/miniserve.pid"}
: ${miniserve_daemon_user:="miniserve"}
miniserve_daemon_group=${miniserve_daemon_group:-$miniserve_daemon_user}
: ${miniserve_chown:=yes}
# miniserve Environment variables
: ${miniserve_path:="${miniserve_dir}"}
: ${miniserve_verbose:=""}
: ${miniserve_index:=""}
: ${miniserve_spa:=""}
: ${miniserve_pretty_urls:=""}
: ${miniserve_port:="8080"}
: ${miniserve_interface:=""}
: ${miniserve_auth:=""}
: ${miniserve_auth_file:=""}
: ${miniserve_route_prefix:=""}
: ${miniserve_random_route:=""}
: ${miniserve_no_symlinks:=""}
: ${miniserve_hidden:=""}
: ${miniserve_default_sorting_method:="name"}
: ${miniserve_default_sorting_order:="desc"}
: ${miniserve_color_scheme:="squirrel"}
: ${miniserve_color_scheme_dark:="archlinux"}
: ${miniserve_qrcode:=""}
: ${miniserve_allowed_upload_dir:=""}
: ${miniserve_mkdir_enabled:=""}
: ${miniserve_media_type:=""}
: ${miniserve_raw_media_type:=""}
: ${miniserve_overwrite_files:="false"}
: ${miniserve_enable_tar:=""}
: ${miniserve_enable_tar_gz:=""}
: ${miniserve_enable_zip:=""}
: ${miniserve_compress_response:=""}
: ${miniserve_dirs_first:=""}
: ${miniserve_title:=""}
: ${miniserve_header:=""}
: ${miniserve_show_symlink_info:=""}
: ${miniserve_hide_version_footer:=""}
: ${miniserve_hide_theme_selector:=""}
: ${miniserve_show_wget_footer:=""}
: ${miniserve_tls_cert:=""}
: ${miniserve_tls_key:=""}
: ${miniserve_readme:=""}
: ${miniserve_disable_indexing:=""}                                 


export_variable()
{
	_var="$(echo $1 | tr A-Z a-z)"
	eval _val="\$${_var}"
	[ -z "${_val}" ] || export "${1}"="${_val}"
}

export_variables()
{
	for _v in $@; do
		export_variable "${_v}"
	done
}

miniserve_precmd()
{
    # Check if user exist
    if id -u $miniserve_daemon_user > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${miniserve_daemon_user}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${miniserve_dir}" ]; then
        mkdir -p "${miniserve_dir}"
    fi
    # Chown data folder
    if checkyesno miniserve_chown; then
        chown -R "${miniserve_daemon_user}":"${miniserve_daemon_group}" "${miniserve_dir}"
    fi
    # Set path
	if [ -z "${miniserve_path}" ]; then
		err 1 "miniserve_path must be set"
	fi
    # Export miniserve_overwrite_files OVERWRITE_FILES
    export OVERWRITE_FILES="${miniserve_overwrite_files}"
    # Export variables
	export_variables MINISERVE_VERBOSE MINISERVE_INDEX MINISERVE_SPA MINISERVE_PRETTY_URLS MINISERVE_PORT MINISERVE_INTERFACE MINISERVE_AUTH MINISERVE_AUTH_FILE MINISERVE_ROUTE_PREFIX MINISERVE_RANDOM_ROUTE MINISERVE_NO_SYMLINKS MINISERVE_HIDDEN MINISERVE_DEFAULT_SORTING_METHOD MINISERVE_DEFAULT_SORTING_ORDER MINISERVE_COLOR_SCHEME MINISERVE_COLOR_SCHEME_DARK MINISERVE_QRCODE MINISERVE_ALLOWED_UPLOAD_DIR MINISERVE_MKDIR_ENABLED MINISERVE_MEDIA_TYPE MINISERVE_RAW_MEDIA_TYPE MINISERVE_ENABLE_TAR MINISERVE_ENABLE_TAR_GZ MINISERVE_ENABLE_ZIP MINISERVE_COMPRESS_RESPONSE MINISERVE_DIRS_FIRST MINISERVE_TITLE MINISERVE_HEADER MINISERVE_SHOW_SYMLINK_INFO MINISERVE_HIDE_VERSION_FOOTER MINISERVE_HIDE_THEME_SELECTOR MINISERVE_SHOW_WGET_FOOTER MINISERVE_TLS_CERT MINISERVE_TLS_KEY MINISERVE_README MINISERVE_DISABLE_INDEXING
}

pidfile="${miniserve_pidfile}"
procname="/usr/local/bin/miniserve"
command="/usr/sbin/daemon"
command_args="-o '${miniserve_logfile}' -p '${pidfile}' -u '${miniserve_daemon_user}' -t '${desc}' -- ${procname} ${miniserve_path}"
start_precmd="miniserve_precmd"

run_rc_command "$1"