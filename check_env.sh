#!/bin/bash

# Bash script used to detect and validate the environment variables.
# Chris Joakim, Microsoft, 2018/03/14

source bash_common

echo 'OSTYPE:    '$OSTYPE
echo 'dbname:    '$dbname
echo 'collname:  '$collname
echo 'footloose: '$footloose

if [ $OSTYPE == "Darwin" ]
then
    echo "we're on a Mac"
else
    echo "we're on a DSVM"
fi

echo 'done'
