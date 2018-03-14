#!/bin/bash

# Azure Data Science Virtual Machine (DSVM) version of this script.
# Chris Joakim, Microsoft, 2018/03/12
# ./create_load_queries.sh

dbname=dev
collname=movies
outfile=data/processed/load_queries.txt

source activate gremlin  # activate the conda virtualenv

rm $outfile

python cosmos_graph.py create_load_queries $dbname $collname

wc  $outfile

echo 'done'
