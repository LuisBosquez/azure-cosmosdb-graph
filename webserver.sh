#!/bin/bash

# Start a simple Python web server for serving D3 visualizations.
#
# Run with:
#   ./webserver.sh
#
# Then visit http://localhost:8899/d3/index.html with your browser.
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
fi

python -m http.server $D3_WEBSERVER_PORT
