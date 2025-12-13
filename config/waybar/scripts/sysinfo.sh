#!/bin/bash
# System info for waybar tooltip

# CPU usage
cpu=$(awk '/^cpu / {usage=100-($5*100/($2+$3+$4+$5+$6+$7+$8))} END {printf "%.0f", usage}' /proc/stat)

# Temperature (try different sensors)
temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
if [[ -n "$temp" ]]; then
    temp=$((temp / 1000))
else
    temp="N/A"
fi

# Memory
read -r total used <<< $(free -b | awk '/^Mem:/ {printf "%.1f %.1f", $2/1073741824, $3/1073741824}')
mem_pct=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2*100}')

# Output JSON
echo "{\"text\": \"󰍛\", \"tooltip\": \"Memory: ${used}GB (${mem_pct}%)\\nCPU: ${cpu}%\\nTemp: ${temp}°C\"}"
