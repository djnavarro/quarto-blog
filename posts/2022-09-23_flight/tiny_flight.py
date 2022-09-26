
## ---- imports --------
import pyarrow
import pyarrow.flight as flight

## ---- tiny-server --------
class TinyServer(flight.FlightServerBase):
  
    def __init__(self, host = "localhost", port = 5678):
        self.tables = {}
        self.location = flight.Location.for_grpc_tcp(host, port)
        super().__init__(self.location)
    
    @staticmethod    
    def server_message(method, content):
        print("(server) " + method + " " + content.decode("utf-8"))
      
    def do_put(self, context, descriptor, reader, writer):
        self.server_message("do_put", descriptor.command)
        self.tables[descriptor.command] = reader.read_all()

    def do_get(self, context, ticket):
        self.server_message("do_get", ticket.ticket)
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
        
        return flight.FlightInfo(schema, descriptor, endpoints, 
                                 ncases, nbytes)
    
    def get_flight_info(self, context, descriptor):
        self.server_message("get_flight_info", descriptor.command)
        return self.collect_flight_info(descriptor)        
        
    def list_flights(self, context, criteria):
        self.server_message("list_flights", b' ')
        for key in self.tables.keys():
            descriptor = flight.FlightDescriptor.for_command(key)
            yield self.collect_flight_info(descriptor)

    def do_action(self, context, action):
        if action.type == "drop_table":
            key = action.body.to_pybytes()
            del self.tables[key]
            self.server_message("drop_table", key)
            
        elif action.type == "shutdown":
            self.server_message("shutdown", b' ')
            self.shutdown()
            
        else:
            raise KeyError("Unknown action {!r}".format(action.type))

    def list_actions(self, context):
        return [
            ("drop_table", "Drop the specified data set."),
            ("shutdown", "Shut down this server."),
        ]
          
## ---- tiny-client --------
class TinyClient:

    def __init__(self, host = "localhost", port = 5678):
        self.location = flight.Location.for_grpc_tcp(host, port)
        self.con = flight.connect(self.location)
        self.con.wait_for_available()

    def put_table(self, name, table):
        desc = flight.FlightDescriptor.for_command(name.encode("utf8"))
        writer, reader = self.con.do_put(desc, table.schema)
        writer.write(table)
        writer.close()
      
    def get_table(self, name):
        ticket = flight.Ticket(name.encode("utf8"))
        reader = self.con.do_get(ticket)
        return reader.read_all()
    
    def list_tables(self):
        names = []
        for flight in self.con.list_flights():
            names.append(flight.descriptor.command.decode('utf-8'))
        return names
    
    def drop_table(self, name):
        drop = flight.Action("drop_table", name.encode('utf-8')) 
        self.con.do_action(drop)
