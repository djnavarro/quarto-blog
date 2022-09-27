
## ---- imports --------
import pyarrow as pa
import pyarrow.flight as flight

## ---- tiny-server --------
class TinyServer(flight.FlightServerBase):
  
    def __init__(self, 
                 host = 'localhost', 
                 port = 5678):
        self.tables = {}
        self.location = flight                  \
                        .Location               \
                        .for_grpc_tcp(host, port)
        super().__init__(self.location)
    
    @staticmethod    
    def server_message(method, name):
        msg = '(server) '                       \
              + method                          \
              + ' '                             \
              + name.decode('utf-8')
        print(msg)
      
    def do_put(self, context, descriptor, reader, 
               writer):
        table_name = descriptor.command
        self.server_message('do_put', table_name)
        self.tables[table_name] = reader.read_all()

    def do_get(self, context, ticket):
        table_name = ticket.ticket
        self.server_message('do_get', table_name)
        table = self.tables[table_name]
        return flight.RecordBatchStream(table)
  
    def flight_info(self, descriptor):
        table_name = descriptor.command
        table = self.tables[table_name]
        schema = table.schema
        ncases = table.num_rows
        
        output = pa.MockOutputStream()
        writer = pa.RecordBatchStreamWriter(output, 
                                            schema)
        writer.write_table(table)
        writer.close()
        nbytes = output.size()
        
        ticket = flight.Ticket(table_name)
        location = self.location.uri.decode('utf-8')
        endpoint = flight.FlightEndpoint(ticket,
                                         [location])
        
        return flight.FlightInfo(schema, 
                                 descriptor, 
                                 [endpoint], 
                                 ncases,
                                 nbytes)
    
    def get_flight_info(self, context, descriptor):
        table_name = descriptor.command
        self.server_message('get_flight_info',
                            table_name)
        return self.flight_info(descriptor)        
        
    def list_flights(self, context, criteria):
        self.server_message('list_flights', b' ')
        for table_name in self.tables.keys():
            descriptor = flight                  \
                         .FlightDescriptor       \
                         .for_command(table_name)
            yield self.flight_info(descriptor)

    def do_action(self, context, action):
        if action.type == 'drop_table':
            table_name = action.body.to_pybytes()
            del self.tables[table_name]
            self.server_message('drop_table',
                                table_name)

        elif action.type == 'shutdown':
            self.server_message('shutdown', b' ')
            self.shutdown()

        else:
            raise KeyError('Unknown action {!r}'.
                           format(action.type))

    def list_actions(self, context):
        return [('drop_table', 'Drop table'),
                ('shutdown', 'Shut down server')]
          
## ---- tiny-client --------
class TinyClient:

    def __init__(self, host = 'localhost', port = 5678):
        self.location = flight                      \
                        .Location                   \
                        .for_grpc_tcp(host, port)
        self.connection = flight.connect(self.location)
        self.connection.wait_for_available()

    def put_table(self, name, table):
        table_name = name.encode('utf8')
        descriptor = flight                         \
                     .FlightDescriptor              \
                     .for_command(table_name)
        writer, reader = self                       \
                         .connection                \
                         .do_put(descriptor,
                                 table.schema)
        writer.write(table)
        writer.close()
      
    def get_table(self, name):
        table_name = name.encode('utf8')
        ticket = flight.Ticket(table_name)
        reader = self.connection.do_get(ticket)
        return reader.read_all()
    
    def list_tables(self):
        names = []
        for flight in self.connection.list_flights():
            table_name = flight.descriptor.command
            names.append(table_name.decode('utf-8'))
        return names
    
    def drop_table(self, name):
        table_name = name.encode('utf8')
        drop = flight.Action('drop_table', table_name) 
        self.connection.do_action(drop)
