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

If you make changes to any of the checked out apps you will want to rerun the
above command to rebuild and test your changes.

## CI/CD

The GitHub action triggered when creating a PR and the AWS CodeBuild job which runs the acceptance tests when building images for the tested apps both call `make test` to execute the tests.

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
