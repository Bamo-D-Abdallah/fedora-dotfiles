#!/bin/bash

# Read raw temp in millidegrees
temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp)
tempC=$((temp_raw / 1000))

# Determine color and icon
if [ "$tempC" -lt 50 ]; then
    color="#71c7ec"
    icon=""
elif [ "$tempC" -lt 70 ]; then
    color="#ffe200"
    icon=""
else
    color="#db1414"
    icon=""
fi

# Output JSON for Waybar with matching color for icon and temperature
echo "{\"text\": \"<span color='${color}'>${tempC}°C ${icon}</span>\", \"tooltip\": \"CPU Temperature: ${tempC}°C\"}"
