#!/bin/bash

# Check the current APP_DEBUG state:
debug_state=$(grep APP_DEBUG [../].env | cut -d = -f2)

# Echo it to the user:
printf "The Current DEBUG setting is: %s \\n" "$debug_state"

# Ask if the setting needs to be changed:
read  -r -p "Do you need to change the DEBUG setting (y/n) " debug_answer "$(echo \n)"

# If the state needs to be changed - change it - else exit:
if [ "$debug_answer" != "y" ]; then
    printf "Leaving DEBUG setting as: %s \\n" "$debug_state"
    exit
fi

# Setting needs to be changed:
# Clear the current APP_DEBUG line:
sed -i '/^APP_DEBUG/d' [path_to].env

# Change the DEBUG setting:
if [ debug_state == "true" ]; then
    echo "APP_DEBUG=false" >> [path_to].env
    printf "Setting DEBUG to: false"
else
    echo "APP_DEBUG=true" >> [path_to].env
    printf "Setting DEBUG to: true"
fi

exit