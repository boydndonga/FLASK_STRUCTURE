#!/usr/bin/env bash


# Creating new app


# Initializing  git
git init
touch .gitignore
echo "should i create a README? y/n"
read ANSWER

if [ "${ANSWER^^}" == 'Y' ]; then
    touch README.md
    echo "created README"
else
    echo "README not created"
fi


cat >> .gitignore << EOF

virtual/
*.pyc
start.sh

EOF