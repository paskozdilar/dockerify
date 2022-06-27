# dockerify

Run any CLI command in a docker container:

    ./dockerify.sh ffmpeg -i input.mp4 output.mp4

This command will run under current directory and not have access to the rest of the system (except dynamically linked libraries it needs to run).

## Limitations

- builds a new image for each command
- copies dependencies instead of bind mounting them
