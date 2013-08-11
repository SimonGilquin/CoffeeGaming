describe 'Upon initialization', ->
  canvas = null
  beforeEach ->
    spyOn window, 'setInterval'
    game.load()
    game.engine.init()
  it 'should update 60 times / s', ->
    expect(window.setInterval).toHaveBeenCalledWith game.engine.mainLoop, 1000/60
  it 'should track mouse events', ->
    moveMouseTo 47, 32
    expect(game.engine.events).toContain
      type: 'mousemove'
      x: 47
      y: 32