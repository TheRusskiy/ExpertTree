require 'qt'
require_relative 'translation_patch'
require_relative 'expert_tree_window'
app = Qt::Application.new(ARGV)
window = ExpertTreeWindow.new
window.show
app.exec