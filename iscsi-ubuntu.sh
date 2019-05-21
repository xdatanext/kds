#!/bin/bash

if pgrep -x iscsid > /dev/null
then
    echo "iscsid is running"
else
    echo "iscsid is not running, starting"
	systemctl restart iscsid
fi

echo "Checking to see iscsi-recv"
systemctl --all | grep iscsi-recv


if pgrep -x iscsid > /dev/null
then
        echo "iscsid is running"
fi


