describe 'Upon initialization', ->
  canvas = null
  beforeEach ->
    spyOn window, 'setInterval'
    game.load()
    game.engine.init()
  it 'should draw the surface 60 times / s', ->
    expect(window.setInterval).toHaveBeenCalledWith game.engine.surface.draw, 1000/60
  it 'should update each ms', ->
    expect(window.setInterval).toHaveBeenCalledWith game.engine.update, 1
  it 'should track mouse events', ->
    moveMouseTo 47, 32
    expect(game.engine.events).toContain
      type: 'mousemove'
      x: 47
      y: 32