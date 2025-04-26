#!/bin/bash

echo "Running app_stop.sh"

# Stop the app if it's already running
pm2 stop quickjobs || true
pm2 delete quickjobs || true
