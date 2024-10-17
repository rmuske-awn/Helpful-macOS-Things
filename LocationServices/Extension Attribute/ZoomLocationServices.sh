#! /bin/bash
set -e # exit on any error

# lookup the key for Zoom
key1=$(/usr/libexec/PlistBuddy -c "Print" /var/db/locationd/clients.plist | grep -a :ius.zoom.xos | awk -F '=Dict{' '{gsub(/ /,"");gsub(":","\\:");print $1}')

# check if the key is authorized
authStatus=$(sudo /usr/libexec/PlistBuddy -c "Print :$key1:Authorized" /var/db/locationd/clients.plist)

if [[ "${authStatus}" == "true" ]]; then
    echo "<result>1</result>"
else
    echo "<result>0</result>"
fi
