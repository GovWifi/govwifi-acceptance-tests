#!/bin/sh -x

# First remove any previous run data
rm /test_log_data/*

# Copy cert into place
aws --endpoint-url=${ENDPOINT_URL} s3 cp ${CERT_STORE_BUCKET}/ /usr/src/app/certs/ --recursive

# Run tests - it is important they are run in a predetermined order (filesystem default sort)
# to ensure the logfile test is run after the eap testing has completed. The "--order defined"
# option ensured this happens
bundle exec rspec --order defined -f d
