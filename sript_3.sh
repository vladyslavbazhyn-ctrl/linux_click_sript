#!/bin/bash

echo "Scanning system for mouse devices..."

MOUSE_EVENT_ID=$(grep -i -A 4 "Name=.*Touchpad" /proc/bus/input/devices | grep -o "event[0-9]\+" | head -n 1)

if [ -z "$MOUSE_EVENT_ID" ]; then
    echo "ERROR: No mouse or touchpad found automatically."
    echo "You may need to manually specify the ID in the script."
    exit 1
fi

# The direct path to the hardware device
DEVICE="/dev/input/$MOUSE_EVENT_ID"
echo "Auto-detected Mouse: $MOUSE_EVENT_ID"

# --- CHECK PERMISSIONS ---
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: Wayland blocks normal users from spying on hardware."
  echo "Please run this script with sudo: sudo ./mouse_spy.sh"
  exit 1
fi

echo "--- MOUSE ACTIVITY MONITOR ---"
echo "Listening to hardware: $DEVICE"
echo "Waiting for clicks"
echo "Press Ctrl+C to stop."
echo "------------------------------"

COUNTER=0

# --- THE HACK ---
# 1. 'cat' reads the raw binary device file.
# 2. 'hexdump' converts binary to text lines so we can count them.
# 3. We filter for a specific pattern to try and slow it down slightly.
cat "$DEVICE" | hexdump -v -e '24/1 "%02x " "\n"' | while read -r line; do
    
    bytes=($line)
    
    event_type="${bytes[16]}"
    event_value="${bytes[20]}"
    
    if [ "$event_type" == "01" ] && [ "$event_value" == "01" ]; then
    ((COUNTER++))
    
    # Print to screen (overwriting the same line)
    echo -ne "Total Clicks: $COUNTER\r"
    
    fi
    
done
