#! /usr/bin/bash

cd ~/GitHub/sites/quarto-blog/posts/2022-09-23_flight
Rscript start_demo_server.R &
quarto render index.qmd
