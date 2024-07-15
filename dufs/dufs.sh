#!/bin/sh

# PROVIDE: dufs
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# mkdir /usr/local/etc/rc.d
# touch /usr/local/etc/rc.d/dufs
# chmod +x /usr/local/etc/rc.d/dufs
# vim /usr/local/etc/rc.d/dufs
# https://github.com/sigoden/dufs

. /etc/rc.subr

name=dufs
rcvar=dufs_enable
desc="a distinctive utility file server"
load_rc_config ${name}

: ${dufs_enable:="NO"}
: ${dufs_dir:="/usr/local/dufs"}
: ${dufs_logfile:="/var/log/dufs.log"}
: ${dufs_pidfile:="/var/run/dufs.pid"}
: ${dufs_daemon_user:="dufs"}
dufs_daemon_group=${dufs_daemon_group:-$dufs_daemon_user}
: ${dufs_chown:=yes}
# dufs Environment variables
: ${dufs_serve_path:="${dufs_dir}"} # Specific path to serve [default: .]
: ${dufs_config:=""} # Specify configuration file
: ${dufs_bind:="0.0.0.0"} # Specify bind address or unix socket
: ${dufs_port:="5000"} # Specify port to listen on [default: 5000]
: ${dufs_path_prefix:="/dufs"} # Specify a path prefix, your url will be your.domain/dufs; Use "/" for root
: ${dufs_hidden:="tmp,*.log,*.lock"} # Hide paths from directory listings, e.g. tmp,*.log,*.lock
: ${dufs_auth:="admin:admin@/:rw|@/"} # Add auth roles, e.g. user:pass@/dir1:rw,/dir2; DUFS supports the use of sha-512 hashed password.
: ${dufs_allow_all:="true"} # Allow all operations
: ${dufs_allow_upload:="true"} # Allow upload files/folders
: ${dufs_allow_delete:="true"} # Allow delete files/folders
: ${dufs_allow_search:="true"} # Allow search files/folders
: ${dufs_allow_symlink:="true"} # Allow symlink to files/folders outside root directory
: ${dufs_allow_archive:="true"} # Allow zip archive generation
: ${dufs_enable_cors:="true"} # Enable CORS, sets `Access-Control-Allow-Origin: *`
: ${dufs_render_index:="true"} # Serve index.html when requesting a directory, returns 404 if not found index.html
: ${dufs_render_try_index:="true"} # Serve index.html when requesting a directory, returns directory listing if not found index.html
: ${dufs_render_spa:="true"} # Serve SPA(Single Page Application)
: ${dufs_assets:=""} # Set the path to the assets directory for overriding the built-in assets
: ${dufs_log_format:=""} # Customize http log format
: ${dufs_log_file:=""} # Specify the file to save logs to, other than stdout/stderr
: ${dufs_compress:="low"} # Set zip compress level [default: low] [possible values: none, low, medium, high]
: ${dufs_tls_cert:=""} # Path to an SSL/TLS certificate to serve with HTTPS
: ${dufs_tls_key:=""} # Path to the SSL/TLS certificate's private key


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

dufs_precmd()
{
    # Check if user exist
    if id -u $dufs_daemon_user > /dev/null 2>&1; then
            echo "User found, it's OK"
    else
            echo "User not found, create one"
            pw useradd -n "${dufs_daemon_user}" -u 1000  -m
    fi
    # Check if folder exist
    if [ ! -d "${dufs_serve_path}" ]; then
        mkdir -p "${dufs_serve_path}"
    fi
    # Set ownnership to folder
    if checkyesno dufs_chown; then
        chown -R "${dufs_daemon_user}":"${dufs_daemon_group}" "${dufs_serve_path}"
    fi
    # Export variables
	export_variables DUFS_SERVE_PATH DUFS_CONFIG DUFS_BIND DUFS_PORT DUFS_PATH_PREFIX DUFS_HIDDEN DUFS_AUTH DUFS_ALLOW_ALL DUFS_ALLOW_UPLOAD DUFS_ALLOW_DELETE DUFS_ALLOW_SEARCH DUFS_ALLOW_SYMLINK DUFS_ALLOW_ARCHIVE DUFS_ENABLE_CORS DUFS_RENDER_INDEX DUFS_RENDER_TRY_INDEX DUFS_RENDER_SPA DUFS_ASSETS DUFS_LOG_FORMAT DUFS_LOG_FILE DUFS_COMPRESS DUFS_TLS_CERT DUFS_TLS_KEY
}

pidfile="${dufs_pidfile}"
procname="/usr/local/bin/dufs"
command="/usr/sbin/daemon"
command_args="-o '${dufs_logfile}' -p '${pidfile}' -u '${dufs_daemon_user}' -t '${desc}' -- ${procname}"
start_precmd="dufs_precmd"

run_rc_command "$1"