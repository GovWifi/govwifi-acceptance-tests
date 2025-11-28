#!/bin/sh
#
# Set up the shell environment to run the test utilities. This will set the
# radius server IP and recover the certs we need for eapol_test
#
export RADIUS_SERVER_IP=$(getent hosts govwifi-frontend | awk '{print $1}')
echo "RADIUS_SERVER_IP=$RADIUS_SERVER_IP"

bundle exec rails runner /tmp/admin_database_configuration.rb $RADIUS_SERVER_IP
