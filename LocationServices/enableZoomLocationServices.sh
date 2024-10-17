#! /bin/bash

# Exit 2 = unable to enable location services
# Exit 3 = Clients database does not currently exist
# Exit 4 = Zoom doesn't exist in Clients

clients="/var/db/locationd/clients.plist"

# Is location services enabled? 
location_enabled=$(sudo -u "_locationd" defaults -currentHost read "/var/db/locationd/Library/Preferences/ByHost/com.apple.locationd" LocationServicesEnabled)
if [[ "$location_enabled" = "1" ]]; then
	echo "Location Services are enabled, moving on..."
else
	echo "Location Services disabled. Enabling them..."
    # Jamf Policy to enable Location Services
    jamf policy -event EnableLocation
    sleep 3
	location_enabled=$(sudo -u "_locationd" defaults -currentHost read "/var/db/locationd/Library/Preferences/ByHost/com.apple.locationd" LocationServicesEnabled)
    if [[ "$location_enabled" = "0" ]]; then
    	echo "Unable to enable location services...exiting"
        exit 2
    fi
fi

# Check if the clients database exists
if [[ -f "$clients" ]]; then
    # Get the UUID for the application in the locationd clients database
    key1=$(/usr/libexec/PlistBuddy -c "Print" /var/db/locationd/clients.plist | grep -a :ius.zoom.xos | awk -F '=Dict{' '{gsub(/ /,"");gsub(":","\\:");print $1}' | head -1)
    echo "$clients already exists! Moving on..."

    # Check if Zoom key exists
    if [[ -z "${key1}" ]]; then
        echo "Client key for Zoom not found"
        exit 4
    else

        # Create a backup of the existing client location services file
        cp $clients /var/db/locationd/clients.BAK

        # Create an extra working backup
        cp $clients /private/var/tmp/

        # Convert our working backup client plist to xml for editing
        plutil -convert xml1 /private/var/tmp/clients.plist

        # Use Plist Buddy to mark-up client plist, enabling Zoom' location services
        /usr/LibExec/PlistBuddy -c "Set :$key1:Authorized true" /private/var/tmp/clients.plist
        # Check return for last command
        if [[ "$?" = "1" ]]; then
            # If we failed to set the key
            echo "Authorized key seems to be missing...re-adding the key"
            # Add the authorizedkey as a new key for the app
            /usr/LibExec/PlistBuddy -c "Add :$key1:Authorized bool true" /private/var/tmp/clients.plist
            echo "Adding 'authorized' key for Zoom app location services returned: $?"
        fi
        echo "Setting Zoom app location services returned: $?"

        # Convert back to binary
        plutil -convert binary1 /private/var/tmp/clients.plist

        # Put the updated client plist into appropriate dir
        cp /private/var/tmp/clients.plist $clients

        # Kill and restart the location services daemon and remove our temp file
        killall locationd
        rm /private/var/tmp/clients.plist
        
    fi
else
    # Clients database doesn't exist
    # Need application to request access
    echo "$clients does not exist...exiting"
    exit 3
fi

exit $?