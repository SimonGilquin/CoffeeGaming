describe 'Upon initialization', ->
  canvas = null
  beforeEach ->
    spyOn window, 'setInterval'
    game.load()
  xit 'should update 60 times / s', ->
    game.engine.init()
    expect(window.setInterval).toHaveBeenCalledWith game.engine.mainLoop, 1000/60
  it 'should loop on the chrome animation frame', ->
    spyOn window, 'requestAnimationFrame'
    game.engine.init()
    expect(window.requestAnimationFrame).toHaveBeenCalled()
  it 'should loop on the chrome animation frame', ->
    spyOn game.engine, 'mainLoop'
    game.engine.init()
    expect(game.engine.mainLoop).toHaveBeenCalled()
  it 'should track mouse events', ->
    game.engine.init()
    moveMouseTo 47, 32
    expect(game.engine.events).toContain
      type: 'mousemove'
      x: 47
      y: 32