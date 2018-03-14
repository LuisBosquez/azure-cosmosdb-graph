#!/bin/bash

# This script calculates the maven CLASSPATH and produces the
# 'classpath' file, which can be sourced from a bash shell script.
#
# Chris Joakim, Microsoft, 2018/03/13

mvn dependency:build-classpath -Dmdep.outputFile=classpath.txt

echo 'executing classpath.py to generate classpath file'
python3 classpath.py classpath > classpath
