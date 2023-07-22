#!/bin/bash

# Default values
username="pufferai"  # replace with your Docker Hub username
name="base"
tag="latest"

# Parse command-line arguments for name, tag, and username
while getopts n:t:u: flag
do
    case "${flag}" in
        n) name=${OPTARG};;
        t) tag=${OPTARG};;
        u) username=${OPTARG};;
    esac
done

# Function for building Docker image
build() {
    # Check if a Docker container with the same name already exists
    if [ "$(docker ps -aq -f name=${name})" ]; then
        # Stop and remove the existing container
        echo "A Docker container with the name ${name} already exists. Stopping and removing it..."
        docker stop ${name}
        docker rm ${name}
    fi
    echo "Building Docker image ${username}/${name}:${tag}..."
    docker build -t ${username}/${name}:${tag} .
}

# Function for testing Docker image
test() {
    # Check if a Docker container with the same name already exists
    if [ "$(docker ps -aq -f name=${name})" ]; then
        # If the container exists and is stopped, start it
        echo "A Docker container with the name ${name} already exists. Starting it..."
        docker start ${name}
    else
        # If the container does not exist, run a new one
        echo "Running Docker image ${username}/${name}:${tag} and executing shell..."
        docker run --name ${name} -it ${username}/${name}:${tag} bash
    fi
    # Attach to the running container
    docker exec -it ${name} bash
}

# Function for pushing Docker image
push() {
    echo "Pushing Docker image ${username}/${name}:${tag}..."
    docker push ${username}/${name}:${tag}
}

# Function for displaying usage instructions
usage() {
    echo "Usage: $0 [-n name] [-t tag] [-u username] command"
    echo "Commands:"
    echo "  build"
    echo "  test"
    echo "  push"
}

# Main script
if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi

case $1 in
    build)
        build
        ;;
    test)
        test
        ;;
    push)
        push
        ;;
    *)
        usage
        ;;
esac