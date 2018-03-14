#!/bin/bash

# This script calculates the maven CLASSPATH and produces the
# 'classpath' file, which can be sourced from a bash shell script.
#
# Chris Joakim, Microsoft, 2018/03/14

source bash_common

if [ $OSTYPE == "Darwin" ]
then
    source bin/activate    # activate the python virtualenv
    python --version
else
    source activate graph  # activate the conda virtualenv named graph
    python --version
exit
fi

rm classpath.txt
rm classpath

echo 'executing maven to determine the classpath ...'
mvn dependency:build-classpath -Dmdep.outputFile=classpath.txt

echo 'executing classpath.py to generate classpath file ...'
python3 classpath.py classpath > classpath

ls -al | grep classpath
