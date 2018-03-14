#!/bin/bash

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
exit
fi

echo 'done'
