FROM alpine:3.23.2@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62

RUN addgroup -S app && adduser -S -G app app

RUN apk --no-cache add --virtual .build-deps build-base && \
    apk --no-cache add aws-cli mysql-dev curl ruby mysql-client jq \
    freeradius freeradius-radclient wpa_supplicant && \
    apk del .build-deps

USER app

WORKDIR /usr/src/app

COPY . .

ENTRYPOINT ["/bin/sh"]
