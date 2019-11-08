#!/bin/bash
set -e

until psql "postgresql://$POSTGRES_USER@:5432" -c '\q'; do
  >&2 echo "Postgres is unavailable - waiting..."
  sleep 1
done

psql -v ON_ERROR_STOP=1 "postgresql://$POSTGRES_USER@:5432" <<-EOSQL
  DROP DATABASE IF EXISTS journal_test;
  DROP USER IF EXISTS journal_test;
  CREATE USER journal_test WITH PASSWORD '';
  CREATE DATABASE journal_test;
  GRANT ALL PRIVILEGES ON DATABASE journal_test TO journal_test;
EOSQL

psql -v ON_ERROR_STOP=1 "postgresql://$POSTGRES_USER@:5432/journal_test" <<-EOSQL
  CREATE EXTENSION IF NOT EXISTS pgcrypto;
  SELECT gen_random_uuid();
EOSQL
