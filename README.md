# README

### Description
Take an address as input and get current weather data, including upcoming days. Cache the data by zip code for 30 minutes to make retrieving data quicker.

### Prereqs
You need Docker installed

### Setup
First, rename the `.env.example` file to `.env`. In addition, you will need to edit this file and include the provided API key. The API key should be pasted into the value of `WEATHER_API_KEY` substituting `api-key-here` for the actual API key that you were provided. Your file should look like the following:

```properties
RAILS_ENV=development
PORT=3000
# Weather API Key
WEATHER_API_KEY=api-key-here
# Memory Store
MEMCACHED_SERVICE_HOST=memcached
MEMCACHED_SERVICE_PORT=11211

```
Once that has been done, you need to build the docker images
```sh
# build the docker images
docker compose build
```

### Running the app

```sh
# start and run the application
docker compose up

# from there you should be able to navigate to http://locahost:3000/forecasts
```

### Tests
```sh
# To run the provided tests
docker compose run -e "RAILS_ENV=test" app ./bin/rails test
```

### Documentation

