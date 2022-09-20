
# load R packages
library(arrow)
library(reticulate)

# use a Python environment with pyarrow
use_miniconda("base")

# load the definition of the "demo flight server" Python class
# that comes bundled with the R arrow package
server_class_object <- load_flight_server("demo_flight_server")

# create an instance of the server and start it running
server_instance <- server_class_object$DemoFlightServer(port = 8089)
server_instance$serve()
