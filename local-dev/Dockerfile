FROM alpine:latest

WORKDIR /usr/src/app

RUN apk --no-cache add --virtual .build-deps build-base && \
    apk --no-cache add mysql-dev curl ruby mysql-client jq \
    freeradius freeradius-radclient && \
    apk del .build-deps

COPY . .

ENTRYPOINT ["/bin/sh"]
