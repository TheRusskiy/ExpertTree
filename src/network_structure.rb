class NetworkStructure
  def  initialize parser
    @parser=parser
    create_groups
    create_connections
  end

  def groups
    @groups
  end

  def connections
    @connections
  end

  private

  def create_groups
    @groups = {}
    @parser.groups.each_pair do |group_name, array_of_nodes|
      @groups[group_name] = create_nodes array_of_nodes
    end
  end

  def create_nodes array_of_nodes
    nodes = []
    for node_params in array_of_nodes
      node = Node.new(node_params['name'])
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
      from = @groups[from_param['group']].find do |n|
        n.name==from_param['name']
      end
      to = @groups[to_param['group']].find do |n|
        n.name==to_param['name']
      end
      connection = Connection.new from, to
      @connections << connection
    end
  end
end