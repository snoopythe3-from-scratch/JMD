#!/bin/bash

# Windows-style fake terminal
PS1="C:\\> "
RETRY_DELAY=1  # seconds

# URL encoding function
urlencode() {
    local string="${1}"
    local strlen=${#string}
    local encoded=""
    local pos c o

    for (( pos=0; pos<strlen; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9]) o="${c}" ;;
            *) printf -v o '%%%02x' "'$c"
        esac
        encoded+="${o}"
    done
    echo "${encoded}"
}

# Spinner animation function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  Please wait..." "${spinstr:0:1}"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
    done
    printf "                         \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
}

# API call function with indefinite retries
get_refusal() {
    local input=$1
    local encoded_input=$(urlencode "$input")
    local url="https://text.pollinations.ai/Refuse%20this%20command%20that%20the%20user%20entered%20into%20a%20fake%20terminal:%20${encoded_input}.%20Act%20like%20a%20terminal.%20Keep%20your%20response%20in%20one%20line.%20Don't%20curse.?model=evil"
    local response=""

    while [[ -z "$response" ]]; do
        response=$(curl -s "$url" | \
                 sed -e 's/<[^>]*>//g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | \
                 grep -v "^$" | \
                 head -n 1)
        
        if [[ -z "$response" ]]; then
            sleep $RETRY_DELAY
        fi
    done
    echo "$response"
}

# Main terminal loop
while true; do
    # Read input with Windows-style path
    IFS= read -r -e -p "$PS1" input
    
    # Exit conditions
    if [[ $? -ne 0 || "$input" == "exit" ]]; then
        echo "Goodbye!"
        exit 0
    fi

    # Skip empty input
    [[ -z "$input" ]] && continue

    # Start API call in background
    get_refusal "$input" > .response.txt &
    pid=$!
    
    # Show spinner while waiting
    spinner $pid
    
    # Get and display response
    response=$(cat .response.txt)
    rm -f .response.txt
    printf "\r%s\n" "$response"
done
