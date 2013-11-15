# encoding: UTF-8
class ExpertTreeWindow < Qt::MainWindow
  require_relative 'network_layout'
  require_relative 'highlighter'
  require_relative 'tree_view'
  require 'yaml'

  slots :close_program, :about, :switch_to_expert_mode, :switch_to_user_mode,
        'start_consultation()', 'load_network_file()', 'save_network_file()', 'show_scale(bool)', 'apply_scales()', 'show_editor()', 'add_node_row()', 'add_connection_row()', 'fill_editor_from_tables()', 'delete_connection_row()', 'delete_node_row()'

  def initialize(parent = nil)
    super(parent)
    #initialize:
    setWindowTitle(tr 'Semantic tree expert system')
    create_actions
    create_menus
    create_status_bar

    #layout:
    @w = Qt::Widget.new
    @w.layout = Qt::GridLayout.new
    setCentralWidget(@w)
    @w.layout.addWidget(create_user_widget, 0, 0)
    @w.layout.addWidget(create_expert_widget, 0, 0)

    #set correct state:
    resize(900, 450)
    path = './resources/network_file.yml'
    load_network_file path if File.exist? path
    fill_tables
    switch_to_user_mode
  end

  def create_expert_system
    begin
      NetworkLayout.new NetworkStructure.new NetworkParser.new @network_editor.plainText
    rescue Exception
      show_warning tr "Can't parse rules"
      nil
    end
  end

  def parse_rules hash
    rules = []
    hash.each_value do |r|
      rules << Rule.new(r['if'], r['then'])
    end
    rules
  end

  def start_consultation
    @tree_view.clear
    system = create_expert_system
    @tree_view.network_layout=system unless system.nil?
  end

  def save_network_file(path = nil)
    filled_name=""
    path||= Qt::FileDialog.getSaveFileName(self,
                                           tr('Save File'),
                                           filled_name,
                                           tr('YAML files (*.yml)'))
    text = @network_editor.plainText
    file = File.open path, 'w:utf-8'
    file.write text
    file.close
  end

  def load_network_file(path = nil)
    filled_name=""
    path||= Qt::FileDialog.getOpenFileName(self,
                                           tr('Open File'), filled_name, "YAML files (*.yml)")
    return if path.nil?
    file = File.open path, 'r:utf-8'
    set_rule_text file.to_a.reduce :+
    file.close
  end

  def show_warning message
    reply = Qt::MessageBox::critical(self, tr('Error'),
                                     message,
                                     Qt::MessageBox::Retry)
  end

  def set_rule_text text
    @network_editor.plainText= text
  end

  def create_user_widget
    @user_widget = Qt::GroupBox.new tr 'User mode'
    layout = Qt::GridLayout.new

    # Add widgets to layout
    @tree_view = TreeView.new(Qt::GraphicsScene.new, self)
    layout.addWidget @tree_view, 1, 0, 1, 3

    start_button = Qt::PushButton.new(tr('Start Consultation'))
    layout.addWidget start_button, 0, 1
    connect(start_button, SIGNAL('clicked()'), self, SLOT('start_consultation()'))

    scale_button = Qt::PushButton.new(tr 'Show scale controls')
    scale_button.checkable = true
    scale_button.autoDefault = false
    connect(scale_button, SIGNAL('toggled(bool)'), self, SLOT('show_scale(bool)'))
    layout.addWidget scale_button, 0, 0

    layout.addWidget create_view_controls, 2, 0, 1, 3

    @user_widget.layout=layout
    @user_widget
  end

  def create_view_controls
    @scale_widget = Qt::GroupBox.new tr 'Scale controls'

    @scale_values=[1, 8, 5]
    scale_label = Qt::Label.new("#{tr 'Scale'} %d..%d:" % [@scale_values[0], @scale_values[1]])
    @scale_box = Qt::SpinBox.new do |i|
      i.range = @scale_values[0]..@scale_values[1]
      i.singleStep = 1
      i.value = @scale_values[2]
    end

    @distance_values=[10, 40, 18]
    distance_label = Qt::Label.new("#{tr 'Distance'} %d..%d:" % [@distance_values[0], @distance_values[1]])
    @distance_box = Qt::SpinBox.new do |i|
      i.range = @distance_values[0]..@distance_values[1]
      i.singleStep = 1
      i.value = @distance_values[2]
    end

    @size_values=[1, 8, 5]
    size_label = Qt::Label.new("#{tr 'Node size'} %d..%d:" % [@size_values[0], @size_values[1]])
    @node_size_box = Qt::SpinBox.new do |i|
      i.range = @size_values[0]..@size_values[1]
      i.singleStep = 1
      i.value = @size_values[2]
    end

    apply_button = Qt::PushButton.new(tr 'Apply scale')
    connect(apply_button, SIGNAL('clicked()'), self, SLOT('apply_scales()'))

    @extensionLayout = Qt::GridLayout.new
    @extensionLayout.margin = 0
    @extensionLayout.addWidget scale_label, 0, 0
    @extensionLayout.addWidget @scale_box, 0, 1
    @extensionLayout.addWidget distance_label, 0, 2
    @extensionLayout.addWidget @distance_box, 0, 3
    @extensionLayout.addWidget size_label, 0, 4
    @extensionLayout.addWidget @node_size_box, 0, 5
    @extensionLayout.addWidget apply_button, 0, 6

    @scale_widget.layout=@extensionLayout
    @scale_widget.setVisible false
    @scale_widget
  end

  def apply_scales
    @tree_view.scale=@scale_box.value
    @tree_view.distance=@distance_box.value
    @tree_view.node_size=@node_size_box.value
    start_consultation
  end

  def show_scale(bool)
    @scale_widget.setVisible bool
  end

  def create_expert_widget
    @expert_widget = Qt::GroupBox.new tr 'Expert Mode'
    layout = Qt::GridLayout.new

    # Add widgets to layout
    frameStyle = Qt::Frame::Sunken | Qt::Frame::Panel
    @network_editor = setup_editor
    @network_editor.frameStyle = frameStyle

    @network_editor_widget = Qt::GroupBox.new tr 'Rule Editor'
    editor_layout = Qt::GridLayout.new
    editor_layout.addWidget @network_editor, 0, 0
    @network_editor_widget.layout = editor_layout

    load_button = Qt::PushButton.new(tr('Load network file'))
    load_button.statusTip = tr 'Load network file' # todo more informative tip?
    load_button.shortcut = Qt::KeySequence.new( 'Ctrl+O' )
    connect(load_button, SIGNAL('clicked()'), self, SLOT('load_network_file()'))

    save_button = Qt::PushButton.new(tr('Save network file'))
    save_button.statusTip = tr 'Save network file' # todo more informative tip?
    save_button.shortcut = Qt::KeySequence.new( 'Ctrl+S' )
    connect(save_button, SIGNAL('clicked()'), self, SLOT('save_network_file()'))

    @show_editor_button = Qt::PushButton.new(tr('Show editor'))
    @show_editor_button.statusTip = tr 'Show rule text editor'
    connect(@show_editor_button, SIGNAL('clicked()'), self, SLOT('show_editor()'))

    save_table_changes_button = Qt::PushButton.new(tr('Save table changes'))
    save_table_changes_button.statusTip = tr 'Save table changes'
    connect(save_table_changes_button, SIGNAL('clicked()'), self, SLOT('fill_editor_from_tables()'))

    @table_widget = create_rule_table_widget
    layout.addWidget load_button, 0, 0
    layout.addWidget save_button, 0, 1
    layout.addWidget @show_editor_button, 0, 2
    layout.addWidget save_table_changes_button, 0, 3
    layout.addWidget @table_widget, 1, 0, 1, 4
    layout.addWidget @network_editor_widget, 2, 0, 1, 4
    @network_editor_widget.visible=false

    @expert_widget.layout=layout
    @expert_widget
  end

  def show_editor
    editor_visible = !@network_editor_widget.visible
    @show_editor_button.text = editor_visible ? tr('Show table') : tr('Show editor')
    @network_editor_widget.visible= editor_visible
    @table_widget.visible= !editor_visible
    fill_tables unless editor_visible
    fill_editor_from_tables if editor_visible
  end

  def setup_editor
    highlighter = Highlighter.new
    commentFormat = Qt::TextCharFormat.new
    commentFormat.foreground = Qt::Brush.new(Qt::Color.new("#8b3d06"))
    highlighter.addMapping('#.*', commentFormat)

    keysFormat = Qt::TextCharFormat.new
    keysFormat.fontWeight = Qt::Font::Bold
    keysFormat.foreground = Qt::Brush.new(Qt::Color.new("#0000ff"))
    highlighter.addMapping(".+:", keysFormat)

    keywordsFormat = Qt::TextCharFormat.new
    keywordsFormat.fontWeight = Qt::Font::Bold
    keywordsFormat.foreground = Qt::Brush.new(Qt::Color.new("#ff587c"))
    highlighter.addMapping("((nodes)|(connections)):", keywordsFormat)

    font = Qt::Font.new
    font.family = "Courier"
    font.fixedPitch = true
    font.pointSize = 10

    editor = Qt::TextEdit.new
    editor.font = font
    highlighter.addToDocument(editor.document())
    editor
  end

  def fill_tables
    parser = NetworkParser.new @network_editor.plainText
    fill_node_table parser.types
    fill_connection_table parser.connections
  end

  def fill_node_table types
    clear_table @node_model
    row_number = 0
    types.each_pair do |type, nodes|
      nodes.each do |node|
        add_node_row
        set_model_data @node_model, row_number, 0, type
        set_model_data @node_model, row_number, 1, node['name']
        required = node['required']
        required = required.nil? ? '' : required * '|'
        set_model_data @node_model, row_number, 2, required
        row_number = row_number + 1
      end
    end
  end

  def fill_connection_table connections
    clear_table @connection_model
    row_number = 0
    connections.each do |conn|
      add_connection_row
      set_model_data @connection_model, row_number, 0, conn['from']['type']
      set_model_data @connection_model, row_number, 1, conn['from']['name']
      set_model_data @connection_model, row_number, 2, conn['to']['type']
      set_model_data @connection_model, row_number, 3, conn['to']['name']
      row_number = row_number + 1
      end
  end

  def fill_editor_from_tables
    set_rule_text(
        {
            "nodes"=>node_hash_from_table,
            "connections"=> connection_hash_from_table
        }.to_yaml
    )
  end

  def node_hash_from_table
    model = @node_model
    nodes = {}
    for row in 0...model.rowCount
      type = model.item(row, 0)
      name = model.item(row, 1)
      required = model.item(row, 2)
      next if type.text.nil? or name.text.nil?
      type = type.text.force_encoding("UTF-8")# unless type.nil?
      name = name.text.force_encoding("UTF-8")# unless name.nil?
      required = required.nil? ? [] : required.text.force_encoding("UTF-8").split(/\|/)
      node = {"name" => name}
      required_hash = {}
      required.each_with_index do |e, i|
        required_hash[i]=e
      end
      node["required"] = required_hash unless required.empty?
      (nodes[type]||={})[row]=node
    end
    nodes
  end

  def connection_hash_from_table
    model = @connection_model
    connections = {}
    for row in 0...model.rowCount
      from_type = model.item(row, 0).text.force_encoding("UTF-8")
      from_name = model.item(row, 1).text.force_encoding("UTF-8")
      from = {"type" => from_type, "name" => from_name}
      to_type = model.item(row, 2).text.force_encoding("UTF-8")
      to_name = model.item(row, 3).text.force_encoding("UTF-8")
      to = {"type" => to_type, "name" => to_name}
      connections[row]={"from"=>from, "to"=>to}
    end
    connections
  end

  def create_rule_table_widget
    table_widget = Qt::GroupBox.new tr 'Rule table'
    layout = Qt::GridLayout.new

    # Add widgets to layout


    layout.addWidget create_node_table, 0,0
    layout.addWidget create_connection_table, 0,1

    table_widget.layout=layout
    table_widget
  end

  def create_node_table
    table_widget = Qt::GroupBox.new
    layout = Qt::GridLayout.new

    @node_model = Qt::StandardItemModel.new(0, 3, self)
    @node_model.setHeaderData(0, Qt::Horizontal, Qt::Variant.new(tr("Type")))
    @node_model.setHeaderData(1, Qt::Horizontal, Qt::Variant.new(tr("Name")))
    @node_model.setHeaderData(2, Qt::Horizontal, Qt::Variant.new(tr("Required")))
    @node_table = Qt::TableView.new
    @node_table.model = @node_model
    @node_table.selectionMode=1

    add_node_button = Qt::PushButton.new tr 'Add record'
    connect(add_node_button, SIGNAL('clicked()'), self, SLOT('add_node_row()'))
    delete_node_button = Qt::PushButton.new tr 'Delete record'
    delete_node_button.statusTip = tr 'Delete selected record'
    connect(delete_node_button, SIGNAL('clicked()'), self, SLOT('delete_node_row()'))

    layout.addWidget @node_table, 0,0,1,2
    layout.addWidget add_node_button, 1,0
    layout.addWidget delete_node_button, 1,1
    table_widget.layout=layout
    table_widget
  end

  def add_node_row
    @node_model.insertRow @node_model.rowCount
  end

  def delete_node_row
    selected_row = @node_table.selectionModel.currentIndex.row
    @node_model.removeRow(selected_row) unless selected_row == -1
  end

  def set_model_data(model, index1, index2, value)
    model.setData(model.index(index1, index2, Qt::ModelIndex.new),
                   qVariantFromValue(value))
  end

  def get_model_data
    @node_model.takeRow(0)[0].text
    @node_model.takeItem(0,1).text
    @node_model.item(0,0).text
  end

  def create_connection_table
    table_widget = Qt::GroupBox.new
    layout = Qt::GridLayout.new

    @connection_model = Qt::StandardItemModel.new(0, 4, self)
    @connection_model.setHeaderData(0, Qt::Horizontal, Qt::Variant.new(tr("From type")))
    @connection_model.setHeaderData(1, Qt::Horizontal, Qt::Variant.new(tr("name")))
    @connection_model.setHeaderData(2, Qt::Horizontal, Qt::Variant.new(tr("To type")))
    @connection_model.setHeaderData(3, Qt::Horizontal, Qt::Variant.new(tr("name")))
    @connection_table = Qt::TableView.new
    @connection_table.model = @connection_model
    @connection_table.selectionMode=1

    add_node_button = Qt::PushButton.new tr 'Add record'
    connect(add_node_button, SIGNAL('clicked()'), self, SLOT('add_connection_row()'))
    delete_connection_button = Qt::PushButton.new tr 'Delete record'
    delete_connection_button.statusTip = tr 'Delete selected record'
    connect(delete_connection_button, SIGNAL('clicked()'), self, SLOT('delete_connection_row()'))

    layout.addWidget @connection_table, 0,0,1,2
    layout.addWidget add_node_button, 1,0
    layout.addWidget delete_connection_button, 1,1
    table_widget.layout=layout
    table_widget
  end

  def add_connection_row
    @connection_model.insertRow @connection_model.rowCount
  end

  def delete_connection_row
    selected_row = @connection_table.selectionModel.currentIndex.row
    @connection_model.removeRow(selected_row) unless selected_row == -1
  end

  def clear_table model
    prev_count = model.rowCount
    for i in 0..prev_count do
      model.removeRow(0)
    end
  end

  def createTableRows(model, count)
    prev_count = model.rowCount
    for i in 0..prev_count do
      model.removeRow(0)
    end
    for i in 0...count do
      model.insertRow(0)
    end
  end

  def create_actions
    @exit_action = Qt::Action.new(tr('Exit'), self)
    @exit_action.shortcut = Qt::KeySequence.new( 'Ctrl+X' )
    @exit_action.statusTip = tr 'Close the program'
    connect(@exit_action, SIGNAL(:triggered), self, SLOT(:close_program))

    @switch_to_expert_mode = Qt::Action.new(tr('Expert mode'), self)
    @switch_to_expert_mode.shortcut = Qt::KeySequence.new( 'Ctrl+E' )
    @switch_to_expert_mode.checkable = true
    @switch_to_expert_mode.statusTip = tr 'In this mode you can edit rules'
    connect(@switch_to_expert_mode, SIGNAL(:triggered), self, SLOT(:switch_to_expert_mode))

    @switch_to_user_mode = Qt::Action.new(tr('User mode'), self)
    @switch_to_user_mode.shortcut = Qt::KeySequence.new( 'Ctrl+U' )
    @switch_to_user_mode.checkable = true
    @switch_to_user_mode.statusTip = tr 'In this mode you can get recommendations'
    connect(@switch_to_user_mode, SIGNAL(:triggered), self, SLOT(:switch_to_user_mode))


    @about_action = Qt::Action.new(tr('About'), self)
    @about_action.statusTip = tr 'Show information about the program'
    connect(@about_action, SIGNAL(:triggered), self, SLOT(:about))
  end

  def create_menus
    @file_menu = menuBar.addMenu(tr 'File')
    @file_menu.addAction(@exit_action)

    @mode_menu = menuBar.addMenu(tr 'Mode')
    @mode_menu.addAction(@switch_to_user_mode)
    @mode_menu.addAction(@switch_to_expert_mode)

    @help_menu = menuBar.addMenu(tr 'Help')
    @help_menu.addAction(@about_action)
  end

  def create_status_bar
    statusBar.showMessage(tr 'Welcome!')
  end

  def close_program
    exit
  end

  def switch_to_expert_mode
    @switch_to_user_mode.checked=false
    @switch_to_expert_mode.checked=true
    @user_widget.visible=false
    @expert_widget.visible=true
  end

  def switch_to_user_mode
    @switch_to_user_mode.checked=true
    @switch_to_expert_mode.checked=false
    @user_widget.visible=true
    @expert_widget.visible=false
  end

  def about
    about_message = tr('long about');
    if about_message=='long about'
      about_message=
          "MINISTRY OF EDUCATION AND SCIENCE\n"+
              "OF THE RUSSIAN FEDERATION\n"+
              "FEDERAL STATE EDUCATIONAL INSTITUTION\n"+
              "OF HIGHER PROFESSIONAL EDUCATION\n"+
              "\"SAMARA STATE AEROSPACE UNIVERSITY\n" +
              "OF ACADEMICIAN S.P. KOROLYOV\"\n" +
              "(NATIONAL RESEARCH UNIVERSITY) (SSAU) \n" +
              "Chair of Computer Systems\n" +
              "\n" +
              "Author: \n" +
              "Dmitry Ishkov\n"+
              "Group: 6502 C 245\n" +
              "Instructor: associate professor Valentin Deryabkin"
    end


    Qt::MessageBox::information(self, tr('About'), about_message)
  end

end