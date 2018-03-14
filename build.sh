#!/bin/bash

# Compile and package the Java code in this project with Maven.
# Chris Joakim, Microsoft, 2018/03/13

mvn clean compile package

source classpath.sh

echo 'done'
