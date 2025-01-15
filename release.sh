#!/bin/bash

VERSION="" # Leave empty as it will be asked below
BUILDER_NAME="mybuilder"
PLATFORMS="linux/arm/v7,linux/arm64/v8,linux/amd64"
BUILD_CONTEXT="."

CPU_CORES=8

### credits to th33xitus for the script base
clear
set -e

### set color variables
green=$(echo -en "\e[92m")
yellow=$(echo -en "\e[93m")
red=$(echo -en "\e[91m")
cyan=$(echo -en "\e[96m")
default=$(echo -en "\e[39m")

warn_msg(){
  echo -e "${red}<!!!!> $1${default}"
}

status_msg(){
  echo; echo -e "${yellow}###### $1${default}"
}

ok_msg(){
  echo -e "${green}>>>>>> $1${default}"
}

title_msg(){
  echo -e "${cyan}$1${default}"
}

get_date(){
  current_date=$(date +"%y%m%d-%H%M")
}

print_unkown_cmd(){
  ERROR_MSG="Invalid command!"
}

print_msg(){
  if [[ "$ERROR_MSG" != "" ]]; then
    echo -e "${red}"
    echo -e "#########################################################"
    echo -e " $ERROR_MSG "
    echo -e "#########################################################"
    echo -e "${default}"
  fi
  if [ "$CONFIRM_MSG" != "" ]; then
    echo -e "${green}"
    echo -e "#########################################################"
    echo -e " $CONFIRM_MSG "
    echo -e "#########################################################"
    echo -e "${default}"
  fi
}

clear_msg(){
  unset CONFIRM_MSG
  unset ERROR_MSG
}

if [[ ${UID} == '0' ]]; then
    warn_msg "You cant run this script as Root!"
    exit 1
fi

status_msg "Please enter the new release"
while true; do
    read -p "$(echo -e "$cyan 1.2.3 as example: $default")" new_version
    if [[ -n "$new_version" ]]; then
        VERSION="$new_version"
        break
    else
        warn_msg "Version cannot be empty. Please try again."
    fi
done

TAG="tludwigdev/mooncord:v$VERSION"

if docker buildx ls | grep -q "$BUILDER_NAME"; then
  echo "Builder '$BUILDER_NAME' already exists."
else
  echo "Creating builder '$BUILDER_NAME'..."
  docker buildx create --name "$BUILDER_NAME" --use --driver-opt "env.BUILDKIT_CPU_COUNT=$CPU_CORES"
fi

echo "Inspecting builder '$BUILDER_NAME'..."
docker buildx inspect "$BUILDER_NAME" --bootstrap

if ! docker buildx ls | grep -q "\*.*$BUILDER_NAME"; then
  echo "Setting builder '$BUILDER_NAME' as default..."
  docker buildx use "$BUILDER_NAME"
fi

status_msg "Clear Build cache"
docker buildx prune --all -f

status_msg "Build $TAG"

docker buildx build --push --platform "$PLATFORMS" \
  --tag "$TAG" \
  --tag "tludwigdev/mooncord:latest" \
  "$BUILD_CONTEXT"