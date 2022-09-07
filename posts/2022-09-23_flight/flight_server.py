
import ast
import threading
import time
import pyarrow as pa
import pyarrow.flight as flight


class Server(flight.FlightServerBase):
  
    # On initialisation, create a Server object specifying the host 
    # and the port. The list of flights for this server is empty
    def __init__(self, host = "localhost", port = 5005):
        if isinstance(port, float):
            port = int(port)
        location = "grpc+tcp://{}:{}".format(host, port)
        super(Server, self).__init__(location)
        self.flights = {}
        self.host = host
    
    # Helper function to construct key from descriptor. The key is a 
    # tuple containing the descriptor type, command, and path
    @classmethod    
    def _descriptor_to_key(self, descriptor):
        return (descriptor.descriptor_type.value, descriptor.command,
                tuple(descriptor.path or tuple()))

    def _make_flight_info(self, key, descriptor, table):
        location = flight.Location.for_grpc_tcp(self.host, self.port)
        endpoints = [flight.FlightEndpoint(repr(key), [location]), ]
        mock_sink = pa.MockOutputStream()
        stream_writer = pa.RecordBatchStreamWriter(mock_sink, table.schema)
        stream_writer.write_table(table)
        stream_writer.close()
        data_size = mock_sink.size()

        return flight.FlightInfo(table.schema, descriptor, endpoints, 
                                 table.num_rows, data_size)

    def list_flights(self, context, criteria):
        print("list_flights")
        for key, table in self.flights.items():
            if key[1] is not None:
                descriptor = flight.FlightDescriptor.for_command(key[1])
            else:
                descriptor = flight.FlightDescriptor.for_path(*key[2])

            yield self._make_flight_info(key, descriptor, table)

    def get_flight_info(self, context, descriptor):
        print("get_flight_info")
        key = Server._descriptor_to_key(descriptor)
        if key in self.flights:
            table = self.flights[key]
            return self._make_flight_info(key, descriptor, table)
        raise KeyError('Flight not found.')

    def do_put(self, context, descriptor, reader, writer):
        print("do_put")
        key = Server._descriptor_to_key(descriptor)
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

    def _shutdown(self):
        """Shut down after a delay."""
        print("Server is shutting down...")
        time.sleep(2)
        self.shutdown()
