module.exports =
class CursorWatcher
  constructor: (@editor, @cursorHistoryManager) ->
    @editor.onDidChangeCursorPosition (e) => @onDidChangeCursorPosition(e)

  onDidChangeCursorPosition: (e) ->
    activePane = atom.workspace.getActivePane()
    @cursorHistoryManager.pushNewNavigation(activePane, @editor, e.newBufferPosition)
