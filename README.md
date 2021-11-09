# Real State Finder

## Deployment
First, I took care of making the deployment work. I consider that one of the most important ways in which the application can scale in the future is through a microservice architecture and a orchestrator that allows things like creating more application instances to respond to a greater demand, load balancing and so on. That's why I made a production deployment with Docker.

The most difficult part of it was to preload the values given in the file properties.sql. For achieving this I decided to not use the typical `rake db:create` approach, and instead go on and both create the database and preload the values through SQL scripts. Then I created a bash script `startup.sh` to use as a startup whenever the container starts. It is important that this container is idempotent, because everytime the container is started, the script will run and it might preload multiple times the database with the same information.

### Development
1. `cp .env.development.example .env.development` and replace in the `.env.development` file the required values: DB_USERNAME and DB_PASSWORD with the matching values of your local Postgres server.
2. `bundle install`
3. `rake db:create`
4. `psql -d real_state_finder_development < properties.sql`
5. `psql -d real_state_finder_development < add_earth_distance_extension.sql`
6. `rails server`
7. Browse to `localhost:3000`

### Production
1. `cp .env.production.example .env.production` and replace in the `.env.production` only the value for DB_PASSWORD and set it to whatever value you want your password to be.
2. Place the `master.key` file sent in the folder config/
3. `docker-compose --env-file=.env.production up`
4. Browse to `localhost:3000`

## Testing
Following a TDD approach, I created first the tests before doing the development. I had to create a migration for creating the properties table, because the table structure was loaded in the development and production databases through the SQL script, but not in the test database. I used the `if_not_exists` flag for not creating the table if it was already created (with the SQL scripts, for example). The gems I used for the testing process are `rspec_rails` as the test framework, `factory_bot` and `faker` for creating the factories. I created some tests that check what should happen if the input is invalid and some others that check that the response is properly sent if the parameters are sent right. I decided to create a standard response structure like this:

* In case of error:
```
{
  data: [],
  message: ['Cause(s) of error'],
  status: Status error code
}
```

I used two HTTP error codes. In the case any of the inputs is invalid, it will return a 400 Bad Request error. In case no properties around are found, it will render a 404 Not Found error

* In case of success:
```
{
  data: [... retrieved information ...],
  message: '',
  status: 200
}
```

The tests can be run through the command `rspec`


## Development
First of all, I added a new SQL file called `add_earth_distance_extension.sql`. This way, the functions `earth_distance` y `ll_to_earth` are available to calculate via Postgres the distance between two points. For the development and test environments, you can run the following commands:

```
psql -d real_state_finder_development < add_earth_distance_extension.sql
psql -d real_state_finder_test < add_earth_distance_extension.sql
```

And the extension will be ready to go. For production, this script will be called in the startup script.

Additionaly, I created a presenter class for defining the fields that will be shown in the API for each property. Then, the search endpoint code is created to match the tests. I created also an utility input class with which I can use the ActiveModel validations for quickly and readably perform the input validations and show the errors. The next task will be to page the results, because as the database includes so many records and most likely the amount will increase a lot when the system scales, it is better to page the results.

For paging, I used the library `pagy`. I'm used to `will_paginate` but according to [Pagy Github](https://github.com/ddnexus/pagy), Pagy is a lot faster and lighter. For doing this, I started receiving two optional parameters in the search endpoint: `page` and `per_page`, that if not sent, take the default value of 1 and 20, respectively. I also had to change a little bit the structure of the response of the endpoint, that will be like this:

```
{
  "success": true,
  "data": {
    "data": [..the results...],
    "pagination": {
      ... some information about the pagination provided by Pagy, such as total count, items count, next and last pages
    }
  }
}
```

Consequently, I had to alter the tests for adjusting to this new behavior and I also added some tests for the paging.

Finally, I fixed some errors in the `startup.sh` script for deploying successfully the production application