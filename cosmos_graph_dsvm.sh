#!/bin/bash

# Azure Data Science Virtual Machine (DSVM) version of this script.
# Chris Joakim, Microsoft, 2018/03/12
# ./cosmos_graph.sh > tmp/cosmos_graph.log

source activate gremlin  # activate the conda virtualenv

export dbname=dev
export collname=movies

drop_graph=0
create_load_queries=1
execute_load_queries=0

if [ $drop_graph -gt 0 ]
then
    echo 'python: drop_graph ...'
    python cosmos_graph.py drop_graph $dbname $collname
fi

if [ $create_load_queries -gt 0 ]
then
    echo 'python: create_load_queries ...'
    python cosmos_graph.py create_load_queries $dbname $collname
fi

if [ $execute_load_queries -gt 0 ]
then
    echo 'python: execute_load_queries ...'
    python cosmos_graph.py execute_load_queries $dbname $collname
fi

echo 'done'
