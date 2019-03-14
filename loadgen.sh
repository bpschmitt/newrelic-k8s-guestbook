#!/bin/bash

PORT=$1

for i in {1..1000}
do
	echo "Sending message $i..."
	curl -d "message=automated_message_$i" -X POST http://192.168.99.101:$PORT/message 2>&1
	echo ""
	sleep 3
done
