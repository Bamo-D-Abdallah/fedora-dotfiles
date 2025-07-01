#!/bin/bash

# Get average CPU usage with decimal precision
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f", 100 - $8}')

# Determine color
if (( $(echo "$cpu_usage <= 40" | bc -l) )); then
    color="#33ff49"  # Green
elif (( $(echo "$cpu_usage <= 75" | bc -l) )); then
    color="#ffe200"  # Yellow
else
    color="#db1414"  # Red
fi

icon=""

# Output JSON for Waybar
echo "{\"text\": \"<span color='${color}'>${cpu_usage}% ${icon}</span>\", \"tooltip\": \"CPU Usage: ${cpu_usage}%\"}"

