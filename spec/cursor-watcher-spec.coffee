CursorWatcher = require '../lib/cursor-watcher'

describe "CursorWatcher", ->
  describe "when TextEditor.onDidChangeCursorPosition is fired", ->
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open('sample.js', autoIndent: false).then (o) -> editor = o

    it "pushes a new navigation to CursorHistoryManager", ->
      cursorHistoryManagerSpy = jasmine.createSpy('cursor-history-manager-push')
      editor = atom.workspace.getActivePane().getActiveEditor()
      cursorHistoryManager =
        pushNewNavigation: cursorHistoryManagerSpy

      cursorWatcher = new CursorWatcher(editor, cursorHistoryManager)
      editor.setCursorBufferPosition([4, 0])

      expect(cursorHistoryManagerSpy).toHaveBeenCalled()
