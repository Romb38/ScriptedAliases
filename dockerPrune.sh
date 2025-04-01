#!/bin/bash

#alias="dockerprune"

echo "Warning: These commands will delete all unused volumes, images, containers, networks, and data."
read -p "Do you really want to delete everything? [Y/n]: " confirmation

if [[ "$confirmation" == "Y" || "$confirmation" == "y" ]]; then
    echo "Deleting..."
    
    # Remove all unused volumes
    echo "Step 1/5: Removing all unused volumes..."
    docker volume prune --all --force
    
    # Remove all unused images
    echo "Step 2/5: Removing all unused images..."
    docker image prune --all --force
    
    # Remove all stopped containers
    echo "Step 3/5: Removing all stopped containers..."
    docker container prune --force
    
    # Remove all unused networks
    echo "Step 4/5: Removing all unused networks..."
    docker network prune --force
    
    # Remove all unused system data
    echo "Step 5/5: Performing a full system cleanup..."
    docker system prune --all --force
    
    echo "Cleanup completed successfully."
else
    echo "Operation canceled."
fi
