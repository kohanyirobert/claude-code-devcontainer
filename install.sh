#!/bin/bash
# Installs the devcontainer configuration to the specified target directory
target_dir="${1:?Target directory must be set as the first argument}"

# Check if the target directory exists
if [ ! -d "$target_dir" ]
then
    echo "Target directory $target_dir does not exist"
    exit 1
fi

# Check if the .devcontainer directory exists in the target directory, if not create it
if [ ! -d "$target_dir/.devcontainer" ]
then
    mkdir "$target_dir/.devcontainer"
fi

# Check if we should include the remoteEnv configuration in devcontainer.json
if [ "${USE_REMOTE_ENV}" = "1" ]
then
    echo "Adding remoteEnv to devcontainer.json with values from local environment variables"
    jq -s '.[0] * .[1]' devcontainer.json remote-env.json > "$target_dir/.devcontainer/devcontainer.json"
else
    echo "Skipping adding remoteEnv to devcontainer.json, USE_REMOTE_ENV is not set to 1"
    cp devcontainer.json "$target_dir/.devcontainer/devcontainer.json"
fi

cp Dockerfile setup.sh "$target_dir/.devcontainer"

if [ "${USE_DOTENV}" = "1" ]
then
    if  [ -f "$target_dir/.env" ]
    then
        echo "Skipping copying .env.sample, $target_dir/.env already exists"
    else
        echo "Copying .env.sample to $target_dir/.env"
        cp .env.sample "$target_dir/.env"
    fi
else
    echo "Skipping copying .env.sample, USE_DOTENV is not set to 1"
fi

