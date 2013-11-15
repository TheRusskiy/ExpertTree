class Connection
  attr_reader :from, :to

  def initialize from, to
    @from=from
    @to=to
    @from.add self
    @to.add self
    @activated = false
  end

  def activate
    @from.connect @to.type
    @to.connect @from.type
    @activated = true
  end

  def activated?
    @activated
  end

  def by_type type
    type = type.to_s
    return @from if @from.type == type
    return @to if @to.type == type
    raise Exception.new "No node with such type: #{type}"
  end

  def to_s
    "From #{@from} to #{@to}"
  end
end