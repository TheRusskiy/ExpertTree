class Connection
  attr_reader :from, :to

  def initialize from, to
    @from=from
    @to=to
  end

  def activate
    @from.connect @to.name
    @to.connect @from.name
  end
end