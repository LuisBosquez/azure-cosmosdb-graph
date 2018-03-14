#!/bin/bash

# Chris Joakim, Microsoft, 2018/03/12
# ./create_load_queries.sh

dbname=dev
collname=movies
outfile=data/processed/load_queries.txt

kevin_bacon=nm0000102
lori_singer=nm0001742
footloose=tt0087277

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
