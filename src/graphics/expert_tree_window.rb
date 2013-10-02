# encoding: UTF-8
class ExpertTreeWindow < Qt::MainWindow
  require_relative 'network_layout'
  require_relative 'highlighter'
  require_relative 'tree_view'
  require 'yaml'

  slots :close_program, :about, :switch_to_expert_mode, :switch_to_user_mode,
        'start_consultation()', 'load_network_file()', 'save_network_file()'

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
    @tree_view.network=system unless system.nil?
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
    layout.addWidget @tree_view, 1, 0

    start_button = Qt::PushButton.new(tr('Start Consultation'))
    layout.addWidget start_button, 0, 0, 4
    connect(start_button, SIGNAL('clicked()'), self, SLOT('start_consultation()'))

    @user_widget.layout=layout
    @user_widget
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