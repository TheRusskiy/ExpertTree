class GraphicNode < Qt::GraphicsItem
  def initialize node, node_size
    super(nil)
    @node = node
    @node_size = node_size

    #@x1=0; @x2=0; @y1=10; @y2=20
    ##@boundingRect = Qt::RectF.new(0, 0,
    ##                              (x2-x1).abs, (y2-y1).abs)
    ##@boundingRect = Qt::RectF.new(0, 0,
    ##                              200, 200)
    #adj=5;
    @boundingRect = Qt::RectF.new(0, 0, @node_size, @node_size);
    #@black = Qt::Color.new(0, 20, 0)
    #@gray = Qt::Color.new(100, 100, 100)
    ##@brush = Qt::Brush.new(@black)
    @active_color = Qt::Color.new(255, 0, 0)
    @passive_color = Qt::Color.new(100, 100, 100)
    @active_brush = Qt::Brush.new(@active_color)
    @passive_brush = Qt::Brush.new(@passive_color)
    #@active_line_brush = Qt::Brush.new(@active_color, 0)
    #@passive_line_brush = Qt::Brush.new(@passive_color, 0)
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

    #painter.brush=@node.activated? ? @active_line_brush : @passive_line_brush
    #path = Qt::PainterPath.new
    #path.moveTo(3, 3);
    #path.quadTo(10, 0, 30, 20);
    #painter.drawPath path
  end
end