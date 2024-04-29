#!/bin/bash


prompt_for_update() {
    
    # Send a notification and capture the output
    decision=$(
        notify-send "System Update Available" "Do you want to perform the system update now?" \
        -A "Yes" -A "No" -a $host
        )

    # Print decision based on output
    echo "Output from notify-send: $decision"

    # Simulate action based on captured output
    if [ "$decision" == 0 ]; then
        echo "Updating system..."
        updater&
    else
        echo "Not updating system."
    fi
}

check_updates() {
    # Define the cache directory and file
    DISTRO_FILE="$CACHE_DIR/distro"
    PREVIOUS_UPDATE_FILE="$CACHE_DIR/previous_update"

    # Check if the previous update timestamp exists
    if [ -f "$PREVIOUS_UPDATE_FILE" ]; then
        # Read the timestamp from the file
        last_update=$(cat "$PREVIOUS_UPDATE_FILE")
        # Get the current timestamp in seconds since epoch
        current_time=$(date +%s)
        # Convert last update time to seconds since epoch
        last_update_time=$(date -d "$last_update" +%s)
        # Calculate time difference in hours
        hours_since_last_update=$(( (current_time - last_update_time) / 3600 ))

        # Check if the last update was less than 24 hours ago
        if [ "$hours_since_last_update" -lt 12 ]; then
            notify-send -a $host "System" "Last system update was less than 12 hours ago. Exiting..."
            return 0
        fi
    fi

    # Read the distribution from the cache file
    if [ -f "$DISTRO_FILE" ]; then
        distro=$(cat "$DISTRO_FILE")
    else
        echo "Distribution file does not exist. Please ensure the cache is initialized properly."
        return 1
    fi

    echo "Detected distribution from cache: $distro"

    # Check for updates based on the distribution
    case $distro in
        "arch")
            # Use checkupdates for Arch, which is part of the pacman-contrib package
            updates=$(checkupdates)
            ;;
        "debian")
            # For Debian, update the package lists and check for upgradable packages
            konsole -e sudo apt update > /dev/null
            updates=$(apt list --upgradable)
            ;;
        "fedora")
            # For Fedora, use dnf to check for updates
            updates=$(dnf check-update)
            ;;
        *)
            echo "Unsupported or unknown distribution: $distro"
            return 1
            ;;
    esac

    # Output the available updates or a message if there are none
    if [ -z "$updates" ]; then
        echo "No updates available."
    else
        echo "Updates available"
        prompt_for_update
    fi
}


updater() {
    DISTRO_FILE="$CACHE_DIR/distro"

    # Ensure the distro file exists
    if [ ! -f "$DISTRO_FILE" ]; then
        echo "Distribution file does not exist. Please ensure the cache is initialized properly."
        return 1
    fi

    # Read the distribution from the cache file
    distro=$(cat "$DISTRO_FILE")

    echo "Starting update for $distro..."

    # Open a new terminal window to perform the update interactively
    case $distro in
        "arch")
            konsole -e "sudo pacman -Syu" && notify-send 'Update Complete' 'Your system is up to date.'; date "+%Y-%m-%d %H:%M:%S" > "$CACHE_DIR/previous_update";
            ;;
        "debian")
            xterm -e "sudo apt update && sudo apt upgrade" && notify-send 'Update Complete' 'Your system is up to date.'; date "+%Y-%m-%d %H:%M:%S" > "$CACHE_DIR/previous_update"
            ;;
        "fedora")
            xterm -e "sudo dnf upgrade --refresh" && notify-send 'Update Complete' 'Your system is up to date'; date "+%Y-%m-%d %H:%M:%S" > "$CACHE_DIR/previous_update"
            echo "Unsupported or unknown distribution: $distro"
            return 1
            ;;
    esac
}

check_updates