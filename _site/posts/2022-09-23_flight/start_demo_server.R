
# load R packages and specify the Python environment
library(arrow)
library(reticulate)
use_miniconda("base")

# load the server class, create an instance, and start serving
server_class <- load_flight_server("demo_flight_server")
server <- server_class$DemoFlightServer(port = 8089)
server$serve()
