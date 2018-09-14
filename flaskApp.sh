#!/usr/bin/env bash


# Creating new app


# Initializing  git
git init
touch .gitignore
echo "should i create a README? y/n"
read answer
if answer == y; then
    touch README.md
    echo "created README"
fi


cat >> .gitignore << EOF

virtual/
*.pyc
start.sh

EOF