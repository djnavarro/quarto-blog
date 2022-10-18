library(arrow)

# make sure we have the right python
reticulate::use_miniconda("base")

client <- flight_connect(port = 6789)

# send data to the server
flight_put(client, data = airquality, path = "pollution_data")

# list the flights on the server
list_flights(client)

# retrieve data from the server
flight_get(client, path = "pollution_data")
