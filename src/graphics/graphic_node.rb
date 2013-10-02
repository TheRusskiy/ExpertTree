class GraphicNode < Qt::GraphicsItem

  Node.class_eval do
    attr_accessor :highlighted
    def highlight is_on
      for conn in @connections
        conn.highlight is_on
      end
    end
  end

  def initialize node, node_size, distance
    super(nil)
    @node = node
    @node_size = node_size
    @distance = distance

    @boundingRect = Qt::RectF.new(0, 0, @node_size, @node_size)
    @active_brush = Qt::Brush.new(Qt::Color.new(255, 0, 0))
    @passive_brush = Qt::Brush.new(Qt::Color.new(100, 100, 100))
    @highlight_brush = Qt::Brush.new(Qt::Color.new(0, 0, 255))
    @text_brush = Qt::Brush.new(Qt::Color.new(0, 0, 0))

    create_text
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
    curr_brush = @passive_brush
    curr_brush=@active_brush if @node.activated?
    curr_brush=@highlight_brush if @node.highlighted
    painter.brush=curr_brush

    @name.brush=@node.highlighted ? @highlight_brush : @text_brush
    painter.drawEllipse(0, 0, @node_size, @node_size)
    @required.setText(required_info)
  end

  def create_text
    name_info = @node.name.capitalize
    @name = Qt::GraphicsSimpleTextItem.new(name_info, self)
    @name.setScale(1.0/scale/4)
    @name.setPos(-@distance+3, 0)

    @required = Qt::GraphicsSimpleTextItem.new(required_info, self)
    @required.setScale(1.0/scale/4)
    @required.setPos(@node_size, -@node_size/2)
  end

  def required_info
    left=@node.required-@node.provided
    if left.empty?
      ''
    else
      "#{tr 'Required'}:\n"+((left)*"\n")
    end
  end
end