#!/bin/bash

# dexec is a function that runs a command in a Docker container
dexec() {
    if [[ $# -eq 0 ]]; then
        set_container
    elif [[ -f /tmp/dexec-container-name ]]; then
        local container_name
        container_name=$(get_container)
        blink_magenta "Using container: $container_name"
        docker exec "$container_name" "$@"
    else
        silly_error "No container set. Run without arguments to set a container."
    fi
}

# get_container returns the name of the container to use, or an error if no container is set
get_container() {
    if [[ -f /tmp/dexec-container-name ]]; then
        cat /tmp/dexec-container-name 2>/dev/null
    fi
}

# set_container uses fzf and docker ps to select a container to use
set_container() {
    container_name=$(docker ps --format "{{.Names}}" | fzf --header-lines=1)
    if [[ -n $container_name ]]; then
        echo "$container_name" > /tmp/dexec-container-name
    fi
    echo "No container selected"
}

blink_magenta() {
    blink "$(magenta "$*")"
}
