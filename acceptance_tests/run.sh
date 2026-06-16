#!/bin/sh -x

aws --endpoint-url=${ENDPOINT_URL} s3 cp ${CERT_STORE_BUCKET}/ /usr/src/app/certs/ --recursive
bundle exec rspec
