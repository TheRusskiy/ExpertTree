require 'qt'
require_relative 'resources/translation_patch'
require_relative 'graphics/expert_tree_window'
app = Qt::Application.new(ARGV)
window = ExpertTreeWindow.new
window.show
app.exec