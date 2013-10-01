require_relative 'node'
class NetworkStructure
  def  initialize parser
    @parser=parser
    create_types
    create_connections
  end

  def types
    @types
  end

  def connections
    @connections
  end

  private

  def create_types
    @types = {}
    @parser.types.each_pair do |group_name, array_of_nodes|
      @types[group_name] = create_nodes array_of_nodes, group_name
    end
  end

  def create_nodes array_of_nodes, group_name
    nodes = []
    for node_params in array_of_nodes
      node = Node.new(node_params['name'], group_name)
      required = node_params['required']
      node.require required unless required.nil?
      nodes << node
    end
    nodes
  end

  def create_connections
    @connections = []
    for connection_params in @parser.connections
      from_param = connection_params['from']
      to_param = connection_params['to']
      from = @types[from_param['type']].find do |n|
        n.name==from_param['name']
      end
      to = @types[to_param['type']].find do |n|
        n.name==to_param['name']
      end
      connection = Connection.new from, to
      @connections << connection
    end
  end
end