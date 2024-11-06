#!/bin/bash

# Define threshold values
CPU_THRESHOLD=80
MEMORY_THRESHOLD=75
DISK_THRESHOLD=90
LOG_FILE="C:/Users/suraj dev yadav/Documents/SystemHealthMonitoringScript/system_health.log"  # Change to your desired log file path

# Create log directory if it does not exist
mkdir -p "C:/Users/suraj dev yadav/Documents/SystemHealthMonitoringScript/"

# Create log file if it does not exist
touch "$LOG_FILE"

# Function to check CPU usage
check_cpu() {
    cpu_usage=$(wmic cpu get loadpercentage | findstr /r "[0-9]")
    if [ -n "$cpu_usage" ] && [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        echo "$(date): High CPU usage detected: ${cpu_usage}%" >> "$LOG_FILE"
    fi
}

# Function to check memory usage
check_memory() {
    total_memory=$(wmic OS get TotalVisibleMemorySize | findstr /r "[0-9]")
    free_memory=$(wmic OS get FreePhysicalMemory | findstr /r "[0-9]")
    used_memory=$((total_memory - free_memory))
    
    if [ "$total_memory" -gt 0 ]; then
        memory_usage=$((used_memory * 100 / total_memory))
        if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
            echo "$(date): High memory usage detected: ${memory_usage}%" >> "$LOG_FILE"
        fi
    else
        echo "$(date): Unable to retrieve total memory." >> "$LOG_FILE"
    fi
}

# Function to check disk usage
check_disk() {
    disk_usage=$(wmic logicaldisk get size,freespace | findstr /r "[0-9]")
    
    while read -r line; do
        size=$(echo $line | awk '{print $1}')
        free=$(echo $line | awk '{print $2}')
        if [ -n "$size" ] && [ -n "$free" ]; then
            used=$((size - free))
            if [ "$size" -gt 0 ]; then
                disk_percentage=$((used * 100 / size))
                if [ "$disk_percentage" -gt "$DISK_THRESHOLD" ]; then
                    echo "$(date): High disk usage detected: ${disk_percentage}%" >> "$LOG_FILE"
                fi
            fi
        fi
    done <<< "$disk_usage"
}

# Function to check number of running processes
check_processes() {
    process_count=$(tasklist | find /c /v "")
    echo "$(date): Number of running processes: ${process_count}" >> "$LOG_FILE"
}

# Run all checks
check_cpu
check_memory
check_disk
check_processes
