class TreeView < Qt::GraphicsView
  require_relative 'graphic_node'
  X=800
  Y=300
  def initialize(scene)
    # initialize
    @scene =  scene
    @scene.setItemIndexMethod(-1)
    @scene.setSceneRect(50, 50, X, Y)
    @scene.itemIndexMethod = Qt::GraphicsScene::NoIndex
    super(@scene)

    # rendering hints
    self.renderHint = Qt::Painter::Antialiasing
    self.cacheMode = Qt::GraphicsView::CacheBackground
    self.dragMode = Qt::GraphicsView::ScrollHandDrag
  end

  def clear

  end

  def network= network
    #node = GraphicNode.new
    #node.setPos(50, 50)
    #node.setScale(10)
    #@scene.addItem node
    @scene.invalidate
  end

end