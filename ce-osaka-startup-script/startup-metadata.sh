#!/bin/bash

# This file will create a metadata.json file in the apache directory with the instance metadata

# Get the internal IP address
INTERNAL_IP=$(hostname -I | awk '{print $1}')

# Get the external IP address (if available)
EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

# Get the instance name
INSTANCE_NAME=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name)

# Get the zone
ZONE=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone)

# Return the metadata as JSON in the apache directory
cat <<EOF > /var/www/html/metadata.json
{
    "internalIp": "$INTERNAL_IP",
    "externalIp": "$EXTERNAL_IP",
    "instanceName": "$INSTANCE_NAME",
    "zone": "$ZONE"
}
EOF