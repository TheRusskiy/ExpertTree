require_relative 'test_helper'

class TestParser < MiniTest::Unit::TestCase
  def setup
    @parser = NetworkParser.new Helper::file_fixture
  end

  def teardown
    # Do nothing
  end

  def test_groups_parsing
    assert @parser.groups.length==6
    assert_equal @parser.groups['memory'].length, 3
    assert_equal @parser.groups['memory'][0]['name'], "512"
    assert_equal @parser.groups['memory'][2]['name'], "2048"
    assert_equal @parser.groups['videocard'][0]['required'].length, 3
    assert_equal @parser.groups['videocard'][0]['required'][0], 'bus'
    assert_equal @parser.groups['videocard'][0]['required'][2], 'frequency'
  end

  def test_connections_parsing
    assert @parser.connections.length==4
    assert_equal @parser.connections[0]['from']['group'], 'videocard'
    assert_equal @parser.connections[3]['to']['name'], '1024'
  end

end
      