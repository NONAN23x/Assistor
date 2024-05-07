#!/bin/bash


greet_user() {
    # Get the current hour using the date command
    current_hour=$(date +"%H")

    # Determine the greeting based on the current hour
    if [ "$current_hour" -ge 6 ] && [ "$current_hour" -lt 12 ]; then
        greeting="Good morning ☀️"
    elif [ "$current_hour" -ge 12 ] && [ "$current_hour" -lt 18 ]; then
        greeting="Good afternoon 🌞"
    elif [ "$current_hour" -ge 18 ] && [ "$current_hour" -lt 22 ]; then
        greeting="Good evening 🌆"
    else
        greeting="Good night 🌙"
    fi


    # Get the user's name from the environment
    user_name=$(whoami)

    # Send the greeting as a notification
    notify-send -a $host "Hi there" "$greeting, $user_name!"
}

# Call the function
greet_user
