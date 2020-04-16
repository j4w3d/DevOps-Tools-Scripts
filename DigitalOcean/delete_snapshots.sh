#!/usr/bin/env bash

#### AUTHOR: JAWED SALIM
# A bash script to delete 7 days older snapshots of specific DigitalOcean Droplet
###

OLD_DATE=$(gdate --date="7 days ago" +%Y-%m-%d)
DROPLET_ID="NUMERIC-ID-OF-DROPLET"
AUTH_TYPE="XYZ TOKEN_STRING" # example: "BASIC vcxzfvhj6247vh2534g578232cvhjt7852t37ct3287t578"

# Get details of a particular droplet
RESPONSE=$(curl -X GET  -H 'Content-Type: application/json' \
                        -H "Authorization: ${AUTH_TYPE}" \
                        --silent  "https://api.digitalocean.com/v2/droplets/${DROPLET_ID}")

# echo $RESPONSE | jq .

SNAPSHOT_IDS=$(echo $RESPONSE|jq '.droplet.snapshot_ids' | tr -d '[],')
# echo "List of snapshot ids : "$SNAPSHOT_IDS

for SNAPSHOT_ID in ${SNAPSHOT_IDS[@]}
  do
    echo "Retrieving details of snapshot with id : "$SNAPSHOT_ID
    RESPONSE=$(curl -X GET  -H 'Content-Type: application/json' \
                            -H "Authorization: ${AUTH_TYPE}" \
                            --silent  "https://api.digitalocean.com/v2/snapshots/${SNAPSHOT_ID}")
    # echo $RESPONSE | jq .
    
    # get created_at datetime of snapshot
    CREATED_DATETIME=$(echo $RESPONSE|jq '.snapshot.created_at')
    CREATED_DATE=$(echo $CREATED_DATETIME |grep -o -E "\d{4}\-\d{2}\-\d{2}")

    # CREATED_DATE is older than OLD_DATE
    if [[ "$CREATED_DATE" < "$OLD_DATE" ]]
    then
      echo "Deleteing snapshot with id : "$SNAPSHOT_ID
      RESPONSE=$(curl -X DELETE  -H 'Content-Type: application/json' \
                               -H "Authorization: ${AUTH_TYPE}" \
                               --silent  "https://api.digitalocean.com/v2/snapshots/${SNAPSHOT_ID}")

    fi

done
