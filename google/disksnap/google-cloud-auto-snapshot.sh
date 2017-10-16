#!/bin/bash
# Original Author: Alan Fuller, Fullworks
# loop through certain disks within this project  and create a snapshot
REGEX=$1
SNAP_PREFIX='disksnap-'
DISK_REGEX=$SNAP_PREFIX$REGEX
gcloud compute disks list --format='value(name,zone)' --regexp=$REGEX | while read DISK_NAME ZONE; do
  gcloud compute disks snapshot $DISK_NAME --snapshot-names $SNAP_PREFIX${DISK_NAME:0:30}-$(date "+%Y-%m-%d-%s") --zone $ZONE
done
#
# snapshots are incremental and dont need to be deleted, 
# deleting snapshots will merge snapshots, so deleting doesn't lose anything
# This script deletes them after 30 days
#
gcloud compute snapshots list --filter="creationTimestamp<$(date -d "-30 days" "+%Y-%m-%d")" --regexp=$DISK_REGEX --uri | while read SNAPSHOT_URI DISK_SIZE SRC_DISK STATUS; do
   gcloud --quiet compute snapshots delete $SNAPSHOT_URI
done
#
