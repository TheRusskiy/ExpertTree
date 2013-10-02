require_relative 'network_structure'
require_relative 'node'
class NetworkLayout

  def initialize structure
    patch_classes

    @types = []
    max_x=0
    structure.types.each_pair do |type_name, node_array|
      new_max_x=max_x+2
      @types << TypeLayout.new(
          type_name, node_array,
          Position.new(max_x,0),
          Position.new(new_max_x,node_array.length+1)
          )
      max_x=new_max_x
    end
  end

  def patch_classes
    Node.class_eval do
      attr_accessor :pos
    end
  end

  def types
    @types
  end


  class TypeLayout < Array
    attr_reader :name, :top_left, :bot_right
    def initialize(type_name, node_array, top_left, bot_right)
      super node_array
      @name=type_name
      @top_left = top_left
      @bot_right = bot_right
      node_y=top_left.y
      for node in node_array
        node_y=node_y+1
        node.pos = Position.new(top_left.x+1, node_y)
      end
    end
  end

  class Position
    attr_accessor :x, :y
    def initialize x, y
      @x = x
      @y = y
    end
  end

end