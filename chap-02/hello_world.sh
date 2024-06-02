#!/bin/bash

# set -ex

## Version 1
# echo "Hello, world!"

## Version 2
# name=""
# if [[ $name == "" ]]; then
#   echo "Hello, world!"
# fi

## Version 3
name="Bob"
if [[ $name == "" ]]; then
  echo "Hello, world!"
else
  echo "Hello, $name!"
fi
