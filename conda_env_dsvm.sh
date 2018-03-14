#!/bin/bash

# Bash shell script to create the 'gremlin' conda/python virtual environment in an Azure DSVM.
# Chris Joakim, Microsoft, 2018/03/14

venvname='graph'

echo 'removing conda environment (if present): '$venvname
conda remove --name $venvname --all -y

echo 'creating conda environment: '$venvname
conda create -n $venvname -y
conda info --envs

echo 'activating conda environment: '$venvname
source activate $venvname

# Note: Use the Conda pip!  Don't explicitly install it like this:
# echo 'installing pip in new conda environment...'
# conda install pip -y
# conda list

# Note: these pip install commands are copy-and-paste to venv.sh
echo 'installing python packages with pip...'

pip install arrow
pip install azure
pip install docopt
pip install gremlinpython==3.2.7
pip install futures
pip install Jinja2

echo 'listing the python packages in this conda environment:'
conda list

echo 'done'
