class GraphicType < Qt::GraphicsItem
  def initialize type, multiplier
    super(nil)
    @type = type
    @x = type.bot_right.x-type.top_left.x
    @y = type.bot_right.y-type.top_left.y
    @x = @x*multiplier
    @y = @y*multiplier
    @boundingRect = Qt::RectF.new(0, 0, @x*6, @y*6);
    #@black = Qt::Color.new(0, 20, 0)
    #@gray = Qt::Color.new(100, 100, 100)
    @main_color = Qt::Color.new(200, 200, 200)
    @second_color = Qt::Color.new(100, 100, 100)
    @brush = Qt::Brush.new(@main_color)
    create_text
    setCacheMode(0)
    setZValue(1)
  end

  def boundingRect
    return @boundingRect
  end

  def create_text
    @text = Qt::GraphicsSimpleTextItem.new(tr(@type.name), self)
    @text.setScale(1.0/scale/3)
    @text.setPos(5, 0)
  end

  def paint(painter, arg, widget)
    painter.brush=@brush
    painter.drawRect(0, 0, @x, @y)
  end
end