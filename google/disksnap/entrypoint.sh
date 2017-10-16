#!/bin/bash
# run google-cloud-auto-snapshot.sh in a loop with a configurable delay
# $HOST_REGEX environment variable with the REGEX to match the disks to snapshot
# ($SLEEP environment variable) and a notification command 
# ($NOTIFY_COMMAND environment variable), for example a curl webhook
# notification (e.g. to Slack).
[ -z "${HOST_REGEX}" ] && { echo "HOST_REGEX ENV variable cannot be empty" && exit 1; }
if [ -z "${SLEEP}" ]; then
  # Default to every 24 hours
  SLEEP=86400
fi
while true; do
  /opt/google-cloud-auto-snapshot.sh ${HOST_REGEX}
  if [ -n "${NOTIFY_COMMAND}" ]; then
    echo "Running notify command: $NOTIFY_COMMAND"
    bash -c "$NOTIFY_COMMAND"
  fi
  echo "Sleeping for $SLEEP seconds"
  sleep $SLEEP
done
