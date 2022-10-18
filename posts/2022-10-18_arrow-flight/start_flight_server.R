library(arrow)

# make sure we have the right python
reticulate::use_miniconda("base")

# path to the folder containing flight_server.py file
this_folder <- here::here("posts", "2022-09-23_flight")

# load the server defined in the flight_server.py module
server_generator <- load_flight_server("tiny_flight_server", this_folder)

# specify a specific instance of this kind of server by calling the
# TinyFlightServer() method
server <- server_generator$TinyFlightServer(port = 6789)

# start the server running
server$serve()

