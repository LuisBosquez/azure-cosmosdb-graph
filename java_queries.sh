#!/bin/bash

# Build and execute the GremlinLoader Java program.
# Chris Joakim, Microsoft, 2018/03/14

source bash_common

echo 'Recompile, package, and create the classpath file per mvn ...'
source build.sh

echo 'Define and export the classpath as $CP ...'
source classpath

echo 'Execute queries vs the DB ...'
java -classpath $CP org.cjoakim.azure.db.cosmos.gremlin.GremlinClient --query

echo 'done'
