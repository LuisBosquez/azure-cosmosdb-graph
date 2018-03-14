#!/bin/bash

# Start a simple Python web server for serving D3 visualizations.
#
# Run with:
#   ./webserver.sh
#
# Then visit http://localhost:8899/d3/index.html with your browser.
#
# Chris Joakim, Microsoft, 2018/03/12

python -m http.server 8899
