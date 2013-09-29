require_relative 'test_helper'

class TestNode < MiniTest::Unit::TestCase
  def setup
    @node = Node.new 'name'
  end

  def teardown
    # Do nothing
  end

  def test_initialize
    assert @node.name=='name'
  end

  def test_can_be_activated
    refute @node.activated?
    @node.activate
    assert @node.activated?
  end

  def test_has_connections
    assert_equal @node.connections.length, 0
    @node.add Object.new
    @node << Object.new
    assert_equal @node.connections.length, 2
  end

  def test_node_activates_connections
    conn1 = Minitest::Mock.new
    conn2 = Minitest::Mock.new
    conn1.expect :activate, nil, []
    conn2.expect :activate, nil, []
    @node.<< conn1, conn2
    @node.activate
    conn1.verify
    conn2.verify
  end

  def test_cant_be_activated_twice
    fake_conn = Mock.new :activate do
      fail if @activated
      @activated=true
    end
    @node << fake_conn
    @node.activate
    @node.activate
  end

  def test_required_field
    @node.require 'property_1'
    @node.require 'property_2'

    refute @node.activated?
    @node.connect 'property_1'
    refute @node.activated?
    @node.connect 'property_2'
    assert @node.activated?
  end

end
      