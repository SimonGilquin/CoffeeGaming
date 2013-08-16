describe 'Upon initialization', ->
  canvas = null
  beforeEach ->
    game.load()
  it 'should update 60 times / s if there is no animation frames', ->
    spyOn window, 'setInterval'
    oldRequestAnimationFrame = window.requestAnimationFrame
    oldWebkitRequestAnimationFrame = window.webkitRequestAnimationFrame = null
    window.requestAnimationFrame = window.webkitRequestAnimationFrame = null
    game.engine.init()
    expect(window.setInterval).toHaveBeenCalledWith game.engine.mainLoop, 1000/60
    window.webkitRequestAnimationFrame = oldWebkitRequestAnimationFrame
    window.requestAnimationFrame = oldRequestAnimationFrame
  it 'should loop on the chrome animation frame', ->
    spyOn window, 'requestAnimationFrame'
    game.engine.init()
    expect(window.requestAnimationFrame).toHaveBeenCalled()
  it 'should loop on the chrome animation frame', ->
    spyOn game.engine, 'mainLoop'
    game.engine.init()
    expect(game.engine.mainLoop).toHaveBeenCalled()
  it 'should register mouse movements', ->
    game.engine.init()
    moveMouseTo 47, 32
    expect(game.engine.events).toContain
      type: 'mousemove'
      x: 47
      y: 32
  it 'should register mouse pressing', ->
    game.engine.init()
    mouseDownAt 47, 32
    expect(game.engine.events).toContain
      type: 'mousedown'
      x: 47
      y: 32
  it 'should register mouse releasing', ->
    game.engine.init()
    mouseUpAt 47, 32
    expect(game.engine.events).toContain
      type: 'mouseup'
      x: 47
      y: 32

  it 'should register key pressing', ->
    game.engine.init()
    pressKey 23
    expect(game.engine.events[0].type).toBe 'keydown'
    expect(game.engine.events[0].keyCode).toBe 23

  describe 'the key mapping', ->
    beforeEach ->
      game.engine.init()
    it 'maps up to thrust', ->
      pressKey 38
      expect(game.engine.events[0].action).toBe 'thrust'

  describe 'the update loop', ->
    it 'consumes the events', ->
      game.engine.init()
      moveMouseTo 47, 32
      mouseDownAt 47, 32
      game.engine.update()
      expect(game.engine.events.length).toBe 0

