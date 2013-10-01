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
    conns = @builder.connections
    assert_equal conns.length, 5
    assert_equal conns[4].class, Connection
    assert_equal conns[4].from.name, 'gaming'
    assert_equal conns[4].to.name, '1024'
  end

  def test_integration
    videocard = @builder.types['videocard'][0]
    refute videocard.activated?
    @builder.types['profiles'][0].activate
    refute videocard.activated?
    @builder.types['bus'][0].activate
    assert videocard.activated?
  end

end
      