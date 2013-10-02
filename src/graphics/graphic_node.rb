class GraphicNode < Qt::GraphicsItem

  Node.class_eval do
    attr_accessor :highlighted
    def highlight is_on
      for conn in @connections
        conn.highlight is_on
      end
    end
  end

  def initialize node, node_size
    super(nil)
    @node = node
    @node_size = node_size

    @boundingRect = Qt::RectF.new(0, 0, @node_size, @node_size)
    @active_brush = Qt::Brush.new(Qt::Color.new(255, 0, 0))
    @passive_brush = Qt::Brush.new(Qt::Color.new(100, 100, 100))
    @highlight_brush = Qt::Brush.new(Qt::Color.new(0, 0, 255))
    @text = Qt::GraphicsSimpleTextItem.new("", self)
    setAcceptHoverEvents(true)
    setCacheMode(0)
    setZValue(2)
  end

  def boundingRect
    return @boundingRect
  end

  def hoverEnterEvent(event)
    @node.highlight true
    self.scene.invalidate
  end

  def hoverLeaveEvent(event)
    @node.highlight false
    self.scene.invalidate
  end

  def mousePressEvent(event)
    @node.activate
    self.scene.invalidate
  end

  def paint(painter, arg, widget)
    painter.brush=@node.activated? ? @active_brush : @passive_brush
    painter.brush=@node.highlighted ? @highlight_brush : painter.brush
    painter.drawEllipse(0, 0, @node_size, @node_size)
  end
end