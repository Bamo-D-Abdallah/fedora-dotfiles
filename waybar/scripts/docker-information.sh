#!/bin/bash

# Get number of running containers
active_containers=$(docker ps -q | wc -l)

# Icon for Waybar
icon=""

# Set color based on active containers count
if [ "$active_containers" -eq 0 ]; then
    color="#888888"  # gray color
else
    color="#71c7ec"  # cyan or any color you want when active
fi

# Header with adjusted column widths
header=$(printf "%-20s %-14s %-24s %-10s\n" "Image" "ID" "Name" "Status")

# Container info with same adjusted widths
container_info=$(docker container ls -a --format '{{.Image}}|{{.ID}}|{{.Names}}|{{.Status}}' | while IFS='|' read -r image id name status; do
    printf "%-20s %-14s %-24s %-10s\n" "$image" "$id" "$name" "$status"
done)

# Escape newlines for Waybar JSON
tooltip=$(printf "%s\n%s" "$header" "$container_info" | sed ':a;N;$!ba;s/\n/\\n/g')

# Output JSON for Waybar, using Pango markup for color
echo "{\"text\": \"<span foreground='${color}'>${icon}  ${active_containers}</span>\", \"tooltip\": \"${tooltip}\"}"


