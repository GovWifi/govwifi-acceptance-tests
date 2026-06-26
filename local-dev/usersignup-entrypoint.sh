#!/bin/sh
set -e

echo "Migrating database..."
bundle exec rake db:migrate
echo "Done migrating database. Starting Server..."
exec bundle exec puma -p 3000 --quiet --threads 8:32
