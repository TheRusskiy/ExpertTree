class TreeView < Qt::GraphicsView
  require_relative 'graphic_node'
  require_relative 'graphic_type'
  require_relative 'graphic_connection'
  attr_accessor :scale, :distance, :node_size
  X=1280
  Y=1024
  def initialize(scene)
    # size modifiers
    @scale = 5
    @distance=18
    @node_size=5

    # initialize
    @graphic_items=[]
    @scene = scene
    @scene.setItemIndexMethod(-1)
    @scene.setSceneRect(0, 0, X, Y)
    @scene.itemIndexMethod = Qt::GraphicsScene::NoIndex
    super(@scene)

    # rendering hints
    self.renderHint = Qt::Painter::Antialiasing
    self.cacheMode = Qt::GraphicsView::CacheBackground
    self.dragMode = Qt::GraphicsView::ScrollHandDrag
  end

  def clear
    for item in @graphic_items
      @scene.removeItem item
    end
    @graphic_items=[]
  end

  def network_layout= network
    clear
    @network = network
    draw_nodes
    draw_connections
    @scene.invalidate
  end

  def draw_nodes
    max_y = 0
    @network.types.each do |type|
      gt = GraphicType.new type, @distance
      gt.setPos(type.top_left.x*@scale*@distance, type.top_left.y*@scale*@distance)
      gt.setScale @scale
      @scene.addItem gt
      @graphic_items << gt
      type.each do |node|
        gn = GraphicNode.new node, @node_size, @distance
        gn.setPos(
            (node.pos.x*@distance-@node_size/2)*@scale,
            (node.pos.y*@distance-@node_size/2)*@scale)
        gn.setScale @scale
        @scene.addItem gn
        @graphic_items << gn
      end
      max_y = type.last.pos.y if type.last.pos.y > max_y
    end
    max_x = @network.types.last.bot_right.x
    max_x+=1 # just to be...
    max_y+=1 # ...sure it fits
    @scene.setSceneRect(0, 0, max_x*@scale*@distance, max_y*@scale*@distance)
  end

  def draw_connections
    odd = false
    @network.connections.each do |conn|
      from_x = conn.from.pos.x
      to_x = conn.to.pos.x
      from_y = conn.from.pos.y
      to_y = conn.to.pos.y
      x = from_x < to_x ? from_x : to_x
      y = from_y < to_y ? from_y : to_y
      gc = GraphicConnection.new conn, @distance, x, y, odd
      gc.setPos x*@scale*@distance, y*@scale*@distance
      gc.setScale @scale
      @scene.addItem gc
      @graphic_items << gc
      odd = !odd
    end
  end

end