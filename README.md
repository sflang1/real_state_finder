# Real State Finder

## Deployment
First, I took care of making the deployment work. I consider that one of the most important ways in which the application can scale in the future is through a microservice architecture and a orchestrator that allows things like creating more application instances to respond to a greater demand, load balancing and so on. That's why I made a production deployment with Docker.

The most difficult part of it was to preload the values given in the file properties.sql. For achieving this I decided to not use the typical `rake db:create` approach, and instead go on and both create the database and preload the values through SQL scripts. Then I created a bash script `startup.sh` to use as a startup whenever the container starts. It is important that this container is idempotent, because everytime the container is started, the script will run and it might preload multiple times the database with the same information.

### Development
1. `cp .env.development.example .env.development` and replace in the `.env.development` file the required values: DB_USERNAME and DB_PASSWORD with the matching values of your local Postgres server.
2. `bundle install`
3. `rake db:create`
4. `psql -d real_state_finder_development < properties.sql`
5. `rails server`
6. Browse to `localhost:3000`

### Production
1. `cp .env.production.example .env.production` and replace in the `.env.production` only the value for DB_PASSWORD and set it to whatever value you want your password to be.
2. `docker-compose --env-file=.env.production up`
3. Browse to `localhost:3000`

