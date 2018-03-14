#!/bin/bash

# Build and execute the GremlinLoader Java program.
# Chris Joakim, Microsoft, 2018/03/14

source bash_common

echo 'Recompile, package, and create the classpath file per mvn ...'
source build.sh

echo 'Define and export the classpath as $CP ...'
source classpath

#echo 'Check connectivity to the Azure CosmosDB Graph database ...'
#java -classpath $CP org.cjoakim.azure.db.cosmos.gremlin.GremlinClient --check-connection

echo 'Invoke the load process ...'
java -classpath $CP org.cjoakim.azure.db.cosmos.gremlin.GremlinClient --load-database > tmp/java_load_db.txt

#echo 'Execute queries vs the DB ...'
#java -classpath $CP org.cjoakim.azure.db.cosmos.gremlin.GremlinClient --query

echo 'done'
