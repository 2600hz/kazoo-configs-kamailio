#!/bin/bash
DISPATCHER_FILE="/usr/local/etc/opensips/dispatcher.list"
OSIP_CTL="/usr/local/etc/opensips/opensipsctl"

fUsage () {
        echo "Usage: $0 [-r reload] [-f flush] [Media Server IP] [-a active] [-i inactive] [-p probing]"
        exit 1
}

cd `dirname $0`

[[ ! $1 == -* ]] && server=$1 && shift

while [ -n "$*" ]; do
    case "x$1" in
        x-a)
            action="a"
            ;;
        x-i)
            action="i"
            ;;
        x-p)
            action="p"
            ;;
        x-r)
            action="r"
            ;;
        x-f)
            action="f"
            ;;
        x--help)
            fUsage
            ;;
        *)
            fUsage
            ;;
    esac
    shift
done

if [ -z $action ]; then
        echo "# $OSIP_CTL fifo ds_list"
        $OSIP_CTL fifo ds_list
        exit 0
elif [ $action == "r" ]; then
        echo "# $OSIP_CTL fifo ds_reload"
        $OSIP_CTL fifo ds_reload
        exit 0
elif grep -q $server $DISPATCHER_FILE; then
        echo "# $OSIP_CTL fifo ds_set_state $action `grep $server $DISPATCHER_FILE | cut -d' ' -f 1` `grep $server $DISPATCHER_FILE | cut -d' ' -f 2`"
        $OSIP_CTL fifo ds_set_state $action `grep $server $DISPATCHER_FILE | cut -d' ' -f 1` `grep $server $DISPATCHER_FILE | cut -d' ' -f 2`
        exit 0
else
        echo "ERROR: Could not locate $server in $DISPATCHER_FILE"
        exit 1
fi
