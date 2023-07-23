#!/bin/bash

# Get Data
HARDWARE_DATA=$(system_profiler SPHardwareDataType)
MACHINE=$(echo "$HARDWARE_DATA" | awk -F ": " '/Model Name/ {print $NF}')
IDENTIFIER=$(echo "$HARDWARE_DATA"  | awk -F ": " '/Model Identifier/ {print $NF}')
INJECT=$(echo "$HARDWARE_DATA" | awk '/CPU Names/{getline;print}' | awk '{print $1}' | sed -e 's/"//g' -e 's/-.*//')
# Machine icon parsing
MACHINE_ICON="$alfred_workflow_cache/machine.png"

if [[ ! -f "$MACHINE_ICON" ]]; then
  mkdir -p "$(dirname "$MACHINE_ICON")"
  osascript getMacIcon.applescript "$MACHINE_ICON"
fi

# HARDWARE parsing
SYSTEM_SERIAL=$(echo "$HARDWARE_DATA" | awk '/Serial Number/ {print $NF}')
if echo "$HARDWARE_DATA" | grep -q 'Processor'; then
  PROC_SPEED=$(echo "$HARDWARE_DATA" | awk '/Processor Speed/ {print substr($0, index($0,$3))}')
  PROC_NAME=$(echo "$HARDWARE_DATA" | awk '/Processor Name/ {print substr($0, index($0,$3))}')
  PROC="$PROC_SPEED $PROC_NAME"
  CPU_ICON="icons/cpu-intel.png"
else
  PROC=$(echo "$HARDWARE_DATA" | awk '/Chip/ {print substr($0, index($0,$2))}')
  CPU_ICON="icons/cpu-arm.png"
fi


# MEMORY parsing
MEMORY_DATA=$(system_profiler SPMemoryDataType)
SYS_MEM=$(echo "$HARDWARE_DATA" | awk '/Memory/ {print substr($0, index($0,$2))}')
MEM_SPEED=$(echo "$MEMORY_DATA" | awk '/Speed/ {print substr($0, index($0,$2))}' | head -1)
MEM_TYPE=$(echo "$MEMORY_DATA" | awk '/Type/ {print substr($0, index($0,$2))}' | head -1)


# GRAPHICS parsing
GRAPHICS_DATA=$(system_profiler SPDisplaysDataType)

NUMGFX=$(echo "$GRAPHICS_DATA" | grep 'Bus' | awk '{print NR}')

if [ "$NUMGFX" == 1 ]; then
    GFXSUB1=$(echo "$GRAPHICS_DATA" | grep 'Resolution:' | awk 'NR==1 {print $1,$2,$3,$4}')
fi

if [ "$NUMGFX" == 2 ]; then
    GFXSUB2=$(echo "$GRAPHICS_DATA" | grep 'Resolution:' | awk 'NR==1 {print $1,$2,$3,$4}')
fi

GRAPHICS1_CHIPSET=$(echo "$GRAPHICS_DATA" | grep 'Chipset Model' | awk 'NR==1 {print substr($0, index($0,$3))}')
GRAPHICS1_VRAM=$(echo "$GRAPHICS_DATA" | grep 'VRAM' | awk 'NR==1 {print " " substr($0, index($0,$4))}')
GRAPHICS2_CHIPSET=$(echo "$GRAPHICS_DATA" | grep 'Chipset Model' | awk 'NR==2 {print substr($0, index($0,$3))}')
GRAPHICS2_VRAM=$(echo "$GRAPHICS_DATA" | grep 'VRAM' | awk 'NR==2 {print " " substr($0, index($0,$4))}')

GFXVENDOR1=$(echo "$GRAPHICS_DATA" | grep 'Vendor' | awk 'NR==1 {print $2}')
if [ "$GFXVENDOR1" == Apple ]; then
    GRAPHICS1_ICON=icons/cpu-arm.png

elif [ "$GFXVENDOR1" == Intel ]; then
    GRAPHICS1_ICON=icons/graphicsintelhd.png

elif [ "$GFXVENDOR1" == NVIDIA ]; then
    GRAPHICS1_ICON=icons/graphicsnvidia.png
fi

GFXVENDOR2=$(echo "$GRAPHICS_DATA" | grep 'Vendor' | awk 'NR==2 {print $2}')
if [ "$GFXVENDOR2" == Intel ]; then
    GRAPHICS2_ICON=icons/graphicsintelhd.png

elif [ "$GFXVENDOR2" == NVIDIA ]; then
    GRAPHICS2_ICON=icons/graphicsnvidia.png
fi


# SOFTWARE parsing
SOFTWARE_DATA=$(system_profiler SPSoftwareDataType)
VERSION=$(echo "$SOFTWARE_DATA" | awk '/System Version/ {print substr($0, index($0,$3))}')


# Time Since Boot parsing
THEN=$(sysctl kern.boottime | awk '{print $5}' | sed "s/,//")
NOW=$(date +%s)
DIFF=$((NOW-THEN))

DAYS=$((DIFF/86400));
DIFF=$((DIFF-(DAYS*86400)))
HOURS=$((DIFF/3600))
DIFF=$((DIFF-(HOURS*3600)))
MINUTES=$((DIFF/60))

function format {
if [ "$1" == 1 ]; then
    echo "$1" "$2"

elif [ "$1" == 0 ]; then
    echo ''

else
    echo "$1" "$2"'s'
fi
}

