require_relative 'test_helper'

class TestNetworkStructure < MiniTest::Unit::TestCase
  def setup
    @builder = NetworkStructure.new NetworkParser.new(Helper::file_fixture)
  end

  def teardown
    # Do nothing
  end

  def test_nodes
    assert_equal @builder.groups['memory'].length, 3
    assert_equal @builder.groups['memory'][0].class, Node
    assert_equal @builder.groups['memory'][0].name, '512'
  end

  def test_nodes_required
    assert_equal @builder.groups['videocard'][0].required.length, 3
    assert_equal @builder.groups['videocard'][0].required[1], 'memory'
  end

  def test_connections
    conns = @builder.connections
    assert_equal conns.length, 4
    assert_equal conns[3].class, Connection
    assert_equal conns[3].from.name, 'gaming'
    assert_equal conns[3].to.name, '1024'
  end

end
      