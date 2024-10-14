#!/bin/bash

# Define variables
IMAGE_NAME="frontend"
IMAGE_TAG="dev"
CONTAINER_NAME="dev_courses_frontend"
PORT="8080"

# Define color variables
WHITE='\033[1;37m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
HIGH='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define text weight
BOLD='\033[1m'
NORMAL='\033[0m'

# Function to display the help menu with color formatting
show_help() {
    echo
    echo -e "${BOLD}${YELLOW}╔══════════════════════════════════════════════════════════════╗"
    echo -e "${BOLD}${YELLOW}║         ${BOLD}${WHITE}VLM IMAGE CLASSIFIER FRONTEND ${HIGH}v0.0.1-alpha${YELLOW}           ║"
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ ${CYAN}${BOLD}AVAILABLE${NORMAL} ${YELLOW}   ║ ${BOLD}${WHITE}COMMAND                                       ${YELLOW}║${NC}"
    echo -e "${YELLOW}║ ${CYAN}${BOLD}COMMANDS${NORMAL} ${YELLOW}    ║ ${BOLD}${WHITE}DESCRIPTION                                   ${YELLOW}║${NC}"
    echo -e "${YELLOW}║══════════════════════════════════════════════════════════════║${NC}"
    echo -e "${YELLOW}║  ${CYAN}${BOLD}build${WHITE}${NORMAL}       ${YELLOW}-${WHITE} Build the Docker image                        ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${CYAN}${BOLD}start${WHITE}${NORMAL}       ${YELLOW}-${WHITE} Start the Docker container                    ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${CYAN}${BOLD}dev${WHITE}${NORMAL}         ${YELLOW}-${WHITE} Start a dev webserver                         ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${CYAN}${BOLD}ip${WHITE}${NORMAL}          ${YELLOW}-${WHITE} Display application access URL                ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${CYAN}${BOLD}down${WHITE}${NORMAL}        ${YELLOW}-${WHITE} Stop and remove the Docker container          ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${CYAN}${BOLD}shell${WHITE}${NORMAL}       ${YELLOW}-${WHITE} Access the container's shell                  ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${CYAN}${BOLD}fresh_dev${WHITE}${NORMAL}   ${YELLOW}-${WHITE} Starts a dev server, builds a fresh image,    ${YELLOW}║${NC}"
    echo -e "${YELLOW}║                ${BOLD}${WHITE}and also removes the old container and ${YELLOW}       ║${NC}"
    echo -e "${YELLOW}║                ${BOLD}${WHITE}replaces it with a new one                    ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Function to build the Docker image
build_image() {
    echo
    echo -e "${BLUE}Building the Docker image...${NC}"
    sudo docker build . -t $IMAGE_NAME:$IMAGE_TAG
    if [ $? -eq 0 ]; then
        echo -e "${HIGH}Docker image built successfully.${NC}"
    else
        echo -e "${RED}Docker build failed.${NC}"
        exit 1
    fi
}

# Function to start the Docker container
start_container() {
    echo
    echo -e "${CYAN}\nSTEP: STARTING DOCKER CONTAINER\n-----------------------------${NC}\n"
    sudo docker run -d -p $PORT:$PORT --name $CONTAINER_NAME $IMAGE_NAME:$IMAGE_TAG
    if [ $? -eq 0 ]; then
        echo -e "${HIGH}Container started successfully.${NC}"
    else
        echo -e "${RED}Failed to start the container.${NC}"
        exit 1
    fi
}

# Function to display application access URL
show_app_url() {
    echo
    IP=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
    if [ -z "$IP" ]; then
        echo -e "${RED}${BOLD}\nContainer is not running. Please start the container first.\n${NC}"
    else
        echo -e "${HIGH}- Continer address: ${WHITE}http://$IP:$PORT\n${NC}"
        echo -e "${HIGH}- Serve prod build with http-server at ${WHITE}http://$IP:$PORT\n${NC}"
    fi
}

# Command: Stop and remove the container
down_container() {
    echo
    echo -e "${CYAN}\nSTEP: STOPPING AND REMOVING THE CONTAINER...\n-----------------------------${NC}\n"
    sudo docker stop $CONTAINER_NAME 2>/dev/null
    sudo docker rm $CONTAINER_NAME 2>/dev/null
    echo -e "${HIGH}Container stopped and removed.${NC}\n"
}

# Command: Access the container shell
access_shell() {
    echo
    echo -e "${CYAN}\nSTEP: ACCESS CONTAINER SHELL\n"
    if [ "$(sudo docker ps -q -f name=$CONTAINER_NAME)" ]; then
        echo -e "${BLUE}Accessing the container shell...${NC}"
        sudo docker exec -it $CONTAINER_NAME "$@"
    else
        echo -e "${RED}${BOLD}Container is not running. Please start the container first.${NC}"
    fi
}

# Function to start the frontend in dev mode
dev () {
    echo
    echo -e "${CYAN}\nSTEP: STARTING FRONTEND IN DEV MODE\n-----------------------------${NC}\n"
    sudo docker exec -it $CONTAINER_NAME yarn dev --host
}

# Parse the argument and call the appropriate function
case $1 in
    build)
        build_image
        ;;
    start)
        start_container
        show_app_url
        ;;
    ip)
        show_app_url
        ;;
    down)
        down_container
        ;;
    shell)
        shift
        access_shell "$@"
        ;;
    dev)
        show_app_url
        dev
        ;;
    fresh_dev)
        down_container
        build_image
        start_container
        show_app_url
        dev
        ;;
    *)
        show_help
        exit 1
        ;;
esac