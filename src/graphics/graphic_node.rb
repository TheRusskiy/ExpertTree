class GraphicNode < Qt::GraphicsItem
  def initialize node, node_size
    super(nil)
    @node = node
    @node_size = node_size

    @boundingRect = Qt::RectF.new(0, 0, @node_size, @node_size)
    @active_color = Qt::Color.new(255, 0, 0)
    @passive_color = Qt::Color.new(100, 100, 100)
    @active_brush = Qt::Brush.new(@active_color)
    @passive_brush = Qt::Brush.new(@passive_color)
    @text = Qt::GraphicsSimpleTextItem.new("", self)
    setCacheMode(0)
    setZValue(2)
  end

  def boundingRect
    return @boundingRect
  end

  def mousePressEvent(event)
    @node.activate
    self.scene.invalidate
  end

  def paint(painter, arg, widget)
    painter.brush=@node.activated? ? @active_brush : @passive_brush
    painter.drawEllipse(0, 0, @node_size, @node_size)
  end
end