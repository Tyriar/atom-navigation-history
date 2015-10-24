{CompositeDisposable} = require 'event-kit'
CursorHistoryManager = require './cursor-history-manager'
CursorWatcher = require './cursor-watcher'

module.exports =
  activate: ->
    @disposables = new CompositeDisposable

    @cursorHistoryManager = new CursorHistoryManager()

    @disposables.add atom.commands.add 'atom-text-editor',
      'navigation-history:back': => @jumpBack()
      'navigation-history:forward': => @jumpForward()

    atom.workspace.observeTextEditors (textEditor) =>
      cursorWatcher = new CursorWatcher(textEditor, @cursorHistoryManager)

  deactivate: ->
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
    console.log navigation.position
    navigation.editor.setCursorBufferPosition(navigation.position, autoscroll: false)
    navigation.editor.scrollToCursorPosition(center: true)
