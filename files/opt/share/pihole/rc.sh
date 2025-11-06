#!/bin/sh
# This file is executed by /opt/etc/init.d/S65pihole-FTL

case $1 in
    start|restart)
        if [ -z "$ARGS" ] && [ -z "$PREARGS" ]; then
            pihole_uid="$(id -u pihole 2> /dev/null)"

            if [ -z "$pihole_uid" ]; then
                echo "Warning: User 'pihole' does not exist!" >&2
            fi

            if [ -n "$pihole_uid" ]; then
                # Update permissions of /dev/shm to allow non-root users to create and delete own files
                if [ "$(stat -c "%a" /dev/shm)" != "1777" ] && ! chmod 1777 /dev/shm; then
                    echo "Warning: Failed to update permissions of /dev/shm!" >&2
                fi

                # Check if we can start the daemon the intended way (setting capabilities on the binary)
                if
                    setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN,CAP_SYS_NICE,CAP_IPC_LOCK,CAP_CHOWN,CAP_SYS_TIME+eip /opt/bin/pihole-FTL
                then
                    PREARGS="nonroot pihole"
                else
                    echo "Warning: Setting capabilities is not supported on this system" >&2
                fi
            else
                echo "Warning: Starting as root user - this is unsupported and will cause issues!" >&2

                root_user="$(id -un 0 2> /dev/null)"
                root_group="$(id -gn 0 2> /dev/null)"

                ARGS="-- -u $root_user -g $root_group"
            fi

            # Prevent processes started by FTL from inheriting USER variable
            export USER=""
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
