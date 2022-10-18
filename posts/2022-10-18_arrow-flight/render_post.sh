#! /usr/bin/bash

cd ~/GitHub/sites/quarto-blog/posts/2022-10-18_arrow-flight
Rscript start_demo_server.R &
quarto render index.qmd
