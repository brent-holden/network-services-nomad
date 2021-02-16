#!/usr/bin/env bash

#SERVICES=(pihole netbootxyz unifi)

declare -A SERVICES=( [pihole]=docker.io/pihole/pihole:latest
                      [netbootxyz]=docker.io/linuxserver/netbootxyz:latest
                      [unifi]=docker.io/linuxserver/unifi-controller:latest
                    )
declare -A BACKUPS=(  [pihole]=/opt/pihole
                      [netbootxyz]=/opt/netbootxyz
                      [unifi]=/opt/unifi
                    )
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
