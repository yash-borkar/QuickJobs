#!/bin/bash

export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "Stopping QuickJobs Node application if running..."

pm2 stop quickjobs-app || true
pm2 delete quickjobs-app || true
