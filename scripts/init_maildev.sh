#!/bin/sh

### BEGIN INIT INFO
# Provides:       maildev
# Short-Description: starts the maildev client and server
# Description:       starts maildev using start-stop-daemon
### END INIT INFO

maildev --smtp 25 --silent
