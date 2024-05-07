#!/bin/bash


query_weather() {
    CACHE_DIR="/home/$USER/.cache/assistor"
    API_KEY=$(cat $CACHE_DIR/WEATHER_API_TOKEN)
    CITY_ID="1269843"  # Replace with your city ID
    URL="http://api.openweathermap.org/data/2.5/weather?id=$CITY_ID&appid=$API_KEY&units=metric"
    WEATHER_FILE="$CACHE_DIR/weather"

    # Fetch weather data
    weather_data=$(curl -s "$URL")

    # Check if the weather data was fetched successfully
    if [[ $? -eq 0 && "$weather_data" != "" ]]; then
        # Process and save the weather data
        echo "$weather_data" | jq '.' > "$WEATHER_FILE"
        echo "Weather data saved to $WEATHER_FILE"
    else
        echo "Failed to fetch weather data."
    fi

}

notify_weather() {
    WEATHER_FILE="$CACHE_DIR/weather"

    # Check if the weather file exists
    if [ ! -f "$WEATHER_FILE" ]; then
        echo "Weather data file does not exist."
        return 1
    fi

    # Extract weather condition and feels like temperature
    weather=$(jq -r '.weather[0].description' "$WEATHER_FILE")
    feels_like=$(jq -r '.main.feels_like' "$WEATHER_FILE")

    # Create the notification message
    message="Weather: $weather, feels like ${feels_like}°C"

    # Send the notification
    notify-send -a $host "Current Weather" "$message"
}

query_weather

notify_weather