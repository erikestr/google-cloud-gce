#!/bin/bash

# This script performs an HTTP load test using ApacheBench (ab).
# Simple test: 1000 requests, 10 concurrent to a given ip address.
# Usage: ./http-load.sh <ip-address>
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <ip-address>"
    exit 1
fi
IP_ADDRESS=$1

ab -n 10000 -c 10 http://$IP_ADDRESS/
