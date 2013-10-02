class TreeView < Qt::GraphicsView
  require_relative 'graphic_node'
  X=1280
  Y=1024
  def initialize(scene)
    @graphic_items=[]
    @scale = 5
    @distance=20
    # initialize
    @scene =  scene
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
    make_nodes
    @scene.invalidate
  end

  def make_nodes
    max_y = 0
    @network.types.each do |type|
      type.each do |node|
        gn = GraphicNode.new node
        gn.setPos(node.pos.x*@scale*@distance, node.pos.y*@scale*@distance)
        gn.setScale(@scale)
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

end