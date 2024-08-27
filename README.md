# Weather Forecast Application

## Description

This application accepts an address as input, retrieves current weather data along with a 4-day forecast, and caches the data by zip code for 30 minutes to reduce API calls and improve performance. If the data is cached, an indicator shows that the result is pulled from the cache.

## Prerequisites

1. Ensure that you have Docker installed on your machine. The application is designed to run in a containerized environment for easy setup and consistent deployment.

2. Signup and register for a FREE weather api key found here: [https://www.weatherapi.com/](https://www.weatherapi.com/). This key will be used to fill in the `your-api-key-here` value in the `.env` file below.

## Setup

1. **Environment Variables**:

   Copy the `.env.example` file to `.env` and edit this file to include your API key.

   ```sh
   cp .env.example .env
   ```

   Example:

   ```sh
   PORT=3000
   # Weather API Key
   WEATHER_API_KEY=your-api-key-here
   # Memory Store
   MEMCACHED_SERVICE_HOST=memcached
   MEMCACHED_SERVICE_PORT=11211
   ```



3. **Build the Docker Images**:
   
   Run the command to build the Docker images.

   ```sh
   docker compose build
   ```

## Running the Application

1. **Start the Application**:

   Use the command to start the application. Once started, you can access the application at `http://localhost:3000/forecasts`.

   ```sh
   docker compose up
   ```

2. **Navigating**:
   
   [http://localhost:3000/forecasts](http://localhost:3000/forecasts) - Use the web interface to input an address (street, city, state, and zip code), and view the current and upcoming weather conditions.

## Tests

1. **To run the provided unit tests**:
   Use the command to run the tests in the Docker environment.

   ```sh
   docker compose run -e "RAILS_ENV=test" app ./bin/rails test
   ```

## Future Enhancements

### Geolocation Integration

- **Description**: Enhance address input precision by integrating a geolocation API, such as Google Maps Geocoding API. This would allow for more accurate weather forecasts by converting addresses into geographic coordinates.
- **Benefits**: Increases accuracy and user trust in the weather data provided.
- **Implementation Considerations**: Requires API key management, error handling for API limits or failures, and potentially complex UI changes to accommodate more precise location inputs.

## Reflection on Approach

### Minimal Validation

- **Chosen Strategy**: Initially, the application accepts input with minimal validation to simplify development and focus on core functionalities.
- **Benefits**: Quicker deployment and initial testing. It lowers the barrier for user interaction by reducing the number of steps required to obtain weather forecasts.
- **Future Considerations**: As user demand and feature requirements grow, more robust validation can be implemented. This might include integrating address verification APIs to ensure that the addresses inputted are valid and correspond correctly to their respective zip codes.

### Scalability and Simplicity

- **Current Implementation**: The current caching strategy and simple user interface are designed to meet the initial requirements without overcomplicating the system architecture.
- **Future Scalability**: The application is built with scalability in mind. As it grows, the infrastructure can evolve to include load balancing, more sophisticated caching mechanisms, and possibly a move to cloud services that scale dynamically based on demand.

### Use of Docker

- **Strategic Decision**: Using Docker for containerization from the start ensures that the application environment is consistent across different development and production setups, simplifying deployment and scaling.
- **Future Enhancements**: As the application scales, Docker can be integrated into a more complex container orchestration system like Kubernetes to manage deployment and operation at scale.

## Architecture Overview

- **WeatherApi Class**:
  Handles interaction with the external weather API. It fetches and parses weather data for a given zip code and returns a structured response, including current and forecasted weather.
- **WeatherManager::WeatherFetcher**:
  This service is responsible for fetching the weather data. It checks the cache first and, if no data is found, calls the `WeatherApi` to retrieve the data and then caches it for 30 minutes.
- **ForecastsController**:
  The controller handles user input (address details), validates the zip code, and retrieves weather data via the `WeatherFetcher` service. The data is then rendered to the user or errors are handled appropriately.

## Design Patterns Used

- **Service Object Pattern**:
  The weather fetching logic is encapsulated in the `WeatherFetcher` service class, following the Service Object pattern to maintain clean separation of concerns.
- **Caching Strategy**:
  Data fetched from the weather API is cached by zip code using Rails' caching mechanism to improve performance and reduce external API calls.

## Scalability Considerations

- **Caching**:
  By caching the weather data for 30 minutes by zip code, the application reduces API call volume significantly, especially for users repeatedly querying the same zip codes.
- **Separation of Concerns**:
  The use of service objects ensures that logic related to fetching and parsing weather data is separate from controller responsibilities, improving maintainability and scalability as the application grows.

## Error Handling

If the API request fails or invalid data is provided, appropriate error messages are displayed to the user, and errors are logged for monitoring and debugging.

## Additional Notes

- **Detailed Comments**:
  The codebase includes detailed comments explaining each method's purpose and functionality. This ensures that anyone reading or maintaining the code can quickly understand its behavior.
- **Naming Conventions**:
  The application follows consistent naming conventions to align with enterprise-grade code standards. Classes, methods, and variables are named with clarity to improve readability and maintainability.
- **Encapsulation & Code Reuse**:
  By using separate service classes and modules, the application ensures encapsulation, avoiding monolithic code. Methods are designed to handle single responsibilities, which promotes code reuse across the project.
