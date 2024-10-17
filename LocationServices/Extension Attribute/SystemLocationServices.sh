#! /bin/bash

# Report if location services is disabled
location_enabled=$(sudo -u "_locationd" defaults -currentHost read "/var/db/locationd/Library/Preferences/ByHost/com.apple.locationd" LocationServicesEnabled)

# 1 = Enabled
# 0 = Disabled

echo "<result>$location_enabled</result>"
