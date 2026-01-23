FROM alpine:3.23.2@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62

RUN addgroup -S app && adduser -S -G app app

WORKDIR /usr/src/app

COPY Gemfile ./

RUN apk --no-cache add --virtual .build-deps build-base ruby-dev mysql-dev && \
    apk --no-cache add aws-cli mysql-client curl ruby ruby-bundler jq \
    freeradius freeradius-radclient wpa_supplicant && \
    bundle install && \
    apk del .build-deps

COPY . .

RUN mkdir -p /usr/src/app/certs && \
    chown -R app:app /usr/src/app

RUN echo "cat << 'EOF'" >> /etc/profile && \
    echo "   ______           _       ___  _____ " >> /etc/profile && \
    echo "  / ____/___ _   __| |     / (_)/ __(_) " >> /etc/profile && \
    echo " / / __/ __ \ | / /| | /| / / // /_/ /  " >> /etc/profile && \
    echo "/ /_/ / /_/ / |/ / | |/ |/ / // __/ /   " >> /etc/profile && \
    echo "\____/\____/|___/  |__/|__/_//_/ /_/    " >> /etc/profile && \
    echo "                                        " >> /etc/profile && \
    echo "    Welcome to GovWifi Development      " >> /etc/profile && \
    echo "EOF" >> /etc/profile && \
    echo "echo ''" >> /etc/profile && \
    echo "echo 'Useful Links:'" >> /etc/profile && \
    echo "echo '  🛠️ Developer Helper:  http://localhost:4567'" >> /etc/profile && \
    echo "echo '  🔐 Admin Interface:   http://localhost:38080'" >> /etc/profile && \
    echo "echo '  📨 Notify Pit:        http://localhost:4040'" >> /etc/profile && \
    echo "echo ''" >> /etc/profile && \
    echo "echo '- Please run \"source ./setup.sh\" to set up the certificates.'" >> /etc/profile && \
    echo "echo '- To login to the admin please run \"make admin-db-setup\" where you ran \"make shell\" from.'" >> /etc/profile && \
    echo "echo ''" >> /etc/profile

USER app

CMD ["ruby", "app.rb"]
