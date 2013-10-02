class Connection
  attr_reader :from, :to

  def initialize from, to
    @from=from
    @to=to
    @from.add self
    @to.add self
  end

  def activate
    @from.connect @to.type
    @to.connect @from.type
  end

  def to_s
    "From #{@from} to #{@to}"
  end
end