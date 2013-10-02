# encoding: UTF-8
class ExpertTreeWindow < Qt::MainWindow
  require_relative 'network_layout'
  require_relative 'highlighter'
  require_relative 'tree_view'
  require 'yaml'

  slots :close_program, :about, :switch_to_expert_mode, :switch_to_user_mode,
        'start_consultation()', 'load_network_file()', 'save_network_file()', 'show_scale(bool)', 'apply_scales()'

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

  def create_user_widget()
    @user_widget = Qt::GroupBox.new tr 'User mode'
    layout = Qt::GridLayout.new

    # Add widgets to layout
    @tree_view = TreeView.new Qt::GraphicsScene.new
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

  def create_expert_widget()
    @expert_widget = Qt::GroupBox.new tr 'Expert Mode'
    layout = Qt::GridLayout.new

    # Add widgets to layout
    frameStyle = Qt::Frame::Sunken | Qt::Frame::Panel
    @network_editor = setup_editor
    @network_editor.frameStyle = frameStyle

    load_button = Qt::PushButton.new(tr('Load network file'))
    load_button.statusTip = tr 'Load network file' # todo more informative tip?
    load_button.shortcut = Qt::KeySequence.new( 'Ctrl+O' )
    connect(load_button, SIGNAL('clicked()'), self, SLOT('load_network_file()'))

    save_button = Qt::PushButton.new(tr('Save network file'))
    save_button.statusTip = tr 'Save network file' # todo more informative tip?
    save_button.shortcut = Qt::KeySequence.new( 'Ctrl+S' )
    connect(save_button, SIGNAL('clicked()'), self, SLOT('save_network_file()'))


    layout.addWidget load_button, 0, 0
    layout.addWidget save_button, 0, 1
    layout.addWidget @network_editor, 1, 0, 1, 2

    @expert_widget.layout=layout
    @expert_widget
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