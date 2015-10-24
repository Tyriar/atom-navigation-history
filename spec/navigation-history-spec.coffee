main = require '../lib/main'

describe "navigation-history", ->
  originalMainJumpTo = null

  beforeEach ->
    originalMainJumpTo = main.jumpTo
    waitsForPromise ->
      atom.workspace.open()

  afterEach ->
    main.jumpTo = originalMainJumpTo

  describe "navigation-history:back", ->
    it "should fire CursorHistoryManager.popBackNavigation", ->
      main.activate()
      cursorHistoryManager = main.cursorHistoryManager
      cursorHistoryManager.popBackNavigation = jasmine.createSpy('pop-back-navigation')

      waitsFor ->
        editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
        atom.commands.dispatch(editorElement, 'navigation-history:back')

      runs ->
        expect(cursorHistoryManager.popBackNavigation).toHaveBeenCalled()

    it "should fire jumpTo with popped navigation as argument", ->
      main.activate()
      cursorHistoryManager = main.cursorHistoryManager
      cursorHistoryManager.popBackNavigation = -> 'back-navigation'
      main.jumpTo = jasmine.createSpy('jump-to')

      waitsFor ->
        editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
        atom.commands.dispatch(editorElement, 'navigation-history:back')

      runs ->
        expect(main.jumpTo).toHaveBeenCalledWith('back-navigation')

  describe "navigation-history:forward", ->
    it "should fire CursorHistoryManager.popForwardNavigation", ->
      main.activate()
      cursorHistoryManager = main.cursorHistoryManager
      cursorHistoryManager.popForwardNavigation = jasmine.createSpy('pop-forward-navigation')

      waitsFor ->
        editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
        atom.commands.dispatch(editorElement, 'navigation-history:forward')

      runs ->
        expect(cursorHistoryManager.popForwardNavigation).toHaveBeenCalled()

    it "should fire jumpTo with popped navigation as argument", ->
      main.activate()
      cursorHistoryManager = main.cursorHistoryManager
      cursorHistoryManager.popForwardNavigation = -> 'forward-navigation'
      main.jumpTo = jasmine.createSpy('jump-to')

      waitsFor ->
        editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
        atom.commands.dispatch(editorElement, 'navigation-history:forward')

      runs ->
        expect(main.jumpTo).toHaveBeenCalledWith('forward-navigation')

  describe "jumpTo", ->
    describe "when a valid navigation is provided", ->
      it "activates the navigation pane, editor and moves the cursor", ->
        main.activate()
        paneActivateSpy = jasmine.createSpy('pane-activate')
        editorActivateSpy = jasmine.createSpy('editor-activate')
        changeCursorSpy = jasmine.createSpy('change-cursor')
        changeScrollSpy = jasmine.createSpy('change-scroll')
        navigation =
          pane:
            activate: paneActivateSpy
            getActiveEditor: -> null
            activateItem: editorActivateSpy
          editor:
            setCursorBufferPosition: changeCursorSpy
            scrollToCursorPosition: changeScrollSpy
          position: 'test'

        main.jumpTo(navigation)

        expect(paneActivateSpy).toHaveBeenCalled()
        expect(editorActivateSpy).toHaveBeenCalled()
        expect(changeCursorSpy).toHaveBeenCalledWith(navigation.position, {autoscroll: false})
        expect(changeScrollSpy).toHaveBeenCalled()