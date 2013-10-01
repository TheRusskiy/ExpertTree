# encoding: UTF-8
require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use! MiniTest::Reporters::RubyMineReporter.new
require_relative '../src/node'
require_relative '../src/connection'
require_relative '../src/network_parser'
require_relative '../src/network_structure'
module Helper
  def self.file_fixture
     @file||=File.open('../test/network_fixture.yml').reduce :+
  end
end

class Mock
  def initialize(method_name, block = nil )
    block||=Proc.new do |*args|
      args=args.first if args.length==1
      yield(args)
    end
    self.class.send :define_method, method_name, block
  end
end

class TestMock < MiniTest::Unit::TestCase
  def test_mock
    fake = Mock.new :some_method do
      'value'
    end
    assert fake.some_method == 'value'
  end

  def test_mock_single_parameter
    fake = Mock.new :some_method do |p|
      p*2
    end
    assert_equal fake.some_method(2),  4
  end

  def test_mock_many_parameters
    fake = Mock.new :some_method do |p1, p2, p3|
      p1*p2*p3
    end
    assert_equal fake.some_method(2, 3, 4), 24
  end

  def test_lambda_parameter
    fake = Mock.new :some_method, lambda {|p| p*2}
    assert_equal fake.some_method(2), 4
  end

  def test_access_to_local_variable
    p1=1
    fake = Mock.new :some_method do
      p1+=1
    end
    fake.some_method
    assert_equal p1, 2
  end
end
