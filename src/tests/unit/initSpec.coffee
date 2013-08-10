describe 'Upon initialization', ->
  canvas = null
  beforeEach ->
    spyOn window, 'setInterval'
    game.init()
  it 'should draw the surface 60 times / s', ->
    expect(window.setInterval).toHaveBeenCalledWith game.surface.draw, 1000/60
  it 'should track mouse events', ->
    moveMouseTo 47, 32
    expect(game.events).toContain
      type: 'mousemove'
      x: 47
      y: 32