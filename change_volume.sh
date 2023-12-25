#!/bin/bash
pipe=./PBL4/test
volume_value=$(($1 * 3))
echo "VOLUME $volume_value" > $pipe
exit 0
