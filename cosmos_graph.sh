#!/bin/bash

# Chris Joakim, Microsoft, 2018/03/14
# ./cosmos_graph.sh > tmp/cosmos_graph.log

source bash_common

drop_graph=0
create_load_queries=1
execute_load_queries=0

if [ $OSTYPE == "Darwin" ]
then
    source bin/activate    # activate the python virtualenv
    python --version
else
    source activate graph  # activate the conda virtualenv named graph
    python --version
fi

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
