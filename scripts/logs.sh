#!/bin/bash
cmd='tail -f logs/*.log|less'
if [ $(whoami) == 'root' ]
then eval $cmd
else echo "Please run this as root from the repository root. This script will run '$cmd'.
Recommended usage: Split screen inside tmux or screen. Press Shift+F to receive updates in less."
fi
