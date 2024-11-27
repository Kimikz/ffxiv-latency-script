#!/bin/bash

DIRECTORY="${HOME}/ffxiv-mitigation"
MITIGATE_PY="${DIRECTORY}/mitigate.py"
FFXIV_EXE="${DIRECTORY}/ffxiv_dx11.exe"

set_iptables()
{
    # Automatically detect the primary network interface
    DEVICE_NAME=$(ip route | grep default | awk '{print $5}')

    # Ensure DEVICE_NAME is detected
    if [ -z "${DEVICE_NAME}" ]; then
        echo "Error: Could not determine the network interface."
        exit 1
    fi

    # Check if LOCAL is true for applying NAT rules
    if [ -z "${LOCAL}" ] || [ "${LOCAL}" = "true" ]; then
        # Verify if the network interface exists
        if ip addr show "${DEVICE_NAME}" &>/dev/null; then
            for ip_addr in $(ip addr show "${DEVICE_NAME}" | grep "inet\b" | awk '{print $2}'); do
                echo "Adding NAT rule for IP: ${ip_addr} on device: ${DEVICE_NAME}"
                sudo iptables -t nat -A POSTROUTING -s "${ip_addr}" -o "${DEVICE_NAME}" -j MASQUERADE
            done
        else
            echo "Error: Network device $DEVICE_NAME not found!"
            exit 1
        fi
    fi
}

download_files()
{
    # Start download of mitigate.py
    echo "Downloading mitigate.py file..."
    if [ ! -d "${DIRECTORY}" ]; then
        mkdir -p "${DIRECTORY}"
    fi

    if [ ! -f "${MITIGATE_PY}" ]; then
        curl -L "https://raw.githubusercontent.com/kimikz/ffxiv-latency-script/main/mitigate.py" \
             -o "${MITIGATE_PY}"
    fi

    if [ ! -f "${FFXIV_EXE}" ]; then
        curl -L "https://raw.githubusercontent.com/kimikz/ffxiv-latency-script/main/app/ffxiv_dx11.exe" \
             -o "${FFXIV_EXE}"
    fi
    echo "Download Complete"
}

run_mitigation()
{
    sudo python "${MITIGATE_PY}"
}

set_iptables && download_files && run_mitigation
