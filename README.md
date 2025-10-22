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

```shell

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

# Configure the environment for testing
source ./setup.sh

# Perform an eapol_test against the Radius server using PEAP for ok/fail scenarios:
#
eapol_test -a $RADIUS_SERVER_IP -c /usr/src/app/eap-peap-password-ok.conf   -s testingradiussecret

eapol_test -a $RADIUS_SERVER_IP -c /usr/src/app/eap-peap-incorrect-password.conf   -s testingradiussecret


# Perform an eapol_test against the Radius server using EAP-TLS:
#
# Successfull call
eapol_test -a $RADIUS_SERVER_IP -c /usr/src/app/eap-tls.conf   -s testingradiussecret

# CBA Fail Testing
#
eapol_test -a $RADIUS_SERVER_IP -c /usr/src/app/eap-tls-reject-client-key-not-found.conf -s testingradiussecret

eapol_test -a $RADIUS_SERVER_IP -c /usr/src/app/eap-tls-mismatch-key.conf -s testingradiussecret

```

### Local admin site set up to recieve traffic

Connect the admin console and setup an organisation to receive.

```shell

make admin-shell

./bin/rails console

```

Now in the console run the following to create an organisation:

```ruby

user = User.new({
 name: 'Joe Admin',
 email: 'admin@example.com',
  password: 'tagged-amount-gotcha',
  password_confirmation: 'tagged-amount-gotcha',
  is_super_admin: true
})
user.confirm
user.save

org = Organisation.new({
 name: 'Civil Aviation Authority',
 service_email: 'admin+civil@example.com'

})
org.save

memb = org.memberships.create(user: user)
memb.confirm!
memb.save

mou1 = Mou.create!(name:'Joe Admin', email_address: 'admin@example.com', job_role: 'Sys Admin', organisation: org, user: user, version: Mou.latest_known_version)

loc1 = Location.create!(address: 'Upper Street, Islington', postcode: 'N1 2XF', organisation: org)

```

In order to test locally with the docker network you will need to add a private
IP address for the site. The code won't work as the `address_is_not_private` in
the file `govwifi-admin/lib/use_cases/administrator/check_if_valid_ip.rb` prevents
this.

```ruby
# 1970-01-01 to bypass the admin 10 day restriction to see the "view traffic" option for the site:
ips1 = Ip.create!(address: '172.20.0.10', location: loc1, created_at: '1970-01-01')

(govwifi-admin):27:in '<top (required)>': Validation failed: Address '172.20.0.10' is a private IP address. Only public IPv4 addresses can be added. (ActiveRecord::RecordInvalid)

```

Instead, you can directly insert it using SQL:

```sql

INSERT INTO admin_govwifi.ips (
 id,
 address,
 created_at,
 updated_at,
 location_id
)
Values (
  1,
  '172.20.0.10',
  '2020-10-22 18:17',
  '2020-10-22 18:17',
  1
)

```
