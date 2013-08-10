describe 'Upon initialization', ->
  beforeEach ->
    spyOn window, 'setInterval'
    game.init()
  it 'should draw the surface 60 times / s', ->
    expect(window.setInterval).toHaveBeenCalledWith game.surface.draw, 1000/60