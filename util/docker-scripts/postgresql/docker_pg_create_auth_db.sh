#!/bin/bash

set -e
set -u

function create_user_and_database() {
	local database=$1
	local user=$2
	local password=$3
	local createuser=${4-false}
	echo "### CREATING DATABASE '$database'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname="$POSTGRES_DB" <<-EOSQL
	    CREATE DATABASE $database;
EOSQL
  if [ "${createuser}" = true ]; then
    echo "### CREATING USER with all privileges '$user' on database '$database'."
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname="$POSTGRES_DB" <<-EOSQL
	    CREATE USER "$user" WITH PASSWORD '$password';
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $user;
EOSQL
  fi
}

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
	echo "### Multiple database creation requested"
  local IFS=";"
	for line in $POSTGRES_MULTIPLE_DATABASES; do
	  local IFS=" "
	  create_user_and_database $(echo $line)
	  done;
	echo "Multiple databases created"
fi