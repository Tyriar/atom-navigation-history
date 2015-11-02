CursorHistoryManager = require '../lib/cursor-history-manager'

describe "CursorHistoryManager", ->
  manager = null
  initialNavigation = null

  beforeEach ->
    # Mock initial navigation
    atom.workspace.getActivePane = ->
      getActiveEditor: ->
        getLastCursor: ->
          getBufferPosition: -> 'test'
    manager = new CursorHistoryManager()
    initialNavigation = manager.getCurrentNavigation()

    waitsForPromise ->
      atom.packages.activatePackage("navigation-history")

  describe "when no entries are added to CursorHistoryManager", ->
    it "should push the initial navigation", ->
      expect(initialNavigation.pane.getActiveEditor().getLastCursor().getBufferPosition()).toBe('test')
      expect(initialNavigation.editor.getLastCursor().getBufferPosition()).toBe('test')
      expect(initialNavigation.position).toBe('test')

    describe "when popBackNavigation is called", ->
      it "should return undefined", ->
        backNavigation = manager.popBackNavigation()
        expect(backNavigation).not.toBeDefined()

    describe "when popForwardNavigation is called", ->
      it "should return undefined", ->
        forwardNavigation = manager.popForwardNavigation()
        expect(forwardNavigation).not.toBeDefined()

  describe "when a single entry is added to CursorHistoryManager", ->
    newNavigation = null

    beforeEach ->
      manager.pushNewNavigation('a', 'b', 'c')
      newNavigation = manager.getCurrentNavigation()

    it "should update the current navigation", ->
      expect(newNavigation.pane).toBe('a')
      expect(newNavigation.editor).toBe('b')
      expect(newNavigation.position).toBe('c')

    describe "when popBackNavigation is called", ->
      backNavigation = null

      beforeEach ->
        backNavigation = manager.popBackNavigation()

      it "should return the initial navigation (undefined)", ->
        expect(backNavigation).toBe(initialNavigation)

      describe "when popForwardNavigation is called", ->
        it "should return the new navigation", ->
          expect(manager.popForwardNavigation()).toBe(newNavigation)

      describe "when popForwardNavigation is called twice", ->
        it "should return undefined", ->
          manager.popForwardNavigation()
          expect(manager.popForwardNavigation()).not.toBeDefined()

    describe "when popForwardNavigation is called", ->
      it "should return the forward navigation (undefined)", ->
        expect(manager.popForwardNavigation()).not.toBeDefined()

  describe "when multiple entries are added to CursorHistoryManager", ->
    newNavigations = []

    beforeEach ->
      manager.pushNewNavigation('a', 'b', 'c')
      newNavigations.push(manager.getCurrentNavigation())
      manager.pushNewNavigation('d', 'e', 'f')
      newNavigations.push(manager.getCurrentNavigation())
      manager.pushNewNavigation('g', 'h', 'i')
      newNavigations.push(manager.getCurrentNavigation())

    it "should update current navigations", ->
      expect(newNavigations.length).toBe(3)
      expect(newNavigations[0]).toEqual({pane: 'a', editor: 'b', position: 'c'})
      expect(newNavigations[1]).toEqual({pane: 'd', editor: 'e', position: 'f'})
      expect(newNavigations[2]).toEqual({pane: 'g', editor: 'h', position: 'i'})

    describe "when popBackNavigation is called", ->
      backNavigations = []

      beforeEach ->
        backNavigations.push(manager.popBackNavigation())
        backNavigations.push(manager.popBackNavigation())
        backNavigations.push(manager.popBackNavigation())

      it "should return the back navigations in order", ->
        expect(backNavigations[0]).toEqual(newNavigations[1])
        expect(backNavigations[1]).toEqual(newNavigations[0])
        expect(backNavigations[2]).toEqual(initialNavigation)
        expect(backNavigations[3]).not.toBeDefined()

      describe "when popForwardNavigation is called", ->
        forwardNavigations = []

        beforeEach ->
          forwardNavigations.push(manager.popForwardNavigation())
          forwardNavigations.push(manager.popForwardNavigation())
          forwardNavigations.push(manager.popForwardNavigation())
          forwardNavigations.push(manager.popForwardNavigation())

        it "should return the forward navigations in order", ->
          expect(forwardNavigations[0]).toEqual(newNavigations[0])
          expect(forwardNavigations[1]).toEqual(newNavigations[1])
          expect(forwardNavigations[2]).toEqual(newNavigations[2])
          expect(forwardNavigations[3]).toEqual(undefined)

  describe "the maxNavigationsToRemember config option", ->
    it "defaults to 30", ->
      expect(atom.config.get("navigation-history.maxNavigationsToRemember")).toBe(30)

    describe "when set to 2", ->
      beforeEach ->
        atom.config.set('navigation-history.maxNavigationsToRemember', 2)

      it "should remember only the last 2 navigations in either direction", ->
        navigations = []
        manager.pushNewNavigation('a', 'b', 'c')
        navigations.push(manager.getCurrentNavigation())
        manager.pushNewNavigation('d', 'e', 'f')
        navigations.push(manager.getCurrentNavigation())
        manager.pushNewNavigation('g', 'h', 'i')
        navigations.push(manager.getCurrentNavigation())
        expect(manager.popBackNavigation()).toBe(navigations[1])
        expect(manager.popBackNavigation()).toBe(navigations[0])
        expect(manager.popBackNavigation()).not.toBeDefined()
        expect(manager.popForwardNavigation()).toBe(navigations[1])
        expect(manager.popForwardNavigation()).toBe(navigations[2])
        expect(manager.popForwardNavigation()).not.toBeDefined()
