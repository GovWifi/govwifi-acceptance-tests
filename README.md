# Local environment setup for development and testing

## Test structure

Each Ruby application has its own set of unit tests which get run whenever a
change is made to its project.

The end to end tests aren't yet run automatically by the individual apps.
They are run whenever a change is made to this, govwifi-build, repository is made.
To run the acceptance tests manually follow the instructions below:

```console
make clean test
```

would recommend to tear down the environment after use to free up resources, to do so run

```console
make clean destroy
```

If you make changes to any of the checked out apps you will want to rerun the
above command to rebuild and test your changes.

## CI/CD

The GitHub action is triggered when creating a PR which calls 'make test' and the AWS CodeBuild job which runs the acceptance tests when building images for the tested apps which calls `make test-ci` to allow for custom branches to be tested, which can be set via the codebuild job.

## Developing within localstack

When making changes to an app it is useful to keep a tight feedback loop by
making your changes to the version in the version checked out here, running end
to end tests, and pushing up to GitHub when all passing.

## Helpful scripts

- `./acceptance_tests` - The Docker setup directory for the testing environment
- `./testdatabase` - All .sql scripts inside this directory will be executed for the main database

## List of apps

### Frontend

These is the FreeRadius configuration, pulled from
[govwifi-frontend](https://github.com/GovWifi/govwifi-frontend) into `.frontend`.

### Authentication

This is the Authentication API, checking user details against the Database

It is pulled from the [govwifi-authentication-api](https://github.com/GovWifi/govwifi-authentication-api) repository
and placed into the `.authentication-api` folder.

### Logging

This is the Logging API, also known as PostAuth in the Radius domain

It is pulled from the [govwifi-logging-api](https://github.com/GovWifi/govwifi-logging-api) repository
and placed into the `.logging-api` folder.

### Local Shell

This is a tool to aid in learning and local development. It provides a running
shell. From which you can run tools to run epol_test or use cURL to make API calls to local running services, inside the docker network.

```

# From the cli
make shell

# See docker-compose.yml for credential details.

# Connect see the userdetails we can use.
#
echo "select username, password, email, mobile from userdetails;" | \
 mariadb --skip-ssl --host=govwifi-user-details-db --password=testpassword -u root govwifi_local

# username password email mobile
# DSLPR SharpRegainDetailed NULL NULL

# Recover the user authorisation password from the authentication API:
#
curl -s http://govwifi-authentication-api-local:8080/authorize/user/DSLPR | jq .
{
  "control:Cleartext-Password": "SharpRegainDetailed"
}

RADIUS_SERVER_IP=$(getent hosts govwifi-frontend-local | awk '{print $1}')
echo "RADIUS_SERVER_IP=$RADIUS_SERVER_IP"

# Copy certs and configuration from the localstack S3 bucket. This will allow
# use to test EAP-PEAP and EAP-TLS calls out local Radius server:
#
aws --endpoint-url=${ENDPOINT_URL} s3 cp ${CERT_STORE_BUCKET}/ /usr/src/app/certs/ --recursive


# Perform an eapol_test against the Radius server using PEAP:
eapol_test -a $RADIUS_SERVER_IP -c /usr/src/app/eap-peap.conf   -s testingradiussecret


# Perform an eapol_test against the Radius server using EAP-TLS:
eapol_test -a $RADIUS_SERVER_IP -c /usr/src/app/eap-peap.conf   -s testingradiussecret


```
