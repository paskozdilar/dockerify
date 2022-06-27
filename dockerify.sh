#!/usr/bin/env bash

# exit on error
which "$1" >/dev/null 2>&1 || {
    echo "ERROR: command '$1' not found" >&2
    exit 1
}

command="$1"
shift

command_path="$(which "$command")"
dependencies="$(ldd "$command_path" | grep -o "/[^ ]\+")"
dependency_dir="./dockerify"
linker="$(which ldd)"
image="dockerify:$command"

if ! docker inspect --type=image "$image" >/dev/null 2>&1
then
    # build image
    mkdir -p "$dependency_dir"
    {
        echo "FROM debian:buster-slim"
        for dependency in $command_path $dependencies
        do
            mkdir -p "${dependency_dir}${dependency%/*}"
            cp "$dependency" "${dependency_dir}${dependency}"
        done
        echo "COPY $dependency_dir /"
    } | {
        docker build \
            --tag "$image" \
            --file - \
            .
    } # >/dev/null 2>&1
    rm -rf "$dependency_dir"
fi

# run image
docker run \
    --rm \
    --interactive \
    --tty \
    --user "$(id -u)" \
    --volume "${PWD}:${PWD}" \
    --workdir "${PWD}" \
   "$image" "$command_path" "$@"
