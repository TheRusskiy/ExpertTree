class Node
  attr_reader :name, :connections
  def initialize name
    @name=name
    @activated = false
    @connections = []
  end

  def activated?
    @activated
  end

  def activate
    @connections.map(&:activate) unless @activated
    @activated = true
  end


  def add(*connections)
    connections.each do |conn|
      @connections << conn
    end
  end

  alias :<< :add

end