class GraphicNode < Qt::GraphicsItem
  def initialize
    super(nil)

    @x1=0; @x2=0; @y1=10; @y2=20
    #@boundingRect = Qt::RectF.new(0, 0,
    #                              (x2-x1).abs, (y2-y1).abs)
    #@boundingRect = Qt::RectF.new(0, 0,
    #                              200, 200)
    adj=5;
    @boundingRect = Qt::RectF.new(@x1-adj, @y1-adj, @x2+adj, @y2+adj);
    @black = Qt::Color.new(0, 20, 0)
    @gray = Qt::Color.new(100, 100, 100)
    #@brush = Qt::Brush.new(@black)
    @pen = Qt::Pen.new(1)
    @pen.setWidth(2)
    #@pen.setCosmetic(true)
  end

  def boundingRect
    return @boundingRect
  end

  def paint(painter, arg, widget)
    @pen.setWidth(2)
    @pen.setColor(@gray)
    @pen.setStyle(1)
    painter.pen = @pen
    painter.drawLine(@x1, @y1, @x2, @y2)

    @pen.setWidth(0)
    @pen.setColor(@black)
    @pen.setStyle(2)
    painter.pen = @pen
    painter.drawLine(@x1, @y1, @x2, @y2)
  end
end