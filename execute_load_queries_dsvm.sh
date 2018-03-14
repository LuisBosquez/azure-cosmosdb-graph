#!/bin/bash

# Azure Data Science Virtual Machine (DSVM) version of this script.
# Chris Joakim, Microsoft, 2018/03/12
# ./execute_load_queries.sh

dbname=dev
collname=movies

source activate gremlin  # activate the conda virtualenv

python cosmos_graph.py execute_load_queries $dbname $collname

echo 'done'
