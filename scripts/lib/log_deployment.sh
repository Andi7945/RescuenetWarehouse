#!/bin/bash

ORG="$1"
ENV="$2"
PROJECT_ID="$3"
GIT_COMMIT="$4"

LOG_FILE="deployments.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
USER=$(whoami)

# Create log entry
LOG_ENTRY="$TIMESTAMP | $USER | $ORG | $ENV | $PROJECT_ID | $GIT_COMMIT"

# Append to log file
echo "$LOG_ENTRY" >> "$LOG_FILE"

echo "📝 Deployment logged to $LOG_FILE"
