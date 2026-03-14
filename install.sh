#!/bin/bash
# Installs the devcontainer configuration to the specified target directory
target="${1:?Target directory must be set as the first argument}"
mkdir -p "$target" "$target/.devcontainer"
echo "Copying devcontainer configuration to $target/.devcontainer"
cp devcontainer.json Dockerfile setup.sh "$target/.devcontainer"
if [ -f $target/.env ]
then
    echo "Skipping copying .env.sample, $target/.env already exists"
else
    echo "Copying .env.sample to $target/.env"
    cp .env.sample "$target/.env"
fi
