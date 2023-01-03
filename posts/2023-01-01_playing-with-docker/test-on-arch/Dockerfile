FROM ghcr.io/djnavarro/arch-r-test:release

# copy the testing script
COPY clone-and-check.R /home/clone-and-check.R

# pass args through environment variables
ARG user
ARG repo
ARG cran=https://cloud.r-project.org
ENV user=$user
ENV repo=$repo
ENV cran=$cran

# run the testing script
CMD Rscript /home/clone-and-check.R
