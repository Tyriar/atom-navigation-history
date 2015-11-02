{CompositeDisposable} = require 'event-kit'
CursorHistoryManager = require './cursor-history-manager'
CursorWatcher = require './cursor-watcher'

module.exports =
  config:
    maxNavigationsToRemember:
      type: 'integer'
      default: 30
      description: 'The maximum number of navigations to remember.'

  activate: ->
    @disposables = new CompositeDisposable

    @cursorHistoryManager = new CursorHistoryManager(atom.config.get('navigation-history.maxNavigationsToRemember'))

    @disposables.add atom.commands.add 'atom-text-editor',
      'navigation-history:back': => @jumpBack()
      'navigation-history:forward': => @jumpForward()

    atom.workspace.observeTextEditors (textEditor) =>
      cursorWatcher = new CursorWatcher(textEditor, @cursorHistoryManager)

  deactivate: ->
    @cursorHistoryManager.deactivate()
    @disposables.dispose()

  jumpBack: ->
    @jumpTo @cursorHistoryManager.popBackNavigation()

  jumpForward: ->
    @jumpTo @cursorHistoryManager.popForwardNavigation()

  jumpTo: (navigation) ->
    if not navigation?
      return

    if navigation.pane isnt atom.workspace.getActivePane()
      navigation.pane.activate()

    if navigation.editor isnt navigation.pane.getActiveEditor()
      navigation.pane.activateItem(navigation.editor)

    navigation.editor.setCursorBufferPosition(navigation.position, autoscroll: false)
    navigation.editor.scrollToCursorPosition(center: true)
