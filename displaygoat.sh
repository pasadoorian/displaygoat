#!/bin/bash
#
#
# Warning, this is a crappy script.
#
# Display Goat (displaygoat.sh) Version 0.1
#
# Author: Paul Asadoorian (paul@securityweekly.com)
# 
# Initial Release Date: 9/22/2016
#
# This script accepts one parameter, a directory name, and displays all images in that directory. It uses feh and attempts to be secure about it.
#
# Currently this script is used by web applications to allow users to change the images being displayed.
#
#
# security stuff
# see https://sipb.mit.edu/doc/safe-shell/
set -euf -o pipefail

display_usage() { 
	echo -e "\nUsage:\n$0 [directoryname] \n" 
} 

# Set the base directory
BASEDIR=/home/pi

# Allows users, such as www-data, to call script even though they do not have a home dir
export HOME=/tmp

# Write all messages to this file
# We have to do this so web frameworks can easily read the output
OUTPUT=/home/pi/display.output

echo "$0 is starting" | tee $OUTPUT 

# Make sure we only got one arguement
if [ "$#" -ne 1 ]; then
        echo "$0: exactly 1 arguments expected, you gave me $#" | tee $OUTPUT
	display_usage
        exit 3
fi

# Make sure there are no funky characters in the parameter
if ! [[ "$1" =~ ^[a-zA-Z0-9] ]]; then
        echo "$0: Cut the crap, I only except alphanumeric arguements, bitch." | tee $OUTPUT
	display_usage
        exit 3
fi

# Make sure the file path exists
if  [ ! -d "$BASEDIR/$1" ]; then
	echo "$0: Uhhh, dude, like that directory doesn't exist! No images for you! Exiting." | tee $OUTPUT
	display_usage
        exit 3
fi

# Make sure the director is not empty
if [ ! "$(ls -A ${BASEDIR}/${1})" ]; then
	echo "$0: Yo punk, the directory you gave me is empty! I will put in some pics of yo mamma, or not. Bye bye." | tee $OUTPUT
	display_usage
        exit 3
fi

# Grab the show name from the user
SHOW=$1

# Set the display to the main display
export DISPLAY=:0.0

# Kill all previously running processes
# Its okay if this fails, so we append the "always true" e.g. !! :
killall feh || :
if [ "$?" -ne 0 ]; then 
	echo "killall command failed, not a big deal" | tee $OUTPUT
else
	echo "Successfully stopped all previous running instances" | tee $OUTPUT
fi

# Execute the magic command that displays images in a folder
feh -R 3 -Y -x -q -D 5 -B black -F -Z -z -r ${BASEDIR}/${SHOW}/ &
if [ "$?" -ne 0 ]; then
        echo "feh command failed, this is  a big deal" | tee $OUTPUT
	exit $?
else
        echo "Success: displaying the images for $SHOW" | tee $OUTPUT
fi

exit $?
