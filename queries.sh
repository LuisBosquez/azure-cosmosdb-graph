#!/bin/bash

# Execute several queries of the CosmosDB/GraphDB and capture their output
# to several txt files in the queries/ directory.
#
# Run with:
#   ./queries.sh
#
# Chris Joakim, Microsoft, 2018/03/14

source bash_common

if [ $OSTYPE == "Darwin" ]
then
    source bin/activate    # activate the python virtualenv
    python --version
else
    source activate graph  # activate the conda virtualenv named graph
    python --version
exit
fi

echo 'using database:   '$dbname
echo 'using collection: '$collname

echo 'removing the output files ...'
rm queries/*.txt

###

echo 'querying countv ...'
python cosmos_graph.py query $dbname $collname countv > queries/countv.txt

###

echo 'querying movie footloose ...'
python cosmos_graph.py query $dbname $collname movie footloose > queries/movie_footloose.txt

echo 'querying movie pretty_woman ...'
python cosmos_graph.py query $dbname $collname movie pretty_woman > queries/movie_pretty_woman.txt

echo 'querying movie cotton_club ...'
python cosmos_graph.py query $dbname $collname movie cotton_club > queries/movie_cotton_club.txt

###

echo 'querying person kevin_bacon ...'
python cosmos_graph.py query $dbname $collname person   kevin_bacon > queries/person_kevin_bacon.txt

echo 'querying person richard_gere ...'
python cosmos_graph.py query $dbname $collname person   richard_gere > queries/person_richard_gere.txt

echo 'querying person julia_roberts ...'
python cosmos_graph.py query $dbname $collname person   julia_roberts > queries/person_julia_roberts.txt

echo 'querying person nm0001742 (Lori Singer) ...'
python cosmos_graph.py query $dbname $collname person   nm0001742 > queries/person_nm0001742.txt

###

echo 'querying movies that kevin_bacon was in ...'
python cosmos_graph.py query $dbname $collname in kevin_bacon > queries/kevin_bacon_in.txt

echo 'querying movies that julia_roberts was in ...'
python cosmos_graph.py query $dbname $collname in julia_roberts > queries/julia_roberts_in.txt

echo 'querying movies that richard_gere was in ...'
python cosmos_graph.py query $dbname $collname in richard_gere > queries/richard_gere_in.txt

echo 'querying movies that diane_lane was in ...'
python cosmos_graph.py query $dbname $collname in diane_lane > queries/diane_lane_in.txt

echo 'querying movies that lori_singer was in ...'
python cosmos_graph.py query $dbname $collname in lori_singer > queries/lori_singer_in.txt

###

echo 'querying kevin_bacon edges ...'
python cosmos_graph.py query $dbname $collname edges kevin_bacon > queries/kevin_bacon_edges.txt

echo 'querying julia_roberts edges ...'
python cosmos_graph.py query $dbname $collname edges julia_roberts > queries/julia_roberts_edges.txt

echo 'querying richard_gere edges ...'
python cosmos_graph.py query $dbname $collname edges richard_gere > queries/richard_gere_edges.txt

echo 'querying diane_lane edges ...'
python cosmos_graph.py query $dbname $collname edges diane_lane > queries/diane_lane_edges.txt

echo 'querying lori_singer edges ...'
python cosmos_graph.py query $dbname $collname edges lori_singer > queries/lori_singer_edges.txt

###

echo 'querying people that kevin_bacon knows ...'
python cosmos_graph.py query $dbname $collname knows kevin_bacon > queries/kevin_bacon_knows.txt

echo 'querying people that julia_roberts knows ...'
python cosmos_graph.py query $dbname $collname knows julia_roberts > queries/julia_roberts_knows.txt

echo 'querying people that richard_gere knows ...'
python cosmos_graph.py query $dbname $collname knows richard_gere > queries/richard_gere_knows.txt

echo 'querying people that lori_singer knows ...'
python cosmos_graph.py query $dbname $collname knows lori_singer > queries/lori_singer_knows.txt

echo 'querying people that diane_lane knows ...'
python cosmos_graph.py query $dbname $collname knows diane_lane > queries/diane_lane_knows.txt

###

echo 'querying path from richard_gere to julia_roberts ...'
python cosmos_graph.py query $dbname $collname path richard_gere julia_roberts > queries/path_richard_gere_to_julia_roberts.txt

echo 'querying path from richard_gere to kevin_bacon ...'
python cosmos_graph.py query $dbname $collname path richard_gere kevin_bacon > queries/path_richard_gere_to_kevin_bacon.txt

echo 'querying path from richard_gere to lori_singer ...'
python cosmos_graph.py query $dbname $collname path richard_gere lori_singer > queries/path_richard_gere_to_lori_singer.txt

echo 'querying path from diane_lane to lori_singer ...'
python cosmos_graph.py query $dbname $collname path diane_lane lori_singer > queries/path_diane_lane_to_lori_singer.txt

echo 'querying path from lori_singer to viola_davis...'
python cosmos_graph.py query $dbname $collname path lori_singer viola_davis > queries/path_lori_singer_to_viola_davis.txt

echo 'querying path from lori_singer to charlotte_rampling...'
python cosmos_graph.py query $dbname $collname path lori_singer charlotte_rampling > queries/path_lori_singer_to_charlotte_rampling.txt

###

echo 'capture_gremlin_queries_for_doc ...'
python cosmos_graph.py capture_gremlin_queries_for_doc $dbname $collname > queries/captured_gremlin_queries.txt

echo 'done'