UPTIME="$(format $DAYS "day") $(format $HOURS "hour") $(format $MINUTES "minute")"


# macOS version parsing
if [ "$(sw_vers -productVersion | awk '{print substr($1,1,2)}')" == 10 ]; then
    SWVER=$(sw_vers -productVersion | awk '{print substr($1,1,5)}')
else
    SWVER=$(sw_vers -productVersion | awk '{print substr($1,1,2)}')
fi

if [ "$SWVER" == 10.14 ]; then
    OSICON=icons/10.14.png

elif [ "$SWVER" == 10.15 ]; then
    OSICON=icons/10.15.png

elif [ "$SWVER" == 11 ]; then
    OSICON=icons/11.png

elif [ "$SWVER" == 12 ]; then
    OSICON=icons/12.png

elif [ "$SWVER" == 13 ]; then
    OSICON=icons/13.png

elif [ "$SWVER" == 14 ]; then
    OSICON=icons/14.png
fi

# Alfred Feedback
cat << EOB
{"items": [

  {
    "title": "$MACHINE ($IDENTIFIER)",
    "subtitle": "Machine (Model Identifier)",
    "arg": "$MACHINE",
    "icon": {
      "path": "$MACHINE_ICON"
    },
    "mods": {
      "alt": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=cpuspec&cc=$INJECT",
        "subtitle": "Open Apple Specifications Site for This Hardware"
      },
      "ctrl": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=psp&cc=$INJECT",
        "subtitle": "Open Apple Support Site for This Hardware"
      }
    }
  },

  {
    "title": "$PROC",
    "subtitle": "Processor",
    "arg": "$PROC",
    "icon": {
      "path": "$CPU_ICON"
    },
    "mods": {
      "alt": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=cpuspec&cc=$INJECT",
        "subtitle": "Open Apple Specifications Site for This Hardware"
      },
      "ctrl": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=psp&cc=$INJECT",
        "subtitle": "Open Apple Support Site for This Hardware"
      }
    }
  },

  {
    "title": "$SYS_MEM $MEM_SPEED $MEM_TYPE",
    "subtitle": "Memory",
    "arg": "$SYS_MEM $MEM_SPEED $MEM_TYPE",
    "icon": {
      "path": "icons/ram.png"
    },
    "mods": {
      "alt": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=cpuspec&cc=$INJECT",
        "subtitle": "Open Apple Specifications Site for This Hardware"
      },
      "ctrl": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=psp&cc=$INJECT",
        "subtitle": "Open Apple Support Site for This Hardware"
      }
    }
  },

  {
    "title": "$GRAPHICS1_CHIPSET$GRAPHICS1_VRAM",
    "subtitle": "$GFXSUB1",
    "arg": "$GRAPHICS1_CHIPSET$GRAPHICS1_VRAM",
    "icon": {
      "path": "$GRAPHICS1_ICON"
    },
    "mods": {
      "alt": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=cpuspec&cc=$INJECT",
        "subtitle": "Open Apple Specifications Site for This Hardware"
      },
      "ctrl": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=psp&cc=$INJECT",
        "subtitle": "Open Apple Support Site for This Hardware"
      }
    }
  },

  {
    "title": "$GRAPHICS2_CHIPSET$GRAPHICS2_VRAM",
    "subtitle": "$GFXSUB2",
    "arg": "$GRAPHICS2_CHIPSET$GRAPHICS2_VRAM",
    "icon": {
      "path": "$GRAPHICS2_ICON"
    },
    "mods": {
      "alt": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=cpuspec&cc=$INJECT",
        "subtitle": "Open Apple Specifications Site for This Hardware"
      },
      "ctrl": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=psp&cc=$INJECT",
        "subtitle": "Open Apple Support Site for This Hardware"
      }
    }
  },

  {
    "title": "$SYSTEM_SERIAL",
    "subtitle": "Serial",
    "arg": "$SYSTEM_SERIAL",
    "icon": {
      "path": "icons/applecare.png"
    },
    "mods": {
      "alt": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=cpuspec&cc=$INJECT",
        "subtitle": "Open Apple Specifications Site for This Hardware"
      },
      "ctrl": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=psp&cc=$INJECT",
        "subtitle": "Open Apple Support Site for This Hardware"
      }
    }
  },

  {
    "title": "$VERSION",
    "subtitle": "System Version (Build)",
    "arg": "$VERSION",
    "icon": {
      "path": "$OSICON"
    },
    "mods": {
      "alt": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=cpuspec&cc=$INJECT",
        "subtitle": "Open Apple Specifications Site for This Hardware"
      },
      "ctrl": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=psp&cc=$INJECT",
        "subtitle": "Open Apple Support Site for This Hardware"
      }
    }
  },

  {
    "title": "$UPTIME",
    "subtitle": "Time Since Boot",
    "arg": "$UPTIME",
    "icon": {
      "path": "icons/uptime.png"
    },
    "mods": {
      "alt": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=cpuspec&cc=$INJECT",
        "subtitle": "Open Apple Specifications Site for This Hardware"
      },
      "ctrl": {
        "valid": true,
        "arg": "http://support-sp.apple.com/sp/index?page=psp&cc=$INJECT",
        "subtitle": "Open Apple Support Site for This Hardware"
      }
    }
  }

]}
EOB
