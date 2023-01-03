# get the system environment variables
user <- Sys.getenv("user")
repo <- Sys.getenv("repo")
cran <- Sys.getenv("cran")

# define github url and a path for the local package install
url <- paste("https://github.com", user, repo, sep = "/")
dir <- paste("/home/project", repo, sep="/")

# clone repo, install dependencies, and run checks
gert::git_clone(url, dir, verbose = TRUE)
remotes::install_deps(dir, dependencies = TRUE, repos = cran)
rcmdcheck::rcmdcheck(dir)
