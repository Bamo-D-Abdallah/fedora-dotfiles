#!/bin/bash

# Check if an argument was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <normal|critical|low>"
  exit 1
fi

URGENCY="$1"

# Validate urgency argument
if [[ "$URGENCY" != "normal" && "$URGENCY" != "critical" && "$URGENCY" != "low" ]]; then
  echo "Invalid urgency level. Use one of: normal, critical, low"
  exit 1
fi

# Set icon and title based on urgency
case "$URGENCY" in
  normal)
    ICON="dialog-information"
    TITLE="Normal Notification"
    MESSAGE="This is a normal urgency notification."
    ;;
  critical)
    ICON="dialog-error"
    TITLE="Critical Notification"
    MESSAGE="This is a critical urgency notification!"
    ;;
  low)
    ICON="dialog-information"
    TITLE="Low Notification"
    MESSAGE="This is a low urgency notification."
    ;;
esac

# Send notification
notify-send -u "$URGENCY" -i "$ICON" "$TITLE" "$MESSAGE"

