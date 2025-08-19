#!/bin/sh
# This file is executed by /opt/etc/init.d/S65pihole-FTL

case $1 in
    start|restart)
        if [ -z "$ARGS" ] && [ -z "$PREARGS" ]; then
            root_user="$(id -nu 0 2> /dev/null)"
            root_group="$(id -ng 0 2> /dev/null)"

            if [ -z "$root_user" ] || [ -z "$root_group" ]; then
                echo "Error: Unable to find root user or group" >&2
                exit 1
            fi

            #shellcheck disable=SC1091
            . /opt/share/pihole/utils.sh
            run_as_user="$(getRunAsUser)"

            # User can choose to force to run as root...
            if [ "$run_as_user" = "root" ] || [ "$run_as_user" = "$root_user" ]; then
                run_as_user=
            fi

            # Update permissions of /dev/shm to allow non-root users to create and delete files
            if [ -n "$run_as_user" ] && [ "$(stat -c "%a" /dev/shm)" != "1777" ]; then
                if ! chmod 1777 /dev/shm; then
                    echo "Warning: Failed to update permissions of /dev/shm" >&2
                fi
            fi

            if [ -z "$(id -u pihole 2> /dev/null)" ]; then
                echo "Warning: User 'pihole' does not exist!" >&2
            fi

            # Check if we can start the daemon the intended way
            if
                [ -n "$run_as_user" ] && \
                setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN,CAP_SYS_NICE,CAP_IPC_LOCK,CAP_CHOWN+eip "/opt/bin/pihole-FTL"
            then
                PREARGS="nonroot $run_as_user"

                # Explicitly specify user and group for the dnsmasq to use
                # Without this dnsmasq will fail with error 'unknown user or group: root' if the root user is not called 'root'
                if [ "$run_as_user" != "pihole" ] || [ "$root_user" != "root" ]; then
                    ARGS="-- -u $run_as_user -g $run_as_user"
                fi
            else
                echo "Warning: Starting in an unsupported way - expect issues to happen!" >&2

                if [ -n "$run_as_user" ]; then
                    ARGS="-- -u $run_as_user -g $run_as_user"

                    echo "Warning: Starting pihole-FTL as '$root_user' (then changing to '$run_as_user') because setting capabilities is not supported on this system" >&2
                else
                    ARGS="-- -u $root_user -g $root_group" # still needed to avoid dnsmasq error mentiond above

                    echo "Warning: Starting pihole-FTL as '$root_user' because couldn't find a suitable user to run as" >&2
                fi
            fi
        fi

        [ -n "$PRECMD" ] && PRECMD_USER="$PRECMD"
        PRECMD="_pihole_prestart"

        _pihole_prestart() {
            # Run poststop and prestart scripts before start/restart
            bash /opt/share/pihole/pihole-FTL-poststop.sh
            bash /opt/share/pihole/pihole-FTL-prestart.sh

            [ -n "$PRECMD_USER" ] && $PRECMD_USER
        }
    ;;
    stop)
        [ -n "$POSTCMD" ] && POSTCMD_USER="$POSTCMD"
        POSTCMD="_pihole_poststart"

        _pihole_poststart() {
            # Run poststop script after stop
            bash /opt/share/pihole/pihole-FTL-poststop.sh

            [ -n "$POSTCMD_USER" ] && $POSTCMD_USER
        }
    ;;
esac
