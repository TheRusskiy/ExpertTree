class Node
  attr_reader :name, :connections
  def initialize name
    @name=name
    @activated = false
    @connections = []
    @required = []
    @provided = []
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
    activate if @required&@provided==@required
  end

end