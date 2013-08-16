describe 'The game surface', ->
  surface = null

  beforeEach ->
    game.load()
    game.engine.init()
    surface = game.engine.surface

  it 'should have the same size as the viewport', ->
    expect(surface.width).toBe game.engine.viewport.width
    expect(surface.height).toBe game.engine.viewport.height

