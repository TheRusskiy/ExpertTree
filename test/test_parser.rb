require_relative 'test_helper'

class TestParser < MiniTest::Unit::TestCase
  def setup
    @parser = NetworkParser.new Helper::file_fixture
  end

  def teardown
    # Do nothing
  end

  def test_types_parsing
    assert @parser.types.length==6
    assert_equal @parser.types['memory'].length, 3
    assert_equal @parser.types['memory'][0]['name'], "512"
    assert_equal @parser.types['memory'][2]['name'], "2048"
    assert_equal @parser.types['videocard'][0]['required'].length, 3
    assert_equal @parser.types['videocard'][0]['required'][0], 'bus'
    assert_equal @parser.types['videocard'][0]['required'][2], 'frequency'
  end

  def test_connections_parsing
    assert @parser.connections.length==5
    assert_equal @parser.connections[0]['from']['type'], 'videocard'
    assert_equal @parser.connections[4]['to']['name'], '1024'
  end

end
      