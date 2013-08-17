describe 'Upon initialization', ->
  canvas = null
  engine = null
  beforeEach ->
    game.engine = engine = new Engine()
  it 'should update 60 times / s if there is no animation frames', ->
    spyOn window, 'setInterval'
    oldRequestAnimationFrame = window.requestAnimationFrame
    oldWebkitRequestAnimationFrame = window.webkitRequestAnimationFrame = null
    window.requestAnimationFrame = window.webkitRequestAnimationFrame = null
    engine.init()
    expect(window.setInterval).toHaveBeenCalledWith game.engine.mainLoop, 1000/60
    window.webkitRequestAnimationFrame = oldWebkitRequestAnimationFrame
    window.requestAnimationFrame = oldRequestAnimationFrame
  it 'should loop on the chrome animation frame', ->
    spyOn window, 'requestAnimationFrame'
    engine.init()
    expect(window.requestAnimationFrame).toHaveBeenCalled()
  it 'should loop on the chrome animation frame', ->
    spyOn engine, 'mainLoop'
    engine.init()
    expect(game.engine.mainLoop).toHaveBeenCalled()
  it 'should register mouse movements', ->
    engine.init()
    moveMouseTo 47, 32
    expect(game.engine.events).toContain
      type: 'mousemove'
      x: 47
      y: 32
  it 'should register mouse pressing', ->
    engine.init()
    mouseDownAt 47, 32
    expect(engine.events).toContain
      type: 'mousedown'
      x: 47
      y: 32
  it 'should register mouse releasing', ->
    engine.init()
    mouseUpAt 47, 32
    expect(engine.events).toContain
      type: 'mouseup'
      x: 47
      y: 32

  it 'should register key pressing', ->
    engine.init()
    pressKey 23
    expect(engine.events[0].type).toBe 'keydown'
    expect(engine.events[0].keyCode).toBe 23

  describe 'the key mapping', ->
    beforeEach ->
      engine.init()
    it 'maps up to thrust', ->
      pressKey 38
      expect(game.engine.events[0].action).toBe 'thrust'
    it 'pauses / resumes the game on escape', ->
      pressKey 27
      engine.update()
      expect(engine.isPaused()).toBeFalsy()
      pressKey 27
      engine.update()
      expect(engine.isPaused()).toBeTruthy()

  describe 'the update loop', ->
    it 'consumes the events', ->
      engine.init()
      moveMouseTo 47, 32
      mouseDownAt 47, 32
      engine.update()
      expect(engine.events.length).toBe 0

