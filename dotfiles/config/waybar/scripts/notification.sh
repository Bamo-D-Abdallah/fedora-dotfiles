#!/bin/bash
# ~/.config/waybar/scripts/notification.sh

# Count notifications in history
UNREAD=$(makoctl history | grep -c '^Notification')

IS_MUTED=$(makoctl mode | grep -c 'do-not-disturb')

ICON=""
if [ "$UNREAD" -gt 0 ]; then
    ICON="󱅫"  # Bell with badge icon
fi

if [ "$IS_MUTED" -gt 0 ]; then
    ICON="󰂛"
fi


# Output valid JSON for Waybar
echo "{\"text\":\"${ICON} ${UNREAD}\"}"

