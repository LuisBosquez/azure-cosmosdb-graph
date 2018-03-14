#!/bin/bash

# Chris Joakim, Microsoft, 2018/03/14
# ./create_load_queries.sh

source bash_common

outfile=data/processed/load_queries.txt

if [ $OSTYPE == "Darwin" ]
then
    source bin/activate    # activate the python virtualenv
    python --version
else
    source activate graph  # activate the conda virtualenv named graph
    python --version
fi

rm $outfile

python cosmos_graph.py create_load_queries $dbname $collname

wc  $outfile

echo 'grep for footloose'
cat $outfile | grep $footloose

echo 'grep for kevin_bacon'
cat $outfile | grep $kevin_bacon

echo 'grep for lori_singer'
cat $outfile | grep $lori_singer

echo 'grep for kevin_bacon and lori_singer'
cat $outfile | grep $kevin_bacon | grep $lori_singer

echo ''
echo 'done'
