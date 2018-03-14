#!/bin/bash

# Azure Data Science Virtual Machine (DSVM) version of this script.
# Start a simple Python web server for serving D3 visualizations.
#
# Run with:
#   ./webserver.sh
#
# Then visit http://<your dsvm ip address>:8899/d3/index.html with your browser.
# Note: You'll need to add an inbound port rule for your DSVM to allow traffic
# to port 8899.
#
# Chris Joakim, Microsoft, 2018/03/12

source activate gremlin  # activate the conda virtualenv

python -m http.server 8899
