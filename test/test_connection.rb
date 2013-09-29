require_relative 'test_helper'

class TestConnection < MiniTest::Unit::TestCase
  def setup
    @from = Node.new 'from'
    @to = Node.new 'to'
    @conn = Connection.new @from, @to
  end

  def teardown
    # Do nothing
  end

  def test_template
    assert_equal @conn.from, @from
    assert_equal @conn.to, @to
  end

  def test_connection_activates_node
    refute @from.activated?
    refute @to.activated?
    @conn.activate
    assert @from.activated?
    assert @to.activated?
  end

end
      