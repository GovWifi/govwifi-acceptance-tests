#!/bin/sh -x

# First remove any previous run data
rm //test_log_data/*

# Copy cert into place
aws --endpoint-url=${ENDPOINT_URL} s3 cp ${CERT_STORE_BUCKET}/ /usr/src/app/certs/ --recursive

# Run tests
bundle exec rspec --order defined
