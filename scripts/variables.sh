#!/usr/bin/env bash

#SERVICES=(pihole netbootxyz unifi)

declare -A SERVICES=( [pihole]=docker.io/pihole/pihole:latest
                      [netbootxyz]=docker.io/linuxserver/netbootxyz:latest
                      [unifi]=docker.io/linuxserver/unifi-controller:latest
                    )
#declare -A BACKUPS=(  [lidarr]=/opt/lidarr/Backups/scheduled
#                      [sonarr]=/opt/sonarr/Backups/scheduled
#                      [radarr]=/opt/radarr/Backups/scheduled
#                      [tautulli]=/opt/tautulli/backups
#                      [hydra2]=/opt/hydra2/backup
#                      [sabnzbd]=/opt/sabnzbd/
#                      [ombi]=/opt/ombi/
#                      [caddy]=/opt/caddy/
#                      [plex]=/opt/plex/Backups
#                    )
DATE=`date +%d-%m-%Y`
CRONDIR=/etc/cron.d
OPTDIR=/opt
TMPDIR=/tmp
RCLONEDIR=/mnt/rclone
RCLONECACHEDIR=${RCLONEDIR}/cache-db
RCLONEBACKUPDIR=${RCLONEDIR}/backup
RCLONECONFIGDIR=${OPTDIR}/rclone
PACKAGES="fuse rsync vim podman podman-docker podman-remote cockpit cockpit-podman"
NOMAD_PLUGIN_DIR=/opt/nomad/plugins
