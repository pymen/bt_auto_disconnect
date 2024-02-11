#!/bin/bash

BLUETOOTH_DEVICE="46:AE:59:A8:AF:B8"  # Bluetooth device MAC address
STATE_FILE="$(dirname "$0")/disconnect_bt8.state"
LOG_FILE="$(dirname "$0")/disconnect_bt8.log"

# Function to read the minutes without sound from the state file
read_minutes_without_sound() {
    if [ -f "$STATE_FILE" ]; then
        minutes_without_sound=$(cat "$STATE_FILE")
    else
        minutes_without_sound=0
    fi
}

# Function to write the minutes without sound to the state file
write_minutes_without_sound() {
    echo "$1" > "$STATE_FILE"
}

# Function to check if the Bluetooth device is connected
is_device_connected() {
    # Check if the Bluetooth device is connected
    connected=$(bluetoothctl info $BLUETOOTH_DEVICE | grep "Connected: yes")
    if [ -n "$connected" ]; then
        return 0
    else
        return 1
    fi
}

# Function to get the audio device index associated with bluez_sink
get_audio_device_index() {
    index=$(pacmd list-sinks | awk '/monitor source:|name:/ {print $0};' | grep -A 1 bluez_sink | grep -oP '\d+$')
    echo "$index"
}

# Function to capture noise level using the specified audio device index
capture_noise_level() {
    local device_index="$1"
    noise_level=$(parec --device="$device_index" --raw --channels=1 --latency=2 2>/dev/null | od -N2 -td2 | head -n1 | cut -d' ' -f2- | tr -d ' ')
    echo "$noise_level"
}

# Function to log messages with datetime
log_message() {
    local datetime=$(date +'%Y-%m-%d %H:%M')
    local message="$datetime - $1"
    echo "$message" | tee -a "$LOG_FILE"
}

# Main function
main() {
    log_message "-----------------------------------------------"
    log_message "Checking if the Bluetooth device is connected..."
    # Check if the Bluetooth device is connected
    if ! is_device_connected; then
        log_message "Bluetooth device is not connected. Resetting minutes without sound and stopping the script."
        # Reset minutes_without_sound and stop the script if the device is not connected
        write_minutes_without_sound 0
        exit 0
    fi

    log_message "Bluetooth device is connected."

    # Retrieve the minutes without sound from the state file
    log_message "Retrieving minutes without sound from the state file..."
    read_minutes_without_sound
    log_message "Minutes without sound: $minutes_without_sound"

    # Get the audio device index associated with bluez_sink
    log_message "Getting the audio device index associated with bluez_sink..."
    device_index=$(get_audio_device_index)
    log_message "Audio device index: $device_index"
    
    # Get the noise level using the specified audio device index
    log_message "Capturing noise level using audio device index $device_index..."
    noise_level=$(capture_noise_level "$device_index")
    log_message "Noise level: $noise_level"
    
    # Check if the noise level is zero
    if [ "$noise_level" -eq 0 ]; then
        # Increment the variable tracking consecutive minutes without sound
        ((minutes_without_sound++))
        log_message "No sound detected. Incrementing minutes without sound: $minutes_without_sound"
        log_message "Minutes without sound: $minutes_without_sound"
    else
        # Reset the variable tracking consecutive minutes without sound
        minutes_without_sound=0
        echo "" > "$LOG_FILE"  # Clear log file
        log_message "Sound detected. Resetting minutes without sound."
    fi

    # Check if there have been 30 or more consecutive minutes without sound
    if [ "$minutes_without_sound" -ge 30 ]; then
        log_message "30 or more consecutive minutes without sound detected. Disconnecting the Bluetooth device."
        bluetoothctl disconnect $BLUETOOTH_DEVICE  # Disconnect the Bluetooth device
        minutes_without_sound=0
        write_minutes_without_sound "$minutes_without_sound"
        exit 0
    fi
    
    # Store the updated minutes without sound to the state file
    log_message "Storing the updated minutes without sound to the state file..."
    write_minutes_without_sound "$minutes_without_sound"
}

# Run the main function
main
