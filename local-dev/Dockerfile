FROM alpine:latest

WORKDIR /usr/src/app

RUN apk --no-cache add --virtual .build-deps build-base && \
    apk --no-cache add aws-cli mysql-dev curl ruby mysql-client jq \
    freeradius freeradius-radclient wpa_supplicant && \
    apk del .build-deps

COPY . .

ENTRYPOINT ["/bin/sh"]
