# README


### Installation
To install and run this app you will need Docker installed. Once Docker is installed, run the following:

```sh
# build the docker images
docker compose build

# after build start the application
docker compose up

# navigate to locahost:3000/forecasts to view
```

### View the UI
Navigate to: http://localhost:3000/forecasts

### Tests
```sh
docker compose run -e "RAILS_ENV=test" app ./bin/rails test
```

### Documentation

