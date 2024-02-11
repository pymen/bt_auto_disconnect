# Bluetooth Device Disconnect Script

This script is designed to monitor the activity of a Bluetooth device and disconnect it if there is no sound detected for a prolonged period. It can be useful for conserving power or managing resources when the Bluetooth device is not actively in use.

## Features

- Monitors Bluetooth audio device activity.
- Automatically disconnects Bluetooth audio device after a period of inactivity.
- Logs activity and disconnections for monitoring and troubleshooting.


## How It Works

The script performs the following actions:

1. Checks if the Bluetooth device is connected.
2. Retrieves the minutes without sound from a state file.
3. Gets the audio device index associated with the Bluetooth sink.
4. Captures noise level using the specified audio device index.
5. Logs messages with datetime.
6. Checks if there has been a prolonged period without sound.
7. Disconnects the Bluetooth device if no sound is detected for a specified duration.

## Requirements

- Linux operating system.
- PulseAudio sound server.
- Bluetooth audio device paired and connected.

## Configuration

You can configure the behavior of the script by editing the variables at the beginning of the script file:

- `STATE_FILE`: Path to the file storing the minutes without sound.
- `BLUETOOTH_DEVICE`: MAC address of the Bluetooth audio device `bluetoothctl info | grep Device`
- `LOG_FILE`: Path to the log file.
- `NUMBER`: Number of consequant periods without sound


## Usage

To use this script effectively, follow these steps:

1. Ensure that the script is executable. If not, make it executable using the command:
   ```bash
   chmod +x bluetooth_disconnect.sh
   ```

2. Configure cron to execute the script at regular intervals. Add the following line to your crontab file (`crontab -e`):
   ```cron
   XDG_RUNTIME_DIR=/run/user/1000
   * * * * * /full_path_to_the_script/bluetooth_disconnect.sh
   ```

3. Ensure that the `XDG_RUNTIME_DIR` environment variable is set correctly. It is typically set to `/run/user/1000`, where `1000` represents the user's UID (User Identifier). This directory is used for storing user-specific runtime files.

4. Restart the cron service to apply the changes:
   ```bash
   sudo service cron restart
   ```

5. To find your own user's UID, you can use the following command:
   ```bash
   id -u
   ```

## Explanation of XDG_RUNTIME_DIR

The `XDG_RUNTIME_DIR` environment variable specifies the directory where user-specific runtime files are stored. In this script, it is set to `/run/user/1000`. The number `1000` corresponds to the UID of the user running the script. This directory is used for communication and storing temporary files that are specific to a user's session. By setting this variable, the script ensures that it has access to the necessary runtime resources.

---

This README provides an overview of the script's functionality, instructions for usage, and an explanation of the `XDG_RUNTIME_DIR` environment variable. Users can refer to this README for guidance on setting up and utilizing the script effectively.
