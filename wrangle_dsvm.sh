#!/bin/bash

# Azure Data Science Virtual Machine (DSVM) version of this script.
# This script wrangles the IMDb data and creates a relatively small subset
# that can be inserted into CosmosDB.
#
# Run with:
#   ./wrangle.sh > tmp/wrangle.txt
#
# Chris Joakim, Microsoft, 2018/03/12

identify_candidate_movies=1
extract_movies=1
extract_principals=1
extract_people=1
derive_people_edges=1

footloose=tt0087277
pretty_woman=tt0100405
kevin_bacon=nm0000102
julia_roberts=nm0000210
richard_gere=nm0000152

source activate gremlin  # activate the conda virtualenv

if [ $identify_candidate_movies -gt 0 ]
then
    echo 'python: identify_candidate_movies ...'
    python wrangle.py identify_candidate_movies
    wc   $IMDB_DATA_DIR/processed/candidate_movies.json
    head $IMDB_DATA_DIR/processed/candidate_movies.json
fi

if [ $extract_movies -gt 0 ]
then
    echo 'python: extract_movies ...'
    python wrangle.py extract_movies
    wc   $IMDB_DATA_DIR/processed/movies.csv
    head $IMDB_DATA_DIR/processed/movies.csv
    echo 'grep by movie id for footloose and pretty woman'
    cat  $IMDB_DATA_DIR/processed/movies.csv | grep $footloose
    cat  $IMDB_DATA_DIR/processed/movies.csv | grep $pretty_woman
    echo 'grep by movie title for Footloose, Pretty, Blade'
    cat  $IMDB_DATA_DIR/processed/movies.csv | grep Footloose
    cat  $IMDB_DATA_DIR/processed/movies.csv | grep Pretty
    cat  $IMDB_DATA_DIR/processed/movies.csv | grep Blade
    wc   $IMDB_DATA_DIR/processed/movies.csv
fi

if [ $extract_principals -gt 0 ]
then
    echo 'python: extract_principals ...'
    python wrangle.py extract_principals
    # inspect the file created in the above python process
    wc   $IMDB_DATA_DIR/processed/principals.csv
    head $IMDB_DATA_DIR/processed/principals.csv
    echo 'grep for principals in footloose'
    cat  $IMDB_DATA_DIR/processed/principals.csv | grep $footloose
    echo 'grep for principals in pretty_woman'
    cat  $IMDB_DATA_DIR/processed/principals.csv | grep $pretty_woman
    echo 'grep for kevinbacon'
    cat  $IMDB_DATA_DIR/processed/principals.csv | grep $kevin_bacon
    echo 'grep for juliaroberts'
    cat  $IMDB_DATA_DIR/processed/principals.csv | grep $julia_roberts
fi

if [ $extract_people -gt 0 ]
then
    echo 'python: extract_people ...'
    python wrangle.py extract_people
    # inspect the files created in the above python process
    wc   $IMDB_DATA_DIR/processed/people.csv
    head $IMDB_DATA_DIR/processed/people.csv
    cat  $IMDB_DATA_DIR/processed/people.csv | grep $kevin_bacon
    cat  $IMDB_DATA_DIR/processed/people.csv | grep $julia_roberts
    wc   $IMDB_DATA_DIR/processed/people.json
fi

if [ $derive_people_edges -gt 0 ]
then
    echo 'python: derive_people_edges ...'
    python wrangle.py derive_people_edges
    wc   $IMDB_DATA_DIR/processed/people_edges.json
    echo 'juliaroberts edges:'
    cat  $IMDB_DATA_DIR/processed/people_edges.json | grep $julia_roberts
    echo 'juliaroberts and richardgere edges:'
    cat  $IMDB_DATA_DIR/processed/people_edges.json | grep $julia_roberts | grep $richard_gere
fi

echo 'done'
