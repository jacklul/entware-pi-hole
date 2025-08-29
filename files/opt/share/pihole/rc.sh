#!/bin/sh
# This file is executed by /opt/etc/init.d/S65pihole-FTL

case $1 in
    start|restart)
        if [ -z "$ARGS" ] && [ -z "$PREARGS" ]; then
            if [ -z "$(id -u pihole 2> /dev/null)" ]; then
                echo "Warning: User 'pihole' does not exist!" >&2
            fi

            #shellcheck source=../../../../dev/core/advanced/Scripts/utils.sh
            . /opt/share/pihole/utils.sh
            run_as_user="$(getRunAsUser)"

            # User can choose to force to run as root...
            if [ "$run_as_user" = "root" ] || [ "$run_as_user" = "$(id -nu 0 2> /dev/null)" ]; then
                run_as_user=
            fi

            # Update permissions of /dev/shm to allow non-root users to create and delete own files
            if [ -n "$run_as_user" ] && [ "$(stat -c "%a" /dev/shm)" != "1777" ] && ! chmod 1777 /dev/shm; then
                echo "Warning: Failed to update permissions of /dev/shm!" >&2
            fi

            # Check if we can start the daemon the intended way (setting capabilities on the binary)
            if
                [ -n "$run_as_user" ] && \
                setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN,CAP_SYS_NICE,CAP_IPC_LOCK,CAP_CHOWN+eip /opt/bin/pihole-FTL
            then
                PREARGS="nonroot $run_as_user"
            fi

            # Explicitly specify user and group to use if it is not 'pihole'
            if [ "$run_as_user" != "pihole" ]; then
                if [ -n "$run_as_user" ]; then
                    ARGS="-- -u $run_as_user -g $run_as_user"
                fi

                echo "Warning: Starting in an unsupported way - expect issues to happen!" >&2
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
