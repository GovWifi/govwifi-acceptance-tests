#!/bin/sh
#
# Set up the shell environment to run the test utilities. This will set the
# radius server IP and recover the certs we need for eapol_test
#
export CLIENT_LOCATION_IP_ADDRESS=$(getent hosts local-dev | awk '{print $1}')
echo "CLIENT_LOCATION_IP_ADDRESS=$CLIENT_LOCATION_IP_ADDRESS"

bundle exec rails runner /tmp/admin_database_configuration.rb $CLIENT_LOCATION_IP_ADDRESS
