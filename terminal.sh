#!/bin/bash

echo "How many PING COUNT you want?"
read COUNT

while IFS='' read -r line || [[ -n "$line" ]]; do
	gnome-terminal -x bash -c "ping -c $COUNT $line | tee 'ping$line'"
done < IPlist
