module.exports =
class SizeLimitedStack
  constructor: (@maxSize) ->
    @stack = []
    @length = 0

  push: (value) ->
    @stack.push(value)
    @length = @stack.length
    @evictIfNecessary()
    return

  pop: ->
    value = @stack.pop()
    @length = @stack.length
    value

  setMaxSize: (maxSize) ->
    if typeof maxSize isnt 'number'
      throw 'Max size must be a number'
    if maxSize < 1
      throw 'Max size must be at least 1'
    @maxSize = maxSize
    @evictIfNecessary()

  evictIfNecessary: ->
    @stack.shift() while @stack.length > @maxSize
    @length = @stack.length
