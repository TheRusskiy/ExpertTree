require_relative 'test_helper'

class TestConnection < MiniTest::Unit::TestCase
  def setup
    @from = Node.new 'from_name', 'from_type'
    @to = Node.new 'to_name', 'to_type'
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

  def test_connection_activates_node_with_require
    @from.require 'to_type'
    @to.require 'something_else'
    refute @from.activated?
    refute @to.activated?
    @conn.activate
    assert @from.activated?
    refute @to.activated?
  end

  def test_connection_adds_itself_to_node
    assert_equal Node.new('name', 'type').connections.length, 0
    assert_equal @from.connections.length, 1
    assert_equal @to.connections.length, 1
  end

  def test_can_be_active
    refute @conn.activated?
    @conn.activate
    assert @conn.activated?
  end

end
      