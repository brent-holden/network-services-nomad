#!/usr/bin/env bash

source ${BASH_SOURCE%/*}/variables.sh

for SERVICE in "${!SERVICES[@]}"
do
  IMGANDREPO=${SERVICES[${SERVICE}]}
  IMAGE=`echo ${IMGANDREPO} | awk -F : '{ print $1 }'`
  RELEASE=`echo ${IMGANDREPO} | awk -F : '{ print $2 }'`

  echo "Pulling ${IMAGE}:${RELEASE}"
  # pull defined image
  podman pull ${IMAGE}:${RELEASE}

  # get image Id
  ID=`podman inspect --format "{{.Id}}" ${IMAGE}:${RELEASE}`

  # echo "Writing: ${SERVICE}/config/image as ${IMAGE}"
  consul kv put ${SERVICE}/config/image ${IMAGE}

  # echo "Writing: ${SERVICE}/config/release as ${RELEASE}"
  consul kv put ${SERVICE}/config/release ${RELEASE}

  #echo "Writing: ${SERVICE}/config/image_id as ${ID}"
  consul kv put ${SERVICE}/config/image_id ${ID}
done
