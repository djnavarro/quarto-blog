#! /usr/bin/bash

conda activate continuation
export LD_LIBRARY_PATH="$(python -m rpy2.situation LD_LIBRARY_PATH)":${LD_LIBRARY_PATH}
cd ~/GitHub/sites/quarto-blog/posts/2022-09-16_arrow-and-rpy2
quarto render index.qmd --execute-daemon-restart
