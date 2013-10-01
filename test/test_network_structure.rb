require_relative 'test_helper'

class TestNetworkStructure < MiniTest::Unit::TestCase
  def setup
    @builder = NetworkStructure.new NetworkParser.new(Helper::file_fixture)
  end

  def teardown
    # Do nothing
  end

  def test_nodes
    assert_equal @builder.types['memory'].length, 3
    assert_equal @builder.types['memory'][0].class, Node
    assert_equal @builder.types['memory'][0].name, '512'
    assert_equal @builder.types['memory'][0].type, 'memory'
  end

  def test_nodes_required
    assert_equal @builder.types['videocard'][0].required.length, 3
    assert_equal @builder.types['videocard'][0].required[1], 'memory'
  end

  def test_connections
    conn = @builder.connections[1]
    assert_equal @builder.connections.length, 8
    assert_equal conn.class, Connection
    assert_equal conn.from.name, 'AMD 7970'
    assert_equal conn.to.name, '2048'
  end

  def test_integration
    amd5870 = @builder.types['videocard'][0]
    amd7970 = @builder.types['videocard'][1]
    refute amd7970.activated?
    @builder.types['profiles'][0].activate
    refute amd7970.activated?
    @builder.types['bus'][0].activate
    assert amd7970.activated?
    refute amd5870.activated?
  end

end
      