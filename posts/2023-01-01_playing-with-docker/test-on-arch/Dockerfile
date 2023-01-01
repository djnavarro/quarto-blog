FROM ghcr.io/djnavarro/arch-r:test

# copy the testing script
COPY clone-and-check.R /home/clone-and-check.R

# pass args through environment variables
ARG user
ARG repo
ENV user=$user
ENV repo=$repo

# run the testing script
CMD Rscript /home/clone-and-check.R
