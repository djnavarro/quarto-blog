
import ast
import threading
import time
import pyarrow as pa
import pyarrow.flight as flight

# Our Server class will inherit from flight.FlightServerBase. That's handy
# because FlightServerBase specifies defaults for all methods that form part
# of the Flight RPC protocol. They don't do anything except throw errors.
# Writing our own server is essentially all about overriding those defaults
# whenever we want our server to support a particular method
#
# https://arrow.apache.org/docs/format/Flight.html#protocol-buffer-definitions

# Why Waitress? It's a "Table Server". Yes this is an excuse to write the whole
# post around The Waitresses. 
class Waitress(flight.FlightServerBase):
  
    # On initialisation, create a Server object specifying the host 
    # and the port. The list of flights for this server is empty
    def __init__(self, host = "localhost", port = 5005):
      
        # Check for float/numeric because we're doing this in 
        # conjunction with R and R is more permissive about letting
        # other numeric types masquerade as integers
        if isinstance(port, float):
            port = int(port)
        
        # Where will our server run?    
        location = "grpc+tcp://{}:{}".format(host, port)
        
        # Initialise Server as an instance of flight.FlightServerBase 
        # using the appropriate location
        super(Server, self).__init__(location)
        
        # Set some initial values for the Server instance
        self.flights = {}
        self.host = host
        
    @classmethod    

    # private methods ------------------------------------------------------
    #
    # Let's first define some "private" (not really) methods that will be 
    # handy later when implementing the public Flight RPC methods
    
    # Helper function to construct a key from a descriptor.
    # The key is a tuple containing the descriptor type, command, and path
    def _get_key(self, descriptor):
        value = descriptor.descriptor_type.value
        command = descriptor.command
        path = tuple(descriptor.path or tuple())
        return (value, command, path)

    def _get_descriptor(self, key):
        if key[1] is not None:
            return flight.FlightDescriptor.for_command(key[1])
        return flight.FlightDescriptor.for_path(*key[2])

    # Helper function to get the total size of the table (in bytes). To 
    # do that we stream to a "mock" sink, using the helper class 
    # MockOutputStream(). Per the docs, this class doesn't do anything 
    # except increment a size counter. No data is copied or retained at 
    # this step. At the end, mock_sink.size() records the number of bytes
    def _get_table_size(self, table):
        mock_sink = pa.MockOutputStream()
        stream_writer = pa.RecordBatchStreamWriter(mock_sink, table.schema)
        stream_writer.write_table(table)
        stream_writer.close()
        return mock_sink.size()

    # Helper to list endpoints where a specified flight is available.
    # To that end: flight.Location is used to handle URIs. What we're using 
    # here is the for_grpc_tcp() method that takes the host name and 
    # port and returns a URI appropriate for the gRCP TCP thingy. Then we 
    # use flight.FlightEndpoint to return an object that contains the ticket
    # (printable representation of the key), and a list of locations. 
    def _get_flight_endpoint(self, key):
        ticket = repr(key)
        location = [flight.Location.for_grpc_tcp(self.host, self.port)]
        endpoints = [flight.FlightEndpoint(ticket, location)] 

    # Helper function that takes a key and descriptor for a table, along 
    # with the table itself, and returns a FlightInfo
    def _get_flight_info(self, key, descriptor, table):
        schema = table.schema
        total_records = table.num_rows
        total_bytes = Waitress._get_table_size(table)
        endpoints = self._get_flight_endpoint(key)
        return flight.FlightInfo(schema, descriptor, endpoints, 
                                 total_records, total_bytes)

    # Helper function to shut down the server after a delay
    def _shutdown(self):
        """Shut down after a delay."""
        print("Server is shutting down...")
        time.sleep(2)
        self.shutdown()

    # public methods ------------------------------------------------------
    #
    # The "public" methods defined below - list_flights, get_flight_info,
    # do_put, do_get, list_actions, do_action - are the ones we're going
    # to define for our server. In addition to self as the first argument,
    # they always have context as the second argument because Arrow. Later
    # arguments vary depending on context

    # if the flight exists call _get_flight_info(), otherwise raise an error
    def get_flight_info(self, context, descriptor):
        print("get_flight_info")
        key = Waitress._get_key(descriptor)
        if key in self.flights:
            table = self.flights[key]
            flight_info = self._get_flight_info(key, descriptor, table)
            return flight_info
        raise KeyError('Flight not found.')

    # generator function (i.e., stateful function: thingy in python that yields 
    # a different result each time it's called depending on where it's up to in
    # the execution) that returns a call to _get_flight_info
    def list_flights(self, context, criteria):
        print("list_flights")
        for key, table in self.flights.items():
            descriptor = Waitress._get_descriptor(key)
            flight_info = self._get_flight_info(key, descriptor, table)
            yield flight_info


    def do_put(self, context, descriptor, reader, writer):
        print("do_put")
        key = Waitress._get_key(descriptor)
        print(key)
        self.flights[key] = reader.read_all()
        print(self.flights[key])

    def do_get(self, context, ticket):
        print("do_get")
        key = ast.literal_eval(ticket.ticket.decode())
        if key not in self.flights:
            return None
        return flight.RecordBatchStream(self.flights[key])

    def list_actions(self, context):
        print("list_actions")
        return [
            ("clear", "Clear the stored flights."),
            ("shutdown", "Shut down this server."),
        ]

    def do_action(self, context, action):
        print("do_action")
        if action.type == "clear":
            raise NotImplementedError(
                "{} is not implemented.".format(action.type))
        elif action.type == "healthcheck":
            pass
        elif action.type == "shutdown":
            yield flight.Result(pa.py_buffer(b'Shutdown!'))
            threading.Thread(target=self._shutdown).start()
        else:
            raise KeyError("Unknown action {!r}".format(action.type))
