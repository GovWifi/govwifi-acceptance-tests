#!/bin/sh
#
# Set up the shell environment to run the test utilities. This will set the
# radius server IP and recover the certs we need for eapol_test
#
export RADIUS_SERVER_IP=$(getent hosts govwifi-frontend | awk '{print $1}')
echo "RADIUS_SERVER_IP=$RADIUS_SERVER_IP"

# Copy certs and configuration from the localstack S3 bucket. This will allow
# use to test EAP-PEAP and EAP-TLS calls out local Radius server:
#
aws --endpoint-url=${ENDPOINT_URL} s3 cp ${CERT_STORE_BUCKET}/ /usr/src/app/certs/ --recursive
