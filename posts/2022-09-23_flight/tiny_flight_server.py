
import pyarrow
import pyarrow.flight as flight

tbl = pa.table([["Mario", "Luigi", "Peach"]], names=["Character"])

class TinyServer(flight.FlightServerBase):
  
    def __init__(self, host = "localhost", port = 5678):
        self.tables = {}
        self.location = flight.Location.for_grpc_tcp(host, port)
        super().__init__(self.location)
        
    def server_log(method, content):
        print("(server) " + method + ": " + content.decode("utf-8"))
      
    def do_put(self, context, descriptor, reader, writer):
        self.server_log("do_put", descriptor.command)
        self.tables[descriptor.command] = reader.read_all()

    def do_get(self, context, ticket):
        self.server_log("do_get", ticket.ticket)
        table = self.tables[ticket.ticket]
        return flight.RecordBatchStream(table)
  
    def collect_flight_info(self, descriptor):
      
        key = descriptor.command
        table = self.tables[key]
        
        schema = table.schema
        ncases = table.num_rows
        
        output = pyarrow.MockOutputStream()
        writer = pyarrow.RecordBatchStreamWriter(output, schema)
        writer.write_table(table)
        writer.close()
        nbytes = output.size()
        
        ticket = flight.Ticket(key)
        locations = [self.location.uri.decode("utf-8")]
        endpoints = [flight.FlightEndpoint(ticket, locations)]
        
        return flight.FlightInfo(schema, descriptor, endpoints, ncases, nbytes)
    
    def get_flight_info(self, context, descriptor):
        self.server_log("get_flight_info", descriptor.command)
        return self.collect_flight_info(descriptor)        
        
    def list_flights(self, context, criteria):
        for key in self.tables.keys():
            descriptor = flight.FlightDescriptor.for_command(key)
            yield self.collect_flight_info(descriptor)

    def list_actions(self, context):
        return [
            ("drop_table", "Drop the specified data set."),
            ("shutdown", "Shut down this server."),
        ]

    def do_action(self, context, action):
        if action.type == "drop_table":
            # --- currently does nothing :) ---
            #path = action.body.to_pybytes().decode('utf-8')
            #full_path = self._repo / path
            #full_path.unlink()
            pass
            
        elif action.type == "shutdown":
            self.shutdown()
            
        else:
            raise KeyError("Unknown action {!r}".format(action.type))
          

class TinyClient:

    def __init__(self, host = "localhost", port = 5678):
        self.location = flight.Location.for_grpc_tcp(host, port)
        self.con = flight.connect(self.location)
        self.con.wait_for_available()

    def put_table(self, name, table):
        desc = flight.FlightDescriptor.for_command(name.encode("utf8"))
        put_writer, put_meta_reader = self.con.do_put(desc, table.schema)
        put_writer.write(table)
        put_writer.close()
      
    def get_table(self, name):
        reader = self.con.do_get(flight.Ticket(name.encode("utf8")))
        return reader.read_all()      
      
