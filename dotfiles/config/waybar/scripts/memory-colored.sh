#!/bin/bash

# Get total and used memory (in GiB)
read total used <<< $(free -g | awk '/Mem:/ {print $2, $3}')

# Get more precise values in GB with decimals
read total_f used_f <<< $(free -m | awk '/Mem:/ {printf "%.1f %.1f", $2/1024, $3/1024}')

# Calculate used percentage
used_percent=$(awk "BEGIN { printf \"%.1f\", ($used_f / $total_f) * 100 }")

# Choose color
if (( $(echo "$used_percent <= 50" | bc -l) )); then
    color="#33ff49"  # Green
elif (( $(echo "$used_percent <= 75" | bc -l) )); then
    color="#ffe200"  # Yellow
else
    color="#db1414"  # Red
fi

icon=""

# Output JSON for Waybar
echo "{\"text\": \"<span color='${color}'>${used_f}G/${total_f}G ${icon}</span>\", \"tooltip\": \"RAM Usage: ${used_percent}% \"}"

