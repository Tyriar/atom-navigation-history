SizeLimitedStack = require 'size-limited-stack'
{CompositeDisposable} = require 'event-kit'

module.exports =
class CursorHistoryManager
  constructor: (maxNavigationsToRemember) ->
    @history = new SizeLimitedStack(maxNavigationsToRemember)
    @backHistory = new SizeLimitedStack(maxNavigationsToRemember)
    @ignoredNavigation = null

    pane = atom.workspace.getActivePane()
    editor = pane?.getActiveEditor()
    position = editor?.getLastCursor().getBufferPosition()

    if position?
      @currentNavigation = {pane, editor, position}

    @disposables = new CompositeDisposable
    @disposables.add atom.config.onDidChange 'navigation-history.maxNavigationsToRemember', =>
      @setMaxNavigationsToRemember(atom.config.get('navigation-history.maxNavigationsToRemember'))

  deactivate: ->
    @disposables.dispose()

  pushNewNavigation: (pane, editor, position) ->
    # Don't record navigations triggered from this package
    return if @currentNavigation? and @currentNavigation.position is position

    # TODO: Don't check for ignoredNavigation if the editor is different

    # Don't record navigations that move only a single character
    if @ignoredNavigation?
      if @shouldNavigationBeIgnored(@ignoredNavigation.position, position)
        @ignoredNavigation = {pane, editor, position}
        return
    else if @currentNavigation? and @shouldNavigationBeIgnored(@currentNavigation.position, position)
      @ignoredNavigation = {pane, editor, position}
      return
    @ignoredNavigation = null

    if @currentNavigation?
      @history.push(@currentNavigation)
    @currentNavigation = {pane, editor, position}
    @backHistory.length = 0

  popBackNavigation: ->
    return if @history.length is 0

    @backHistory.push(@currentNavigation)
    @currentNavigation = @history.pop()
    @currentNavigation

  popForwardNavigation: ->
    return if @backHistory.length is 0

    @history.push(@currentNavigation)
    @currentNavigation = @backHistory.pop()
    @currentNavigation

  getCurrentNavigation: -> @currentNavigation

  shouldNavigationBeIgnored: (oldPosition, newPosition) ->
    rowDifference = Math.abs(oldPosition.row - newPosition.row)
    rowDifference <= 1

  setMaxNavigationsToRemember: (maxNavigations) ->
    @history.setMaxSize(maxNavigations)
    @backHistory.setMaxSize(maxNavigations)
