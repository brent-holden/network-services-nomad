#!/usr/bin/env bash

declare -A SERVICES=( [pihole]=docker.io/pihole/pihole:latest
                      [netbootxyz]=docker.io/linuxserver/netbootxyz:latest
                      [unifi]=docker.io/linuxserver/unifi-controller:latest
                      [tfc-agent]=docker.io/hashicorp/tfc-agent:latest
                    )

declare -A BACKUPS=(  [pihole]=/opt/pihole
                      [netbootxyz]=/opt/netbootxyz
                      [unifi]=/opt/unifi
                      [tfc-agent]=/dev/null
                    )

DATE=`date +%d-%m-%Y`
CRONDIR=/etc/cron.d
OPTDIR=/opt
TMPDIR=/tmp
RCLONEDIR=/mnt/rclone
RCLONECACHEDIR=${RCLONEDIR}/cache-db
RCLONEBACKUPDIR=${RCLONEDIR}/backup
RCLONECONFIGDIR=${OPTDIR}/rclone
PACKAGES="fuse rsync vim podman podman-docker cockpit cockpit-podman"
NOMAD_PLUGIN_DIR=/opt/nomad/plugins
