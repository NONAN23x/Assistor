#!/bin/bash

export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DISPLAY=:1
host=$(hostname)
export WORK_DIR=/home/$USER/Documents/programs/bash
export SCRIPTS=$WORK_DIR/scripts
export CACHE_DIR="/home/$USER/.cache/assistor" # Define the cache directory

write_distro_to_cache() {
    # Check for distribution type
    if [ -f /etc/arch-release ]; then
        distro="arch"
    elif [ -f /etc/debian_version ]; then
        distro="debian"
    elif [ -f /etc/fedora-release ]; then
        distro="fedora"
    else
        echo "Unsupported distribution."
        return 1
    fi

    # Write the distro name to a file
    echo "$distro" > ~/.cache/assistor/distro

    echo "Distribution ($distro) written to cache."
}

initialize_cache_dir() {

    # Check if the directory exists
    if [ ! -d "$CACHE_DIR" ]; then
        echo "Cache directory does not exist. Creating: $CACHE_DIR"
        # Create the directory
        mkdir -p "$CACHE_DIR"
        write_distro_to_cache&
        # Check if directory was created successfully
        if [ $? -eq 0 ]; then
            echo "Cache directory initialized successfully."
        else
            echo "Failed to create cache directory."
            return 1
        fi
    else
        echo "Cache directory already exists."
    fi
}

# Call the function to ensure the cache directory is initialized
initialize_cache_dir&


# Fire off magic workers
$SCRIPTS/updater.sh
