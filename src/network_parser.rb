class NetworkParser
  require 'yaml'
  def initialize text
    @hash = YAML::load text
    parse_nodes
    parse_connections
  end

  def types
    return @hash['nodes']
  end

  def connections
    return @hash['connections']
  end

  private
  def parse_nodes
    @hash['nodes'].each_pair do |group, hash_of_values|
      nodes = hash_of_values.values
      nodes.each do |node|
        node.each_pair do |property, value|
          if property == 'required'; node[property] = value.values end
        end
      end
      @hash['nodes'][group] = nodes
    end
  end

  def parse_connections
    @hash['connections'] = @hash['connections'].values
  end
end