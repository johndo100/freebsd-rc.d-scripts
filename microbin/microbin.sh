#!/bin/sh

# PROVIDE: microbin
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# /usr/local/etc/rc.d/microbin
# https://github.com/szabodanika/microbin

. /etc/rc.subr

name=microbin
rcvar=microbin_enable
desc="Super tiny, feature rich, configurable, self-contained and self-hosted paste bin web application"
load_rc_config ${name}

: ${microbin_enable:="NO"}
: ${microbin_dir:="/usr/local/etc/microbin"}
: ${microbin_chdir:="/usr/local/etc/microbin"}
: ${microbin_logfile:="/var/log/microbin.log"}
: ${microbin_pidfile:="/var/run/microbin.pid"}
: ${microbin_username:="microbin"}
microbin_group=${microbin_group:-$microbin_user}
: ${microbin_chown:=yes}
# Microbin Environment variables
: ${microbin_basic_auth_username:=""}
: ${microbin_basic_auth_password:=""}
: ${microbin_admin_username:="admin"}
: ${microbin_admin_password:="m1cr0b1n"}
: ${microbin_editable:="true"}
: ${microbin_footer_text:=""}
: ${microbin_hide_header:="false"}
: ${microbin_hide_footer:="false"}
: ${microbin_hide_logo:="false"}
: ${microbin_no_listing:="false"}
: ${microbin_highlightsyntax:="true"}
: ${microbin_port:="8080"}
: ${microbin_bind:="0.0.0.0"}
: ${microbin_private:="true"}
: ${microbin_pure_html:="false"}
: ${microbin_data_dir:="microbin_data"}
: ${microbin_json_db:="false"}
: ${microbin_public_path:=""}
: ${microbin_short_path:=""}
: ${microbin_uploader_password:=""}
: ${microbin_readonly:="false"}
: ${microbin_show_read_stats:="true"}
: ${microbin_title:=""}
: ${microbin_threads:="1"}
: ${microbin_gc_days:="90"}
: ${microbin_enable_burn_after:="false"}
: ${microbin_default_burn_after:="0"}
: ${microbin_wide:="false"}
: ${microbin_qr:="false"}
: ${microbin_eternal_pasta:="false"}
: ${microbin_enable_readonly:="true"}
: ${microbin_default_expiry:="24hour"}
: ${microbin_no_file_upload:="false"}
: ${microbin_custom_css:=""}
: ${microbin_hash_ids:="false"}
: ${microbin_encryption_client_side:="false"}
: ${microbin_encryption_server_side:="false"}
: ${microbin_max_file_size_encrypted_mb:="256"}
: ${microbin_max_file_size_unencrypted_mb:="2048"}
: ${microbin_disable_update_checking:="false"}
: ${microbin_disable_telemetry:="false"}
: ${microbin_list_server:="false"}

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

microbin_precmd()
{
    # Check if user exist
    if id -u $microbin_username > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${microbin_username}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${microbin_dir}" ]; then
        mkdir -p "${microbin_dir}"
    fi
    # Chown data folder
    if checkyesno microbin_chown; then
        chown -R "${microbin_username}":"${microbin_group}" "${microbin_dir}"
    fi
    # export variables
	export_variables MICROBIN_BASIC_AUTH_USERNAME MICROBIN_BASIC_AUTH_PASSWORD MICROBIN_ADMIN_USERNAME MICROBIN_ADMIN_PASSWORD MICROBIN_EDITABLE MICROBIN_FOOTER_TEXT MICROBIN_HIDE_HEADER MICROBIN_HIDE_FOOTER MICROBIN_HIDE_LOGO MICROBIN_NO_LISTING MICROBIN_HIGHLIGHTSYNTAX MICROBIN_PORT MICROBIN_BIND MICROBIN_PRIVATE MICROBIN_PURE_HTML MICROBIN_DATA_DIR MICROBIN_JSON_DB MICROBIN_PUBLIC_PATH MICROBIN_SHORT_PATH MICROBIN_UPLOADER_PASSWORD MICROBIN_READONLY MICROBIN_SHOW_READ_STATS MICROBIN_TITLE MICROBIN_THREADS MICROBIN_GC_DAYS MICROBIN_ENABLE_BURN_AFTER MICROBIN_DEFAULT_BURN_AFTER MICROBIN_WIDE MICROBIN_QR MICROBIN_ETERNAL_PASTA MICROBIN_ENABLE_READONLY MICROBIN_DEFAULT_EXPIRY MICROBIN_NO_FILE_UPLOAD MICROBIN_CUSTOM_CSS MICROBIN_HASH_IDS MICROBIN_ENCRYPTION_CLIENT_SIDE MICROBIN_ENCRYPTION_SERVER_SIDE MICROBIN_MAX_FILE_SIZE_ENCRYPTED_MB MICROBIN_MAX_FILE_SIZE_UNENCRYPTED_MB MICROBIN_DISABLE_UPDATE_CHECKING MICROBIN_DISABLE_TELEMETRY MICROBIN_LIST_SERVER
}

pidfile="${microbin_pidfile}"
procname="/usr/local/bin/microbin"
command="/usr/sbin/daemon"
command_args="-o '${microbin_logfile}' -p '${pidfile}' -u '${microbin_username}' -t '${desc}' -- ${procname}"
start_precmd="microbin_precmd"

run_rc_command "$1"