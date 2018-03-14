#!/bin/bash

# Chris Joakim, Microsoft, 2018/03/14
# ./execute_load_queries.sh

source bash_common

if [ $OSTYPE == "Darwin" ]
then
    source bin/activate    # activate the python virtualenv
    python --version
else
    source activate graph  # activate the conda virtualenv named graph
    python --version
fi

python cosmos_graph.py execute_load_queries $dbname $collname > tmp/execute_load_queries.txt

echo 'done'
