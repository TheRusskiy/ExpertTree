class Node
  attr_reader :name, :type, :connections
  def initialize name, type
    @name=name
    @type=type
    @activated = false
    @connections = []
    @required = []
    @provided = []
  end

  def activated?
    @activated
  end

  def activate
    unless @activated
      @activated = true
      @connections.map(&:activate)
    end
  end

  def add(*connections)
    connections.each do |conn|
      @connections << conn
    end
  end
  alias :<< :add

  def require property
    if property.respond_to? :each
      @required = @required + property
    else
      @required << property
    end
  end

  def required
    @required
  end

  def connect property
    @provided << property
    activate if (@required-@provided).empty?
  end

  def to_s
    "Node '#{@name}' active: #{@activated.to_s}"
  end

end