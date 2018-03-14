#!/bin/bash

# Chris Joakim, Microsoft, 2018/03/14
# ./execute_load_queries.sh

dbname=dev
collname=moviespy

python cosmos_graph.py execute_load_queries $dbname $collname > tmp/execute_load_queries.txt

echo 'done'
