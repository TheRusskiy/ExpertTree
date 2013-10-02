class GraphicConnection < Qt::GraphicsItem

  def initialize conn, multiplier, min_x, min_y, is_odd
    super(nil)
    @conn = conn
    @min_x=min_x
    @min_y=min_y
    @multiplier = multiplier
    @is_odd = is_odd

    @x1 = (conn.from.pos.x-min_x)*multiplier
    @y1 = (conn.from.pos.y-min_y)*multiplier
    @x2 = (conn.to.pos.x-min_x)*multiplier
    @y2 = (conn.to.pos.y-min_y)*multiplier
    x_delta = (@x1-@x2).abs
    y_delta = (@y1-@y2).abs

    @boundingRect = Qt::RectF.new(0, 0, x_delta, y_delta)
    @active_color = Qt::Color.new(255, 0, 0)
    @passive_color = Qt::Color.new(20, 20, 20)
    #noinspection RubyArgCount
    @active_pen = Qt::Pen.new
    @active_pen.setColor @active_color
    #noinspection RubyArgCount
    @passive_pen = Qt::Pen.new
    @passive_pen.setColor @passive_color
    setCacheMode(0)
    setZValue(3)
  end

  def boundingRect
    return @boundingRect
  end

  def paint(painter, arg, widget)
    prepareGeometryChange
    painter.pen=@conn.activated? ? @active_pen : @passive_pen

    path = Qt::PainterPath.new
    path.moveTo(@x1, @y1);

    curve_x = (@x1-@x2).abs/2.0
    curve_y = (@y1-@y2).abs/2.0+@multiplier/2.0
    curve_y = -curve_y if @is_odd
    path.quadTo(curve_x, curve_y, @x2, @y2);
    painter.drawPath path
  end
end