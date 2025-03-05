#!/bin/zsh
# ------------------------------------------------------------------------------
# Script to fully disable the root user on macOS and validate compliance
# ------------------------------------------------------------------------------
appname="DisableRootUser"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"
log="$logandmetadir/$appname.log"

# Create log directory
[[ -d "$logandmetadir" ]] || mkdir -p "$logandmetadir"
exec &> >(tee -a "$log")

# Function to disable root
DisableRootUser() {
    echo "$(date) | Checking root account status..."

    # Check 1: Is the root password set? (ShadowHash = enabled)
    if dscl . -read /Users/root AuthenticationAuthority 2>/dev/null | grep -q "ShadowHash"; then
        echo "$(date) | Root account is enabled (password set). Disabling..."
    else
        echo "$(date) | Root account is already disabled."
        exit 0
    fi

    # Step 1: Invalidate root password
    echo "$(date) | Setting root password to invalid..."
    dscl . -create /Users/root Password "*"

    # Step 2: Use macOS tool to disable root
    echo "$(date) | Running dsenableroot -d..."
    dsenableroot -d -u "${USER}" -p "${PASSWORD}"  # Replace with admin credentials if needed

    # Step 3: Remove AuthenticationAuthority (if still present)
    echo "$(date) | Removing AuthenticationAuthority..."
    dscl . -delete /Users/root AuthenticationAuthority 2>/dev/null

    # Validation
    echo "$(date) | Validating root account status..."
    if dscl . -read /Users/root AuthenticationAuthority 2>/dev/null | grep -q "ShadowHash"; then
        echo "$(date) | FAILURE: Root account is still enabled."
        exit 1
    else
        echo "$(date) | SUCCESS: Root account fully disabled."
        exit 0
    fi
}

# Begin Script
echo "\n$(date) | Starting $appname\n"
DisableRootUser
