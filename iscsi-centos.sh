#!/bin/bash

# stop the service for iscsi and start it manually
# CentOS latest cases only.

systemctl stop iscsid.socket
systemctl disable iscsid.socket

if pgrep -x iscsid > /dev/null
then
    echo "iscsid is running"
else
    echo "iscsid is not running, starting"
    iscsid
fi

echo "Checking to see iscsi-recv"
systemctl --all | grep iscsi-recv


if pgrep -x iscsid > /dev/null
then
        echo "iscsid is running"
fi

