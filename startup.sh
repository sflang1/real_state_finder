#!/bin/bash

# while connection refused, this means, the db server has not started yet
curl db:5432
while [ $? == 7 ]; do
  curl db:5432
done

psql postgresql://$POSTGRES_USERNAME:$POSTGRES_PASSWORD@db < create-database.sql 2>&1 | grep 'ERROR'

if ! [[ $? == 0 ]] ; then
  # The database doesn't exist!
  echo "Creating the extensions..."
  psql postgresql://$POSTGRES_USERNAME:$POSTGRES_PASSWORD@db/real_state_finder_production < add_earth_distance_extension.sql

  echo "Filling the database with script data..."
  psql postgresql://$POSTGRES_USERNAME:$POSTGRES_PASSWORD@db/real_state_finder_production < properties.sql
fi