class Connection
  attr_reader :from, :to

  def initialize from, to
    @from=from
    @to=to
  end

  def activate
    @from.activate
    @to.activate
  end
end