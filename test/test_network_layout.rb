require_relative 'test_helper'

class TestNetworkLayout < MiniTest::Unit::TestCase
  def setup
    @layout = NetworkLayout.new NetworkStructure.new NetworkParser.new(Helper::file_fixture)
  end

  def teardown
    # Do nothing
  end

  def test_init
    @layout.types.length==6
  end

  def test_type_0_layout
    type=@layout.types[0]
    assert_equal type.length, 2
    assert_equal type.top_left.x, 0
    assert_equal type.top_left.y, 0
    assert_equal type.bot_right.x, 2
    assert_equal type.bot_right.y, 3
  end

  def test_type_5_layout
    type=@layout.types[5]
    assert_equal type.length, 8
    shift = 5*2 # 5 previous types, 2 coords each
    assert_equal type.top_left.x, shift
    assert_equal type.top_left.y, 0
    assert_equal type.bot_right.x, shift+2
    assert_equal type.bot_right.y, 8+1 # nodes + 1
  end

  def test_type_5_node_layout
    type=@layout.types[5]
    assert_equal type.length, 8
    shift = 5*2 # 5 previous types, 2 coords each
    assert_equal type[0].pos.x, shift+1
    assert_equal type[0].pos.y, 1
    assert_equal type[7].pos.x, shift+1
    assert_equal type[7].pos.y, 8
  end

  def test_correct_type_to_layout_binding
    type=@layout.types[0]
    assert_equal type.name, 'profiles'
    assert_equal type.length, 2
    assert_equal type[0].name, 'gaming'
  end

end
      