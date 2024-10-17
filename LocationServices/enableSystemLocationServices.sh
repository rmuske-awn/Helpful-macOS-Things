#! /bin/bash


# check if location services is enabled
location_enabled=$(sudo -u "_locationd" defaults -currentHost read "/var/db/locationd/Library/Preferences/ByHost/com.apple.locationd" LocationServicesEnabled)

if [[ "$location_enabled" = "1" ]]; then
    # Location Services already enabled
    echo "Location Services already enabled"
else
    # Enable Location Services
    sudo defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 1
    # Restart location services daemon
    sudo killall locationd
fi