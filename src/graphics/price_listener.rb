class PriceListener
  def initialize nodes, window
    @window = window
    @nodes = nodes
    @lowest_price = 99999999
  end

  def on_click event
    min = nil
    min_node = nil
    @nodes.each do |n|
      if n.type == 'price' and n.activated?
        if min.nil?
          min = n.name.to_i
          min_node = n
        elsif n.name.to_i < min
          min = n.name.to_i
          min_node = n
        end
      end
    end
    if not min.nil? and min < @lowest_price
      @lowest_price = min
      Qt::MessageBox::information(@window, tr('Your card!'), message(min_node, min))
    end
  end

  private
  def message node, price
    cards = []
    node.connections.each do |conn|
      cards << conn.by_type(:videocard)
    end
    m = tr "With the price of"
    m += " #{price} "
    m += tr "you can get"
    m += ' '+cards.map(&:name)*', '
    m
  end
end